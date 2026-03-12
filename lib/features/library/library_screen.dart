import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import 'library_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('New Playlist', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Playlist name...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentPrimary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentPrimary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(libraryProvider.notifier).createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create', style: TextStyle(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryAsync = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        title: const Text('Your Library',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.accentPrimary, size: 28),
            tooltip: 'Create Playlist',
            onPressed: () => _showCreatePlaylistDialog(context, ref),
          )
        ],
      ),
      body: libraryAsync.when(
        data: (playlists) {
          if (playlists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.library_music, size: 80, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  const Text('No playlists yet',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap + to create your first playlist',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Playlist', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _showCreatePlaylistDialog(context, ref),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return Dismissible(
                key: Key(playlist.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.shade900,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  ref.read(libraryProvider.notifier).deletePlaylist(playlist.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"${playlist.name}" deleted'),
                      backgroundColor: AppColors.backgroundSecondary,
                    ),
                  );
                },
                child: Card(
                  color: AppColors.backgroundSecondary,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: playlist.songs.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                playlist.songs.first.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.queue_music, color: AppColors.accentPrimary),
                              ),
                            )
                          : const Icon(Icons.queue_music, color: AppColors.accentPrimary),
                    ),
                    title: Text(playlist.name,
                        style: const TextStyle(
                            color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${playlist.songs.length} song${playlist.songs.length == 1 ? '' : 's'}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PlaylistDetailScreen(playlist: playlist),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// Playlist Detail Screen (shows songs inside a playlist)
// ──────────────────────────────────────────────────────────────
class PlaylistDetailScreen extends ConsumerWidget {
  final Playlist playlist;
  const PlaylistDetailScreen({super.key, required this.playlist});

  void _showRenameDialog(BuildContext context, WidgetRef ref, Playlist currentPlaylist) {
    final controller = TextEditingController(text: currentPlaylist.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Rename Playlist', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'New playlist name...',
            hintStyle: TextStyle(color: AppColors.textSecondary),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentPrimary),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.accentPrimary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != currentPlaylist.name) {
                ref.read(libraryProvider.notifier).renamePlaylist(currentPlaylist.id, newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save', style: TextStyle(color: AppColors.accentPrimary)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Playlist currentPlaylist) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundSecondary,
        title: const Text('Delete Playlist', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Are you sure you want to delete "${currentPlaylist.name}"?',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(libraryProvider.notifier).deletePlaylist(currentPlaylist.id);
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close PlaylistDetailScreen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${currentPlaylist.name}" deleted'),
                  backgroundColor: AppColors.backgroundSecondary,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the library to get live updates to this playlist
    final libraryAsync = ref.watch(libraryProvider);
    final currentPlaylist = libraryAsync.when(
      data: (list) => list.firstWhere((p) => p.id == playlist.id, orElse: () => playlist),
      loading: () => playlist,
      error: (_, __) => playlist,
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        leading: const BackButton(color: AppColors.textPrimary),
        title: Text(currentPlaylist.name,
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            color: AppColors.backgroundSecondary,
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameDialog(context, ref, currentPlaylist);
              } else if (value == 'delete') {
                _confirmDelete(context, ref, currentPlaylist);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'rename',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.textPrimary, size: 20),
                    SizedBox(width: 12),
                    Text('Rename Playlist', style: TextStyle(color: AppColors.textPrimary)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete Playlist', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: currentPlaylist.songs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.music_off, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No songs yet', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                  SizedBox(height: 8),
                  Text('Search for songs and tap ⋮ → Add to Playlist',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      textAlign: TextAlign.center),
                ],
              ),
            )
          : ListView.builder(
              itemCount: currentPlaylist.songs.length,
              itemBuilder: (context, index) {
                final song = currentPlaylist.songs[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      song.thumbnail,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.music_note, color: AppColors.textSecondary),
                    ),
                  ),
                  title: Text(song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                  subtitle: Text(song.channel,
                      style: const TextStyle(color: AppColors.textSecondary)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(libraryProvider.notifier)
                          .removeSongFromPlaylist(currentPlaylist.id, song.videoId);
                    },
                  ),
                );
              },
            ),
    );
  }
}
