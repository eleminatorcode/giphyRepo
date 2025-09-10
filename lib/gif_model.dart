class GifData {
  late final String id;
  late final String title;
  late final String previewUrl;
  late final String originalUrl;

  GifData({
    required this.id,
    required this.title,
    required this.previewUrl,
    required this.originalUrl,
  });

  factory GifData.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as Map<String, dynamic>;
    final fixed = images['fixed_width'] ?? images['preview_gif'] ?? images['original'];
    final original = images['original'];
    return GifData(
      id: json['id'] as String,
      title: (json['title'] as String?)?.trim().isNotEmpty == true ? json['title'] as String : 'GIF',
      previewUrl: (fixed['url'] as String?) ?? (original['url'] as String),
      originalUrl: original['url'] as String,
    );
  }
}
