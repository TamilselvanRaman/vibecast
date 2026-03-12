import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../models/song_model.dart';
import '../../core/services/youtube_service.dart';
import '../search/search_provider.dart';
import '../player/player_provider.dart';
import '../settings/language_provider.dart';
import '../settings/api_key_provider.dart';
import 'widgets/music_card.dart';

// These providers now watch the selected language and refresh automatically
final trendingProvider = FutureProvider<List<Song>>((ref) async {
  final service = ref.watch(youtubeServiceProvider);
  final lang = ref.watch(languageProvider);
  final items = await service.searchMusic(lang.trendingQuery);
  return items.map((json) => Song.fromJson(json)).toList();
});

final recommendedProvider = FutureProvider<List<Song>>((ref) async {
  final service = ref.watch(youtubeServiceProvider);
  final lang = ref.watch(languageProvider);
  final items = await service.searchMusic(lang.recommendedQuery);
  return items.map((json) => Song.fromJson(json)).toList();
});

final newReleasesProvider = FutureProvider<List<Song>>((ref) async {
  final service = ref.watch(youtubeServiceProvider);
  final lang = ref.watch(languageProvider);
  final items = await service.searchMusic(lang.newReleasesQuery);
  return items.map((json) => Song.fromJson(json)).toList();
});

final topArtistsProvider = FutureProvider<List<Song>>((ref) async {
  final service = ref.watch(youtubeServiceProvider);
  final lang = ref.watch(languageProvider);
  final items = await service.searchMusic(lang.topArtistsQuery);
  return items.map((json) => Song.fromJson(json)).toList();
});

final focusProvider = FutureProvider<List<Song>>((ref) async {
  final service = ref.watch(youtubeServiceProvider);
  final lang = ref.watch(languageProvider);
  final items = await service.searchMusic(lang.focusQuery);
  return items.map((json) => Song.fromJson(json)).toList();
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  void _showApiKeySettings(BuildContext context, WidgetRef ref) {
    final currentKey = ref.read(apiKeyProvider);
    final keyController = TextEditingController(text: currentKey);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Custom API Key',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your own YouTube Data v3 API Key to bypass daily quota limits. Leave blank to use the default app key.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: keyController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'AIzaSyA...',
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.backgroundPrimary,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  await ref.read(apiKeyProvider.notifier).setKey(keyController.text);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('API Key updated!'),
                      backgroundColor: AppColors.accentPrimary,
                    ),
                  );
                },
                child: const Text('Save API Key', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    final currentLang = ref.read(languageProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose Language',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: availableLanguages.map((lang) {
                  final isSelected = lang.label == currentLang.label;
                  return GestureDetector(
                    onTap: () {
                      ref.read(languageProvider.notifier).setLanguage(lang);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.backgroundPrimary,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.accentPrimary
                              : AppColors.textSecondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        lang.label,
                        style: TextStyle(
                          color: isSelected ? Colors.black : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLang = ref.watch(languageProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 80,
            backgroundColor: AppColors.backgroundPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                _getGreeting(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            actions: [
              // Language Selector Button
              GestureDetector(
                onTap: () => _showLanguagePicker(context, ref),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPrimary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.accentPrimary, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language, color: AppColors.accentPrimary, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        selectedLang.label,
                        style: const TextStyle(
                          color: AppColors.accentPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _showApiKeySettings(context, ref),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(context, ref, 'Trending Now', Icons.local_fire_department, trendingProvider),
                  const SizedBox(height: 32),
                  _buildSection(context, ref, 'New Releases', Icons.album, newReleasesProvider),
                  const SizedBox(height: 32),
                  _buildSection(context, ref, 'Recommended For You', Icons.auto_awesome, recommendedProvider),
                  const SizedBox(height: 32),
                  _buildSection(context, ref, 'Top Artists', Icons.mic, topArtistsProvider),
                  const SizedBox(height: 32),
                  _buildSection(context, ref, 'Focus & Relax', Icons.psychology, focusProvider),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, WidgetRef ref, String title, IconData icon,
      FutureProvider<List<Song>> provider) {
    final asyncValue = ref.watch(provider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentPrimary, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 220,
          child: asyncValue.when(
            data: (songs) {
              if (songs.isEmpty) {
                return const Center(
                  child: Text('No songs found.', style: TextStyle(color: AppColors.textSecondary)),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return MusicCard(
                    song: songs[index],
                    onTap: () {
                      ref.read(currentSongProvider.notifier).setSong(songs[index]);
                      ref.read(playerControllerProvider.notifier).playSong(songs[index]);
                      context.push('/player');
                    },
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accentPrimary),
            ),
            error: (err, stack) {
              String msg = 'Failed to load songs.';
              final errString = err.toString();
              if (errString.contains('403') || errString.contains('quota')) {
                msg = 'Daily API limit reached.\nPlease try again later.';
              } else if (errString.contains('SocketException') || errString.contains('TimeoutException') || errString.contains('timeout')) {
                msg = 'Network error. Check your connection.';
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      TextButton(
                        onPressed: () => ref.invalidate(provider),
                        child: const Text('Retry', style: TextStyle(color: AppColors.accentPrimary)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
