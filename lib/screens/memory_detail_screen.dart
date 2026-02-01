import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/memory.dart';
import '../services/memory_store.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;

  Future<void> _toggleAudio() async {
    if (widget.memory.audioPath == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(
        DeviceFileSource(widget.memory.audioPath!),
      );
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memory = widget.memory;

    return Scaffold(
      appBar: AppBar(
        title: Text(memory.title.isEmpty ? 'Memory' : memory.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              MemoryStore.deleteMemory(memory.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📅 Date
            Text(
              memory.createdAt.toLocal().toString().split(' ')[0],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 16),

            // 📸 Photos
            if (memory.photoPaths.isNotEmpty)
              SizedBox(
                height: 140,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: memory.photoPaths.map((path) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(path),
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            if (memory.photoPaths.isNotEmpty)
              const SizedBox(height: 20),

            // ✍️ Text
            if (memory.content.isNotEmpty)
              Text(
                memory.content,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),

            const SizedBox(height: 24),

            // 🎙️ AUDIO PLAYER UI
            if (memory.audioPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 28,
                      ),
                      onPressed: _toggleAudio,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Voice memory',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
