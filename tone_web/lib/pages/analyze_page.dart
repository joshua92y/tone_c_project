import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final _dialogueController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  Future<void> _analyzeTone() async {
    setState(() => _loading = true);

    final dialogueLines = _dialogueController.text.trim().split('\n');
    final uri = Uri.parse('http://localhost:8000/analyze?user_id=test');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"dialogue": dialogueLines}),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes); // 한글 디코딩
        setState(() => _result = jsonDecode(decoded));
        //setState(() => _result = jsonDecode(response.body));
      } else {
        throw Exception('서버 오류: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('분석 실패: $e'),
      ));
    } finally {
      setState(() => _loading = false);
    }
  }

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
            Text("📌 말투 이름: ${_result!['name']}"),
            Text("🎯 톤: ${_result!['tone']}"),
            Text("😊 감정 경향: ${_result!['emotion_tendency']}"),
            Text("📏 격식: ${_result!['formality']}"),
            const SizedBox(height: 8),
            Text("🗣️ 어휘 스타일: ${_result!['vocab_style'].join(', ')}"),
            Text("✍️ 문장 스타일: ${_result!['sentence_style'].join(', ')}"),
            Text("🎉 표현 빈도: ${_result!['expression_freq'].join(', ')}"),
            Text("💬 의도 성향: ${_result!['intent_bias'].join(', ')}"),
            const SizedBox(height: 8),
            Text("📝 비고: ${_result!['notes']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 말투 분석')),
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
