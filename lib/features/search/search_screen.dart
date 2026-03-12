import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'search_provider.dart';
import '../../models/song_model.dart';
import '../player/player_provider.dart';
import '../library/library_provider.dart';
import '../../core/constants/app_colors.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // Fires 500ms after the user stops typing
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isNotEmpty) {
        ref.read(searchQueryProvider.notifier).setQuery(value.trim());
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondary,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Tamil songs, Bollywood 2025...',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: AppColors.accentPrimary),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {});
            _onSearchChanged(value);
          },
          onSubmitted: (value) {
            _debounce?.cancel();
            if (value.trim().isNotEmpty) {
              ref.read(searchQueryProvider.notifier).setQuery(value.trim());
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              _debounce?.cancel();
              _controller.clear();
              ref.read(searchQueryProvider.notifier).setQuery('');
              FocusScope.of(context).unfocus();
              context.go('/home');
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.accentPrimary, fontSize: 15),
            ),
          ),
        ],
      ),
      body: searchResults.when(
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.music_note, size: 72, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'Try "Tamil songs" or "Bollywood hits"',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          final songs = items
              .where((item) => item['id']?['videoId'] != null)
              .map((item) => Song.fromJson(item))
              .toList();

          return ListView.builder(
            itemCount: songs.length,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    song.thumbnail,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 56,
                      height: 56,
                      color: AppColors.backgroundSecondary,
                      child: const Icon(Icons.music_note, color: AppColors.textSecondary),
                    ),
                  ),
                ),
                title: Text(
                  song.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                subtitle: Text(
                  song.channel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                  color: AppColors.backgroundSecondary,
                  onSelected: (value) async {
                    if (value == 'play') {
                      ref.read(currentSongProvider.notifier).setSong(song);
                      ref.read(playerControllerProvider.notifier).playSong(song);
                      context.push('/player');
                    } else if (value == 'add_playlist') {
                      final playlists = ref.read(libraryProvider).value ?? [];
                      if (playlists.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Go to Library and create a playlist first!'),
                            backgroundColor: Color(0xFF282828),
                          ),
                        );
                        return;
                      }
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: const Color(0xFF282828),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Add to Playlist',
                                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              ...playlists.map((p) => ListTile(
                                leading: const Icon(Icons.queue_music, color: Color(0xFF1DB954)),
                                title: Text(p.name, style: const TextStyle(color: Colors.white)),
                                subtitle: Text('${p.songs.length} songs', style: const TextStyle(color: Colors.grey)),
                                onTap: () {
                                  ref.read(libraryProvider.notifier).addSongToPlaylist(p.id, song);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Added to "${p.name}"'),
                                      backgroundColor: const Color(0xFF1DB954),
                                    ),
                                  );
                                },
                              )),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'play', child: Row(
                      children: [Icon(Icons.play_arrow, color: Color(0xFF1DB954)), SizedBox(width: 8), Text('Play', style: TextStyle(color: Colors.white))],
                    )),
                    PopupMenuItem(value: 'add_playlist', child: Row(
                      children: [Icon(Icons.playlist_add, color: Color(0xFF1DB954)), SizedBox(width: 8), Text('Add to Playlist', style: TextStyle(color: Colors.white))],
                    )),
                  ],
                ),
                onTap: () {
                  ref.read(currentSongProvider.notifier).setSong(song);
                  ref.read(playerControllerProvider.notifier).playSong(song);
                  context.push('/player');
                },
              );
            },
          );
        },
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.accentPrimary),
              SizedBox(height: 16),
              Text('Searching...', style: TextStyle(color: AppColors.textSecondary)),
            ],
          ),
        ),
        error: (err, stack) {
          String msg = 'Search failed. Check your internet.';
          final errString = err.toString();
          if (errString.contains('403') || errString.contains('quota')) {
            msg = 'Daily API limit reached. Try playing from Library.';
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  errString.contains('403') ? Icons.error_outline : Icons.wifi_off, 
                  size: 56, 
                  color: Colors.red
                ),
                const SizedBox(height: 16),
                Text(msg, style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    final q = _controller.text.trim();
                    if (q.isNotEmpty) {
                      ref.read(searchQueryProvider.notifier).setQuery(q);
                    }
                  },
                  child: const Text('Retry', style: TextStyle(color: AppColors.accentPrimary)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
