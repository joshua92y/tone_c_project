// ✅ 앱 진입점: main.dart
import 'package:flutter/material.dart';
import 'pages/home_page.dart';         // 홈 화면 (사용자 선택 및 기능 진입)
import 'pages/history_page.dart';      // 히스토리 화면 (기본 라우트 등록)

void main() {
  runApp(const MyApp()); // 앱 실행 시작
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 앱 전체 설정 및 초기 화면 정의
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tone_C', // 앱 제목
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // 테마 색상
        useMaterial3: true, // Material 3 사용
      ),
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      home: const HomePage(), // 앱 실행 시 진입할 첫 화면 (사용자 선택 포함)
      routes: {
        '/history': (context) => const HistoryPage(), // 히스토리 페이지 라우트 등록
        // ⚠️ ConvertPage 및 AnalyzePage는 파라미터(userId)를 받아야 하므로
        // Navigator.push(MaterialPageRoute(...)) 방식으로만 이동해야 함
      },
    );
  }
}
