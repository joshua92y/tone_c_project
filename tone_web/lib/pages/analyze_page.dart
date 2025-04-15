import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final _dialogueController = TextEditingController(); // 대화 입력 컨트롤러
  bool _loading = false; // 로딩 상태
  Map<String, dynamic>? _result; // 분석 결과 저장 변수

  final String hostApiServer = 'https://tonecproject-production.up.railway.app'; // 배포된 API 서버 주소

  // 말투 분석 요청 함수
  Future<void> _analyzeTone() async {
    setState(() => _loading = true);

    final dialogueLines = _dialogueController.text.trim().split('\n'); // 대화를 줄 단위로 나눔
    final uri = Uri.parse('$hostApiServer/analyze?user_id=test');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"dialogue": dialogueLines}),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes); // 한글 디코딩
        setState(() => _result = jsonDecode(decoded));
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      // 분석 실패 시 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('분석 실패: $e'),
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

  // 분석 결과 카드 위젯
  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("\u{1F4CC} 말투 이름: ${_result!['name']}"),
            Text("\u{1F3AF} 톤: ${_result!['tone']}"),
            Text("\u{1F60A} 감정 경향: ${_result!['emotion_tendency']}"),
            Text("\u{1F4CF} 격식: ${_result!['formality']}"),
            const SizedBox(height: 8),
            Text("\u{1F5E3}\u{FE0F} 어휘 스타일: ${_result!['vocab_style'].join(', ')}"),
            Text("\u{270D}\u{FE0F} 문장 스타일: ${_result!['sentence_style'].join(', ')}"),
            Text("\u{1F389} 표현 빈도: ${_result!['expression_freq'].join(', ')}"),
            Text("\u{1F4AC} 의도 성향: ${_result!['intent_bias'].join(', ')}"),
            const SizedBox(height: 8),
            Text("\u{1F4DD} 비고: ${_result!['notes']}"),
          ],
        ),
      ),
    );
  }

  // 전체 UI 빌드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u{1F4AC} 말투 분석')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dialogueController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '대화 입력 (한 줄에 한 대화)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _analyzeTone,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('분석하기'),
            ),
            _buildResultCard(),
          ],
        ),
      ),
    );
  }
}
