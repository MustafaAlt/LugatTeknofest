import 'package:flutter/material.dart';

class StudentDetailScreen extends StatelessWidget {
  final String uid;
  const StudentDetailScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Baykuş - Öğrenci Detayı")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "📋 Öğrenci Rapor Kartı",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.account_circle, size: 40, color: Colors.indigo),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Öğrenci ID:", style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(uid, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        )
                      ],
                    ),
                    const Divider(height: 32),
                    const Text(
                      "📊 Raporlar ve performans detayları burada görüntülenecek.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("🛠️ Geliştirilecek...")),
                );
              },
              icon: const Icon(Icons.analytics),
              label: const Text("Analiz Paneli (Yakında)"),
            ),
          ],
        ),
      ),
    );
  }
}
