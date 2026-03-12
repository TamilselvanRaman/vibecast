import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/youtube_service.dart';
import '../settings/api_key_provider.dart';

final youtubeServiceProvider = Provider((ref) {
  final apiKey = ref.watch(apiKeyProvider);
  return YouTubeService(apiKey: apiKey);
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => "";

  void setQuery(String value) {
    state = value;
  }
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

final searchResultsProvider = FutureProvider<List<dynamic>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.length < 1) return []; // allow from 1 character
  
  final service = ref.watch(youtubeServiceProvider);
  return await service.searchMusic(query);
});
