import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_detail_screen.dart';

class StudentListScreen extends StatelessWidget {
  final String classId;
  const StudentListScreen({super.key, required this.classId});

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    final studentsQuery = await FirebaseFirestore.instance
        .collection('students_in_class')
        .where('classId', isEqualTo: classId)
        .get();

    final studentList = <Map<String, dynamic>>[];

    for (var doc in studentsQuery.docs) {
      final studentId = doc['studentId'];
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(studentId).get();

      if (userDoc.exists) {
        studentList.add({
          'uid': studentId,
          'email': userDoc['email'],
          'role': userDoc['role'],
        });
      }
    }

    return studentList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Baykuş - Sınıf Öğrencileri"),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("📊 Sınıf raporları yakında!")),
              );
            },
            icon: const Icon(Icons.bar_chart),
            tooltip: "Sınıf Raporu",
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStudents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "📭 Bu sınıfta henüz öğrenci yok.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final students = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final student = students[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(student['email'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Rol: ${student['role']}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentDetailScreen(uid: student['uid']),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
