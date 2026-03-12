import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YouTubeService {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  
  final String apiKey;

  YouTubeService({required this.apiKey});

  Future<List<dynamic>> searchMusic(String query) async {
    // Append constraints to ensure we only get music/songs and reject status clips
    final enhancedQuery = '$query song -whatsapp -status -bgm -shorts';

    try {
      final response = await _dio.get(
        "https://www.googleapis.com/youtube/v3/search",
        queryParameters: {
          "part": "snippet",
          "q": enhancedQuery,
          "type": "video",
          "videoCategoryId": "10", // Music category only
          "maxResults": 20,
          "key": apiKey,
        },
      );
      
      return response.data["items"] ?? [];
    } catch (e) {
      print('YouTubeService Error for query "$query": $e');
      throw Exception('Failed to load music metadata: $e');
    }
  }

  Future<List<dynamic>> getRelatedSongs(String videoId) async {
    try {
      final response = await _dio.get(
        "https://www.googleapis.com/youtube/v3/search",
        queryParameters: {
          "part": "snippet",
          "relatedToVideoId": videoId,
          "type": "video",
          "videoCategoryId": "10", // Music category only
          "maxResults": 10,
          "key": apiKey,
        },
      );
      
      return response.data["items"];
    } catch (e) {
      throw Exception('Failed to load related music: $e');
    }
  }
}
