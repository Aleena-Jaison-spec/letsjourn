class Memory {
  final String id;

  // Core content
  final String title;
  final String content;

  // Date
  final DateTime createdAt;

  // Media
  final List<String> photoPaths;
  final String? audioPath;

  Memory({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    List<String>? photoPaths,
    this.audioPath,
  }) : photoPaths = photoPaths ?? [];

  /// ✅ Backward compatibility for HomeScreen
  DateTime get date => createdAt;
}
