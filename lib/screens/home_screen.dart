import 'dart:io';

import 'package:flutter/material.dart';
import '../models/memory.dart';
import '../services/memory_store.dart';
import 'add_memory_screen.dart';
import 'memory_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final List<Memory> memories = MemoryStore.memories.reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Diary',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: memories.isEmpty
          ? const Center(
              child: Text(
                'No memories yet 🌸\nTap + to begin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, height: 1.6),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                final hasPhoto = memory.photoPaths.isNotEmpty;

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MemoryDetailScreen(memory: memory),
                      ),
                    ).then((_) => setState(() {}));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFDF7),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📸 Polaroid photo with tape
                        if (hasPhoto)
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    10, 10, 10, 22),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(memory.photoPaths.first),
                                    height: 220,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                              // 📌 Left tape
                              const Positioned(
                                top: -10,
                                left: 24,
                                child: _Tape(),
                              ),

                              // 📌 Right tape
                              const Positioned(
                                top: -10,
                                right: 24,
                                child: _Tape(),
                              ),
                            ],
                          ),

                        const SizedBox(height: 14),

                        // ✍️ Handwritten diary text
                        Text(
                          memory.content.isNotEmpty
                              ? memory.content
                              : '(No text)',
                          style: const TextStyle(
                            fontFamily: 'DiaryFont',
                            fontSize: 18,
                            height: 1.7,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // 📅 Date
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Text(
                            memory.createdAt
                                .toLocal()
                                .toString()
                                .split(' ')[0],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }
}

/// 📌 Tape decoration widget
class _Tape extends StatelessWidget {
  const _Tape();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.12,
      child: Container(
        width: 50,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFFFE4A1),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
