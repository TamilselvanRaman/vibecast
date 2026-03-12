import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/song_model.dart';
import '../../core/services/youtube_service.dart';
import '../settings/api_key_provider.dart';

class CurrentSongNotifier extends Notifier<Song?> {
  @override
  Song? build() => null;

  void setSong(Song? song) {
    state = song;
  }
}

final currentSongProvider = NotifierProvider<CurrentSongNotifier, Song?>(CurrentSongNotifier.new);

class ShuffleNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}
final shuffleProvider = NotifierProvider<ShuffleNotifier, bool>(ShuffleNotifier.new);

class RepeatNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}
final repeatProvider = NotifierProvider<RepeatNotifier, bool>(RepeatNotifier.new);

class PlayerStateNotifier extends Notifier<YoutubePlayerController?> {
  bool _isFetchingNext = false;

  @override
  YoutubePlayerController? build() {
    ref.onDispose(() {
      state?.removeListener(_playerListener);
      state?.dispose();
    });
    return null;
  }

  void _playerListener() {
    final controller = state;
    if (controller == null) return;
    if (controller.value.playerState == PlayerState.ended && !_isFetchingNext) {
      _playNextRelated();
    }
  }

  Future<void> _playNextRelated() async {
    final currentSong = ref.read(currentSongProvider);
    if (currentSong == null) return;

    final isRepeat = ref.read(repeatProvider);
    if (isRepeat) {
      state?.seekTo(Duration.zero);
      state?.play();
      return;
    }

    if (_isFetchingNext) return;
    _isFetchingNext = true;
    try {
      final service = YouTubeService(apiKey: ref.read(apiKeyProvider));
      // 'relatedToVideoId' was deprecated by YouTube in Aug 2023.
      // Fallback: simply search for another song by the same channel/artist.
      final query = "${currentSong.channel} audio OR song";
      final relatedItems = await service.searchMusic(query);
      
      if (relatedItems.isNotEmpty) {
        // Find valid video items that are NOT the exact current song.
        final items = relatedItems.where((item) {
          final id = item['id']?['videoId'];
          return id != null && id != currentSong.videoId;
        }).toList();

        if (items.isNotEmpty) {
           final isShuffle = ref.read(shuffleProvider);
           if (isShuffle) {
             items.shuffle();
           }
           final nextSong = Song.fromJson(items.first);
           ref.read(currentSongProvider.notifier).setSong(nextSong);
           playSong(nextSong);
        }
      }
    } catch (e) {
      print("Error fetching related song: $e");
    } finally {
      // Small delay before allowing another fetch to avoid double fetches when state bounces
      Future.delayed(const Duration(seconds: 2), () {
        _isFetchingNext = false;
      });
    }
  }

  Future<void> playNext() async {
    await _playNextRelated();
  }

  void playSong(Song song) {
    if (state != null) {
      state!.load(song.videoId);
    } else {
      final controller = YoutubePlayerController(
        initialVideoId: song.videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          hideControls: true, 
          disableDragSeek: true,
          loop: false,
        ),
      );
      controller.addListener(_playerListener);
      state = controller;
    }
  }

  void togglePlayPause() {
    if (state == null) return;
    if (state!.value.isPlaying) {
      state!.pause();
    } else {
      state!.play();
    }
  }

  void seekTo(Duration position) {
    state?.seekTo(position);
  }
}

final playerControllerProvider = NotifierProvider<PlayerStateNotifier, YoutubePlayerController?>(PlayerStateNotifier.new);
