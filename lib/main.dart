import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'features/home/home_screen.dart';
import 'features/search/search_screen.dart';
import 'features/playlist/playlist_screen.dart';
import 'features/player/player_screen.dart';
import 'features/library/library_screen.dart';
import 'features/player/mini_player.dart';
import 'features/player/player_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// Router Configuration
final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainAppLayout(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const LibraryScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/player',
      builder: (context, state) => const PlayerScreen(),
    ),
    // Pass videoId or playlist data as extra config
    GoRoute(
      path: '/playlist',
      builder: (context, state) => const PlaylistScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VibeCast',
      theme: appTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Global Main Layout to embed the MiniPlayer over the Bottom Navigation
class MainAppLayout extends StatefulWidget {
  final Widget child;
  const MainAppLayout({super.key, required this.child});

  @override
  State<MainAppLayout> createState() => _MainAppLayoutState();
}

class _MainAppLayoutState extends State<MainAppLayout> {
  int _currentIndex = 0;

  void _onItemTapped(int index, BuildContext context) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/search');
        break;
      case 2:
        context.go('/library');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          widget.child,
          // Global invisible player instance to enable persistent music buffering
          Consumer(
            builder: (context, ref, _) {
              final controller = ref.watch(playerControllerProvider);
              if (controller == null) return const SizedBox.shrink();
              return Offstage(
                offstage: true, // Audio will still play while hidden
                child: YoutubePlayer(
                  controller: controller,
                ),
              );
            },
          ),
          // Position MiniPlayer slightly above the BottomNavigationBar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0, 
            child: MiniPlayer(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: 'Library'),
        ],
      ),
    );
  }
}
