import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:ui';
import '../../core/constants/app_colors.dart';
import 'player_provider.dart';
import '../library/library_provider.dart';
import '../../models/song_model.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  void _showPlaylistBottomSheet(BuildContext context, WidgetRef ref, Song song) {
    final playlists = ref.read(libraryProvider).value ?? [];
    if (playlists.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go to Library and create a playlist first!'), backgroundColor: Color(0xFF282828)),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF282828),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add to Playlist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...playlists.map((p) => ListTile(
              leading: const Icon(Icons.queue_music, color: Color(0xFF1DB954)),
              title: Text(p.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text('${p.songs.length} songs', style: const TextStyle(color: Colors.grey)),
              onTap: () {
                ref.read(libraryProvider.notifier).addSongToPlaylist(p.id, song);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added to "${p.name}"'), backgroundColor: const Color(0xFF1DB954)),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSong = ref.watch(currentSongProvider);
    final controller = ref.watch(playerControllerProvider);
    final isShuffle = ref.watch(shuffleProvider);
    final isRepeat = ref.watch(repeatProvider);

    if (currentSong == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Player')),
        body: const Center(child: Text('No song selected')),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Now Playing', style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background
          Image.network(
            currentSong.thumbnail,
            fit: BoxFit.cover,
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Album Art
                  Container(
                    width: MediaQuery.of(context).size.width - 48,
                    height: MediaQuery.of(context).size.width - 48,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 20,
                          offset: Offset(0, 10),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        currentSong.thumbnail,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Title & Artist & Add Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentSong.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentSong.channel,
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.accentPrimary, size: 40),
                        onPressed: () => _showPlaylistBottomSheet(context, ref, currentSong),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Progress Bar (using linear progress for mockup, as fetching true duration is complex via YT headless)
                  ProgressBar(controller: controller),
                  
                  const SizedBox(height: 16),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shuffle, size: 28, color: isShuffle ? AppColors.accentPrimary : AppColors.textSecondary),
                        onPressed: () { ref.read(shuffleProvider.notifier).toggle(); },
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous, size: 36, color: AppColors.textPrimary),
                        onPressed: () {},
                      ),
                      PlayPauseButton(
                        controller: controller,
                        onToggle: () => ref.read(playerControllerProvider.notifier).togglePlayPause(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, size: 36, color: AppColors.textPrimary),
                        onPressed: () {
                           // Skip next manually uses the autoplay logic
                           ref.read(playerControllerProvider.notifier).playNext();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.repeat, size: 28, color: isRepeat ? AppColors.accentPrimary : AppColors.textSecondary),
                        onPressed: () { ref.read(repeatProvider.notifier).toggle(); },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom progress bar interacting with YoutubePlayerController
class ProgressBar extends StatefulWidget {
  final YoutubePlayerController? controller;
  const ProgressBar({super.key, required this.controller});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_listener);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      return const LinearProgressIndicator(value: 0);
    }
    final position = widget.controller!.value.position;
    final duration = widget.controller!.metadata.duration;
    
    double progress = 0.0;
    if (duration.inMilliseconds > 0) {
      progress = position.inMilliseconds / duration.inMilliseconds;
    }

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            activeTrackColor: AppColors.accentPrimary,
            inactiveTrackColor: Colors.grey.shade800,
            thumbColor: Colors.white,
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (val) {
              final newPosition = Duration(milliseconds: (val * duration.inMilliseconds).toInt());
              widget.controller!.seekTo(newPosition);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              Text(
                '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom Play/Pause Button interacting with YoutubePlayerController
class PlayPauseButton extends StatefulWidget {
  final YoutubePlayerController? controller;
  final VoidCallback onToggle;

  const PlayPauseButton({super.key, required this.controller, required this.onToggle});

  @override
  State<PlayPauseButton> createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_listener);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.controller?.value.isPlaying ?? false;
    
    return Container(
      width: 72,
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.accentPrimary,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(
          isPlaying ? Icons.pause : Icons.play_arrow,
          size: 36,
          color: Colors.black,
        ),
        onPressed: widget.onToggle,
      ),
    );
  }
}

