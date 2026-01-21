import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/error_messages.dart';
import '../record/record_screen.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({
    super.key,
    required this.language, // 'ko' or 'en'
    required this.learnerMode, // 'korean_learner' or 'english_learner'
  });

  final String language;
  final String learnerMode;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final _picker = ImagePicker();
  
  File? _selectedImage;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = ErrorMessages.getApiErrorMessage(
          e,
          isKorean: widget.language == 'ko',
        );
      });
    }
  }

  Future<void> _goToRecord() async {
    if (_selectedImage == null) return;

    // Navigate to RecordScreen with the selected image path
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => RecordScreen(
            language: widget.language,
            learnerMode: widget.learnerMode,
            initialImagePath: _selectedImage!.path,
          ),
        ),
      );
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isKorean = widget.language == 'ko';

    return Scaffold(
      appBar: AppBar(
        title: Text(isKorean ? '이미지 분석' : 'Image Analysis'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instructions
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.image,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isKorean
                              ? '사진을 선택하고 그 사진에 대해 말하면 AI가 피드백을 제공합니다.'
                              : 'Select an image and describe it. AI will provide feedback on your speech.',
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Image preview
                Expanded(
                  child: _selectedImage == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 80,
                                color: colorScheme.onSurface.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isKorean
                                    ? '이미지를 선택해주세요'
                                    : 'Please select an image',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: colorScheme.onSurface
                                          .withOpacity(0.6),
                                    ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white),
                                onPressed: _removeImage,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                Column(
                  children: [
                    // Image selection buttons
                    if (_selectedImage == null) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt),
                              label: Text(isKorean ? '카메라' : 'Camera'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo_library),
                              label: Text(isKorean ? '갤러리' : 'Gallery'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      // Go to record button
                      ElevatedButton.icon(
                        onPressed: _goToRecord,
                        icon: const Icon(Icons.mic, size: 24),
                        label: Text(
                          isKorean ? '녹음 시작' : 'Start Recording',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 20),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 4,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
