import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/song_model.dart';

class Playlist {
  final String id;
  final String name;
  final List<Song> songs;

  Playlist({required this.id, required this.name, required this.songs});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songs': songs
            .map((s) => {
                  'title': s.title,
                  'thumbnail': s.thumbnail,
                  'videoId': s.videoId,
                  'channel': s.channel,
                })
            .toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'],
        name: json['name'],
        songs: (json['songs'] as List)
            .map((s) => Song(
                  title: s['title'],
                  thumbnail: s['thumbnail'],
                  videoId: s['videoId'],
                  channel: s['channel'],
                ))
            .toList(),
      );

  Playlist copyWith({String? name, List<Song>? songs}) => Playlist(
        id: id,
        name: name ?? this.name,
        songs: songs ?? this.songs,
      );
}

const _kPlaylistsKey = 'vibecast_playlists';

class LibraryNotifier extends AsyncNotifier<List<Playlist>> {
  @override
  Future<List<Playlist>> build() async {
    return await _loadPlaylists();
  }

  Future<List<Playlist>> _loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_kPlaylistsKey);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((j) => Playlist.fromJson(j)).toList();
  }

  Future<void> _save(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kPlaylistsKey, jsonEncode(playlists.map((p) => p.toJson()).toList()));
  }

  Future<void> createPlaylist(String name) async {
    final current = state.value ?? [];
    final newPlaylist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songs: [],
    );
    final updated = [...current, newPlaylist];
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> deletePlaylist(String id) async {
    final current = state.value ?? [];
    final updated = current.where((p) => p.id != id).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final current = state.value ?? [];
    final updated = current.map((p) {
      if (p.id != id) return p;
      return Playlist(id: p.id, name: newName, songs: p.songs);
    }).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final current = state.value ?? [];
    final updated = current.map((p) {
      if (p.id != playlistId) return p;
      // Avoid duplicates
      if (p.songs.any((s) => s.videoId == song.videoId)) return p;
      return p.copyWith(songs: [...p.songs, song]);
    }).toList();
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> removeSongFromPlaylist(String playlistId, String videoId) async {
    final current = state.value ?? [];
    final updated = current.map((p) {
      if (p.id != playlistId) return p;
      return p.copyWith(songs: p.songs.where((s) => s.videoId != videoId).toList());
    }).toList();
    state = AsyncData(updated);
    await _save(updated);
  }
}

final libraryProvider = AsyncNotifierProvider<LibraryNotifier, List<Playlist>>(LibraryNotifier.new);
