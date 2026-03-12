import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLanguage {
  final String label;
  final String flag;
  final String trendingQuery;
  final String recommendedQuery;
  final String newReleasesQuery;
  final String topArtistsQuery;
  final String focusQuery;

  const AppLanguage({
    required this.label,
    required this.flag,
    required this.trendingQuery,
    required this.recommendedQuery,
    required this.newReleasesQuery,
    required this.topArtistsQuery,
    required this.focusQuery,
  });
}

const List<AppLanguage> availableLanguages = [
  AppLanguage(
    label: 'Tamil',
    flag: '🎵',
    trendingQuery: 'tamil trending songs 2024',
    recommendedQuery: 'tamil hits music',
    newReleasesQuery: 'latest tamil video songs 2024',
    topArtistsQuery: 'anirudh ar rahman tamil hits',
    focusQuery: 'tamil melody lofi relax',
  ),
  AppLanguage(
    label: 'Hindi',
    flag: '🎵',
    trendingQuery: 'hindi trending songs 2024',
    recommendedQuery: 'bollywood hits music',
    newReleasesQuery: 'new bollywood songs 2024',
    topArtistsQuery: 'arijit singh shreya ghoshal hits',
    focusQuery: 'hindi lofi chill study',
  ),
  AppLanguage(
    label: 'Telugu',
    flag: '🎵',
    trendingQuery: 'telugu trending songs 2024',
    recommendedQuery: 'telugu hits music',
    newReleasesQuery: 'latest telugu hit songs 2024',
    topArtistsQuery: 'dsp thaman anirudh telugu hits',
    focusQuery: 'telugu lofi chill melody',
  ),
  AppLanguage(
    label: 'Malayalam',
    flag: '🎵',
    trendingQuery: 'malayalam trending songs 2024',
    recommendedQuery: 'malayalam hits music',
    newReleasesQuery: 'new malayalam songs 2024',
    topArtistsQuery: 'sushin shyam hesham abdul wahab hits',
    focusQuery: 'malayalam lofi chill melody',
  ),
  AppLanguage(
    label: 'Kannada',
    flag: '🎵',
    trendingQuery: 'kannada trending songs 2024',
    recommendedQuery: 'kannada hits music',
    newReleasesQuery: 'latest kannada songs 2024',
    topArtistsQuery: 'kalyan nayak kannada hits',
    focusQuery: 'kannada lofi chill',
  ),
  AppLanguage(
    label: 'English',
    flag: '🎵',
    trendingQuery: 'english trending songs 2024',
    recommendedQuery: 'english pop hits music',
    newReleasesQuery: 'new pop music 2024',
    topArtistsQuery: 'taylor swift weeknd pop hits',
    focusQuery: 'english lofi hip hop study beat',
  ),
  AppLanguage(
    label: 'Punjabi',
    flag: '🎵',
    trendingQuery: 'punjabi trending songs 2024',
    recommendedQuery: 'punjabi hits music',
    newReleasesQuery: 'latest punjabi songs 2024',
    topArtistsQuery: 'karan aujla diljit dosanjh hits',
    focusQuery: 'punjabi lofi chill drive',
  ),
  AppLanguage(
    label: 'Bengali',
    flag: '🎵',
    trendingQuery: 'bengali trending songs 2024',
    recommendedQuery: 'bengali hits music',
    newReleasesQuery: 'latest bengali songs 2024',
    topArtistsQuery: 'arijit singh bengali hits',
    focusQuery: 'bengali lofi chill acoustic',
  ),
];

class LanguageNotifier extends Notifier<AppLanguage> {
  @override
  AppLanguage build() => availableLanguages[0]; // default: Tamil

  void setLanguage(AppLanguage lang) {
    state = lang;
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, AppLanguage>(LanguageNotifier.new);
