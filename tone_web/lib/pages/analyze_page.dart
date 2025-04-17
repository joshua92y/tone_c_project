import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnalyzePage extends StatefulWidget {
  final String userId;
  const AnalyzePage({super.key, required this.userId});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final _dialogueController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  final String hostApiServer = 'https://tonecproject-production.up.railway.app';

  Future<void> _analyzeTone() async {
    setState(() => _loading = true);

    final dialogueLines = _dialogueController.text.trim().split('\n');
    final uri = Uri.parse('$hostApiServer/analyze?user_id=${widget.userId}');

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"dialogue": dialogueLines}),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        setState(() => _result = jsonDecode(decoded));
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
    final r = _result!;
    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("📌 말투 이름: ${r['name']}"),
            Text("🎯 말투 톤: ${r['tone']}"),
            Text("😊 감정 경향: ${r['emotion_tendency']}"),
            Text("📏 격식 수준: ${r['formality']}"),
            const SizedBox(height: 8),
            Text("🗣️ 어휘 스타일: ${_formatList(r['vocab_style'])}"),
            Text("✍ 문장 스타일: ${_formatList(r['sentence_style'])}"),
            Text("📊 표현 빈도: ${_formatList(r['expression_freq'])}"),
            Text("💡 의도 성향: ${_formatList(r['intent_bias'])}"),
            const SizedBox(height: 8),
            Text("👥 관계별 말투:"),
            ..._formatRelationshipList(r['relationship_tendency']),
            const SizedBox(height: 8),
            Text("💬 샘플 문장:"),
            ..._formatListAsWidgets(r['sample_phrases']),
            const SizedBox(height: 8),
            Text("📝 비고: ${r['notes']}"),
            Text("🤖 AI 추천 톤: ${r['ai_recommendation_tone']}"),
          ],
        ),
      ),
    );
  }

  String _formatList(List<dynamic>? list) {
    if (list == null || list.isEmpty) return '-';
    return list.join(', ');
  }

  List<Widget> _formatListAsWidgets(List<dynamic>? list) {
    if (list == null || list.isEmpty) return [Text("-")];
    return list.map((item) => Text("- $item")).toList();
  }

  List<Widget> _formatRelationshipList(List<dynamic>? list) {
    if (list == null || list.isEmpty) return [Text("-")];
    return list.map((item) {
      final context = item['context'];
      final tone = item['tone'];
      return Text("- $context: $tone");
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🧠 말투 분석')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dialogueController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '대화 입력 (한 줄에 한 문장)',
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
            Expanded(child: SingleChildScrollView(child: _buildResultCard())),
          ],
        ),
      ),
    );
  }
}
