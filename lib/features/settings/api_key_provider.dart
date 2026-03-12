import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeyNotifier extends Notifier<String> {
  static const _key = 'custom_youtube_api_key';

  @override
  String build() {
    _loadKey();
    return dotenv.env['YOUTUBE_API_KEY'] ?? "";
  }

  Future<void> _loadKey() async {
    final prefs = await SharedPreferences.getInstance();
    final customKey = prefs.getString(_key);
    if (customKey != null && customKey.trim().isNotEmpty) {
      state = customKey;
    }
  }

  Future<void> setKey(String newKey) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (newKey.trim().isEmpty) {
      // Revert to default
      await prefs.remove(_key);
      state = dotenv.env['YOUTUBE_API_KEY'] ?? "";
    } else {
      // Save custom key
      await prefs.setString(_key, newKey.trim());
      state = newKey.trim();
    }
  }
}

final apiKeyProvider = NotifierProvider<ApiKeyNotifier, String>(ApiKeyNotifier.new);
