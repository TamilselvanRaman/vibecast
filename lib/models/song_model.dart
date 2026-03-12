class Song {
  final String title;
  final String thumbnail;
  final String videoId;
  final String channel;

  Song({
    required this.title,
    required this.thumbnail,
    required this.videoId,
    required this.channel,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json["snippet"]["title"] ?? "Unknown Title",
      thumbnail: json["snippet"]["thumbnails"]?["high"]?["url"] ?? "",
      videoId: json["id"]["videoId"] ?? "",
      channel: json["snippet"]["channelTitle"] ?? "Unknown Artist",
    );
  }
}
