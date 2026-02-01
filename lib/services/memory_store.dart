import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/memory.dart';

class MemoryStore {
  // Local cache (used by UI)
  static final List<Memory> _memories = [];

  // Firestore instance
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Expose memories safely
  static List<Memory> get memories =>
      List.unmodifiable(_memories);

  // Add memory locally
  static void addMemory(Memory memory) {
    _memories.insert(0, memory);
  }

  // Delete memory locally
  static void deleteMemory(String id) {
    _memories.removeWhere((memory) => memory.id == id);
  }

  // ☁️ Save memory to Firestore
  static Future<void> saveMemoryToCloud(Memory memory) async {
    await _firestore.collection('memories').doc(memory.id).set({
      'title': memory.title,
      'content': memory.content,
      'createdAt': memory.createdAt,
      'photoPaths': memory.photoPaths,
      'audioPath': memory.audioPath,
    });
  }

  // ☁️ Load memories from Firestore
  static Future<void> loadMemoriesFromCloud() async {
    final snapshot = await _firestore
        .collection('memories')
        .orderBy('createdAt', descending: true)
        .get();

    _memories.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      _memories.add(
        Memory(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt:
              (data['createdAt'] as Timestamp).toDate(),
          photoPaths:
              List<String>.from(data['photoPaths'] ?? []),
          audioPath: data['audioPath'],
        ),
      );
    }
  }
}
