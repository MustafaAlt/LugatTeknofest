import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/ocr.dart';
import 'student_classes_screen.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  final _classCodeController = TextEditingController();

  Future<void> _joinClass() async {
    final classCode = _classCodeController.text.trim();
    final studentId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final query = await FirebaseFirestore.instance
          .collection('classes')
          .where('classCode', isEqualTo: classCode)
          .get();

      if (query.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Böyle bir sınıf bulunamadı.")),
        );
        return;
      }

      final classDoc = query.docs.first;
      final classId = classDoc.id;

      await FirebaseFirestore.instance.collection('students_in_class').add({
        'studentId': studentId,
        'classId': classId,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 Sınıfa başarıyla katıldınız!")),
      );

      _classCodeController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baykuş - Öğrenci Paneli")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "🦉 Hoş geldin Baykuş Öğrencisi!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _classCodeController,
              decoration: const InputDecoration(
                labelText: 'Sınıf Kodu Gir',
                hintText: 'Örnek: ABC123',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _joinClass,
              icon: const Icon(Icons.group_add),
              label: const Text("Sınıfa Katıl"),
            ),
            const Divider(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentClassesScreen()),
                );
              },
              icon: const Icon(Icons.class_),
              label: const Text("Katıldığım Sınıflar"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const QuestionAnalysisScreen()),
    );
  },
  icon: const Icon(Icons.bar_chart),
  label: const Text("Soru Analizi"),
),
          ],
        ),
      ),
    );
  }
}
