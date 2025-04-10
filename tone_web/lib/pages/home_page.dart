import 'package:flutter/material.dart';
import 'analyze_page.dart';
import 'preset_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 말투 분석 시스템')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('말투 분석하기'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AnalyzePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync_alt),
              label: const Text('말투 변환'),
              onPressed: () {
                Navigator.pushNamed(context, '/convert'); // ✅ 라우트 사용
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.library_books),
              label: const Text('프리셋 관리'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PresetPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('히스토리 보기'),
              onPressed: () {
                Navigator.pushNamed(context, '/history'); // ✅ 라우트 사용
              },
            ),
          ],
        ),
      ),
    );
  }
}
