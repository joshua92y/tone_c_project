import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'preset_page.dart';

class AnalyzePage extends StatefulWidget {
  final String userId;
  const AnalyzePage({super.key, required this.userId});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  final _dialogueController = TextEditingController();
  final _presetNameController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;

  final String hostApiServer = 'https://tonecproject-production.up.railway.app';

  @override
  void dispose() {
    _dialogueController.dispose();
    _presetNameController.dispose();
    super.dispose();
  }

  Future<bool> _checkPresetExists(String name) async {
    try {
      final uri = Uri.parse('$hostApiServer/presets/${widget.userId}/$name');
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _analyzeTone() async {
    final text = _dialogueController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('분석할 대화를 입력해주세요.')),
      );
      return;
    }

    setState(() => _loading = true);
    final dialogueLines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();

    try {
      final uri = Uri.parse('$hostApiServer/analyze?user_id=${widget.userId}');
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('분석 실패: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveAsPreset(String name, Map<String, dynamic> presetData) async {
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋 이름을 입력해주세요.')),
      );
      return;
    }

    // 중복 체크
    final exists = await _checkPresetExists(name);
    if (exists) {
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('프리셋 덮어쓰기'),
          content: Text('이미 "$name" 프리셋이 존재합니다. 덮어쓰시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('덮어쓰기'),
            ),
          ],
        ),
      );
      if (overwrite != true) return;
    }

    try {
      final uri = Uri.parse('$hostApiServer/presets/${widget.userId}');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          ...presetData,
          'name': name,  // 프리셋 이름 추가
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프리셋이 저장되었습니다.')),
        );
        
        // 저장 후 프리셋 페이지로 이동 여부 확인
        final goToPresetPage = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('프리셋 저장 완료'),
            content: const Text('프리셋 목록 페이지로 이동하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('아니오'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('예'),
              ),
            ],
          ),
        );

        if (goToPresetPage == true) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => PresetPage(userId: widget.userId),
            ),
          );
        }
      } else {
        throw Exception('저장 실패: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 오류: $e')),
      );
    }
  }

  Widget _buildResultCard() {
    if (_result == null) return const SizedBox.shrink();
    final r = _result!;

    return Card(
      margin: const EdgeInsets.only(top: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _presetNameController,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: '📌 말투 이름',
                hintText: '저장할 프리셋 이름을 입력하세요',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            _buildResultField('🎯 말투 톤', r['tone']),
            _buildResultField('😊 감정 경향', r['emotion_tendency']),
            _buildResultField('📏 격식 수준', r['formality']),
            const SizedBox(height: 8),
            _buildResultField('🗣️ 어휘 스타일', _formatList(r['vocab_style'])),
            _buildResultField('✍ 문장 스타일', _formatList(r['sentence_style'])),
            _buildResultField('📊 표현 빈도', _formatList(r['expression_freq'])),
            _buildResultField('💡 의도 성향', _formatList(r['intent_bias'])),
            const SizedBox(height: 8),
            _buildSectionTitle('👥 관계별 말투'),
            ..._formatRelationshipList(r['relationship_tendency']),
            const SizedBox(height: 8),
            _buildSectionTitle('💬 샘플 문장'),
            ..._formatListAsWidgets(r['sample_phrases']),
            const SizedBox(height: 8),
            _buildResultField('📝 비고', r['notes']),
            _buildResultField('🤖 AI 추천 톤', r['ai_recommendation_tone']),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('프리셋으로 저장'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _saveAsPreset(_presetNameController.text.trim(), r),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildResultField(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
          ),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(
              text: value ?? '-',
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
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
    if (list == null || list.isEmpty) return [const Text('- 없음')];
    return list.map((item) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '• $item',
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black54,
        ),
      ),
    )).toList();
  }

  List<Widget> _formatRelationshipList(List<dynamic>? list) {
    if (list == null || list.isEmpty) return [const Text('- 없음')];
    return list.map((item) {
      final context = item['context'];
      final tone = item['tone'];
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          '• $context: $tone',
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black54,
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 말투 분석'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _dialogueController,
              maxLines: 6,
              style: const TextStyle(fontSize: 16),
              decoration: const InputDecoration(
                labelText: '대화 입력',
                hintText: '분석할 대화를 한 줄에 한 문장씩 입력하세요.',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _analyzeTone,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
              ),
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('분석하기'),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: _buildResultCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
