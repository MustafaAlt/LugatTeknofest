import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StudentClassesScreen extends StatefulWidget {
  const StudentClassesScreen({super.key});

  @override
  State<StudentClassesScreen> createState() => _StudentClassesScreenState();
}

class _StudentClassesScreenState extends State<StudentClassesScreen> {
  late final String studentId;

  @override
  void initState() {
    super.initState();
    studentId = FirebaseAuth.instance.currentUser!.uid;
  }

  Future<List<Map<String, dynamic>>> _fetchJoinedClasses() async {
    final joinQuery = await FirebaseFirestore.instance
        .collection('students_in_class')
        .where('studentId', isEqualTo: studentId)
        .get();

    final classList = <Map<String, dynamic>>[];

    for (var joinDoc in joinQuery.docs) {
      final classId = joinDoc['classId'];

      final classDoc = await FirebaseFirestore.instance.collection('classes').doc(classId).get();
      if (!classDoc.exists) continue;

      final teacherId = classDoc['teacherId'];
      final teacherDoc = await FirebaseFirestore.instance.collection('users').doc(teacherId).get();

      classList.add({
        'className': classDoc['className'],
        'classCode': classDoc['classCode'],
        'teacherEmail': teacherDoc.exists ? teacherDoc['email'] : 'Bilinmiyor',
      });
    }

    return classList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baykuş - Katıldığım Sınıflar")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchJoinedClasses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "🦉 Henüz bir sınıfa katılmadınız.\nBir sınıf kodu ile katılmayı deneyin.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final classes = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: classes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final cls = classes[index];

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(cls['className'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("📘 Sınıf Kodu: ${cls['classCode']}"),
                      Text("👨‍🏫 Öğretmen: ${cls['teacherEmail']}"),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
