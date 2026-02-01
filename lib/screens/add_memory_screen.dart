import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../models/memory.dart';
import '../services/memory_store.dart';

class AddMemoryScreen extends StatefulWidget {
  const AddMemoryScreen({super.key});

  @override
  State<AddMemoryScreen> createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<String> _photoPaths = [];

  final AudioRecorder _recorder = AudioRecorder();

  String? _audioPath;
  bool _isRecording = false;
  bool _isSaving = false;

  // 📸 Pick photos
  Future<void> _pickPhotos() async {
    final images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _photoPaths.addAll(images.map((e) => e.path));
      });
    }
  }

  // 🎙️ Start / Stop recording
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _audioPath = path;
        _isRecording = false;
      });
    } else {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return;

      final dir = await getApplicationDocumentsDirectory();
      final path =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
        ),
        path: path,
      );

      setState(() => _isRecording = true);
    }
  }

  // 💾 Save memory (FIXED)
  Future<void> _saveMemory() async {
    // 🚫 Stop recording if still active
    if (_isRecording) {
      final path = await _recorder.stop();
      _audioPath = path;
      _isRecording = false;
    }

    // 🚫 Nothing to save
    if (_titleController.text.isEmpty &&
        _contentController.text.isEmpty &&
        _photoPaths.isEmpty &&
        _audioPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to save')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final memory = Memory(
      id: const Uuid().v4(),
      title: _titleController.text,
      content: _contentController.text,
      createdAt: DateTime.now(),
      photoPaths: _photoPaths,
      audioPath: _audioPath,
    );

    MemoryStore.addMemory(memory);
    await MemoryStore.saveMemoryToCloud(memory);

    setState(() => _isSaving = false);

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Memory'),
        actions: [
          TextButton(
            onPressed: (_isSaving || _isRecording) ? null : _saveMemory,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 📸 + 🎙️ buttons
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: _pickPhotos,
                ),
                IconButton(
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? Colors.red : null,
                  ),
                  onPressed: _toggleRecording,
                ),
              ],
            ),

            // 📸 Photo preview
            if (_photoPaths.isNotEmpty)
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _photoPaths.map((path) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(path),
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // 🎙️ Audio indicator
            if (_audioPath != null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '🎙️ Voice recorded',
                  style: TextStyle(fontSize: 13),
                ),
              ),

            const SizedBox(height: 12),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: 'Write your memory…',
                  border: InputBorder.none,
                ),
                maxLines: null,
                expands: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
