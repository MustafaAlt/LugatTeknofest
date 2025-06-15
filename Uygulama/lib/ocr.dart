import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'text_classifier_screen.dart';

class QuestionAnalysisScreen extends StatefulWidget {
  const QuestionAnalysisScreen({super.key});

  @override
  State<QuestionAnalysisScreen> createState() => _QuestionAnalysisScreenState();
}

class _QuestionAnalysisScreenState extends State<QuestionAnalysisScreen> {
  File? _imageFile;
  String _extractedText = '';

  Future<void> _pickCropAndRecognize() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sorunun Kenarlarını Kırp',
            toolbarColor: Colors.deepPurple,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
        ],
      );

      if (croppedFile == null) return;

      final safeFile = File(croppedFile.path);

      setState(() {
        _imageFile = safeFile;
        _extractedText = 'Metin analiz ediliyor...';
      });

      await _performOCR(safeFile);
    } catch (e) {
      setState(() {
        _extractedText = 'Bir hata oluştu: $e';
      });
    }
  }

  Future<void> _performOCR(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final recognized = await recognizer.processImage(inputImage);

      setState(() {
        _extractedText = recognized.text;
      });

      recognizer.close();
    } catch (e) {
      setState(() {
        _extractedText = 'OCR Hatası: $e';
      });
    }
  }

  void _copyToClipboard() {
    if (_extractedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _extractedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Metin panoya kopyalandı')),
      );
    }
  }

  Widget buildGradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)], // mor tonlar
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text('🦉 Baykuş - Soru Analizi'),
        centerTitle: true,
        backgroundColor: const Color(0xFF512DA8),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "📸 1. Sorunun Fotoğrafını Çek",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF311B92),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(_imageFile!, height: 250, fit: BoxFit.cover),
                  )
                : Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: const Center(
                      child: Text(
                        "Hiç fotoğraf çekilmedi.",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            buildGradientButton(
              text: "Fotoğraf Çek & Kırp",
              icon: Icons.camera_alt_outlined,
              onPressed: _pickCropAndRecognize,
            ),
            const SizedBox(height: 30),
            const Text(
              "📝 2. Çıkarılan Metin",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF311B92),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _extractedText.isEmpty
                    ? "Fotoğrafı çekip burada metni görebilirsiniz."
                    : _extractedText,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 20),
            buildGradientButton(
              text: "Metni Kopyala",
              icon: Icons.copy_rounded,
              onPressed: _copyToClipboard,
            ),
            buildGradientButton(
              text: "Sınıflandırıcıya Gönder",
              icon: Icons.send_rounded,
              onPressed: () {
                if (_extractedText.isNotEmpty) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TextClassifierScreen(initialText: _extractedText),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Önce bir metin çıkarmalısınız!")),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
