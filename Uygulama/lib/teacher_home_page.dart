import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'teacher_class_list_screen.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  final _classNameController = TextEditingController();

  String _generateClassCode(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (index) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createClass() async {
    final className = _classNameController.text.trim();
    if (className.isEmpty) return;

    final classCode = _generateClassCode(6);
    final teacherId = FirebaseAuth.instance.currentUser!.uid;

    final classDoc = {
      'className': className,
      'classCode': classCode,
      'teacherId': teacherId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection('classes').add(classDoc);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Sınıf oluşturuldu! Kod: $classCode")),
      );
      _classNameController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baykuş - Öğretmen Paneli")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "📚 Yeni Sınıf Oluştur",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _classNameController,
                      decoration: const InputDecoration(
                        labelText: 'Sınıf İsmi',
                        hintText: 'Örn: 10-A',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createClass,
                      icon: const Icon(Icons.add),
                      label: const Text("Sınıf Oluştur"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeacherClassListScreen()),
                );
              },
              icon: const Icon(Icons.view_list),
              label: const Text("Sınıfları Gör"),
            ),
          ],
        ),
      ),
    );
  }
}
