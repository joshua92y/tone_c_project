import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PresetPage extends StatefulWidget {
  const PresetPage({super.key});

  @override
  State<PresetPage> createState() => _PresetPageState();
}

class _PresetPageState extends State<PresetPage> {
  // 사용자 ID와 API 서버 주소
  final String userId = 'joshua';
  final String hostApiServer = 'https://tonecproject-production.up.railway.app';

  // 상태 변수들
  List<String> _presetNames = []; // 프리셋 이름 목록
  String? _selectedPreset; // 현재 선택된 프리셋 이름
  Map<String, dynamic>? _presetDetail; // 선택된 프리셋 상세정보
  bool _loading = false; // 로딩 상태 여부

  // 입력 필드 컨트롤러
  final _nameController = TextEditingController();
  final _toneController = TextEditingController();
  final _emotionController = TextEditingController();
  final _formalityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPresetList(); // 위젯이 시작될 때 프리셋 목록을 불러옴
  }

  // 프리셋 목록 불러오기
  Future<void> _loadPresetList() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$hostApiServer/presets/$userId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        setState(() {
          _presetNames = List<String>.from(jsonDecode(decoded));
        });
      } else {
        throw Exception('불러오기 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  // 프리셋 상세 정보 불러오기
  Future<void> _loadPresetDetail(String presetName) async {
    setState(() {
      _selectedPreset = presetName;
      _presetDetail = null;
      _loading = true;
    });

    try {
      final uri = Uri.parse('$hostApiServer/presets/$userId/$presetName');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        setState(() {
          _presetDetail = jsonDecode(decoded);
        });
      } else {
        throw Exception('상세 불러오기 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  // 프리셋 삭제하기
  Future<void> _deletePreset(String presetName) async {
    try {
      final uri = Uri.parse('$hostApiServer/presets/$userId/$presetName');
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제됨')));
        await _loadPresetList(); // 삭제 후 목록 다시 불러오기
      } else {
        throw Exception('삭제 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 오류: $e')));
    }
  }

  // 프리셋 저장하기
  Future<void> _savePreset() async {
    final uri = Uri.parse('$hostApiServer/presets/$userId');

    final presetData = {
      "name": _nameController.text.trim(),
      "tone": _toneController.text.trim(),
      "emotion_tendency": _emotionController.text.trim(),
      "formality": _formalityController.text.trim(),
      "vocab_style": [],
      "sentence_style": [],
      "expression_freq": [],
      "intent_bias": [],
      "relationship_tendency": [],
      "sample_phrases": [],
      "notes": "",
      "ai_recommendation_tone": ""
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(presetData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프리셋 저장 완료')));
        await _loadPresetList(); // 저장 후 목록 새로고침
      } else {
        throw Exception('프리셋 저장 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 오류: $e')));
    }
  }

  // 프리셋 목록 UI 구성
  Widget _buildPresetList() {
    if (_presetNames.isEmpty) return const Text('프리셋이 없습니다.');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _presetNames.map((name) {
        return ListTile(
          title: Text(name),
          onTap: () => _loadPresetDetail(name),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deletePreset(name),
          ),
        );
      }).toList(),
    );
  }

  // 프리셋 상세 UI 구성
  Widget _buildPresetDetail() {
    if (_presetDetail == null) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("\u{1F4CC} 이름: ${_presetDetail!['name']}"),
            Text("\u{1F3AF} 톤: ${_presetDetail!['tone']}"),
            Text("\u{1F60A} 감정: ${_presetDetail!['emotion_tendency']}"),
            Text("\u{1F4CF} 격식: ${_presetDetail!['formality']}"),
            const SizedBox(height: 6),
            Text("\u{1F5E3}\u{FE0F} 어휘 스타일: ${_presetDetail!['vocab_style'].join(', ')}"),
          ],
        ),
      ),
    );
  }

  // 전체 UI 구성
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('\u{1F4DA} 프리셋 관리')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPresetList(),
                    _buildPresetDetail(),
                    const Divider(),
                    const Text("\u{1F4E5} 프리셋 새로 저장"),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: '프리셋 이름'),
                    ),
                    TextField(
                      controller: _toneController,
                      decoration: InputDecoration(labelText: '말투 톤 예: 정중한'),
                    ),
                    TextField(
                      controller: _emotionController,
                      decoration: InputDecoration(labelText: '감정 경향 예: 긍정적'),
                    ),
                    TextField(
                      controller: _formalityController,
                      decoration: InputDecoration(labelText: '격식 예: 높음'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('프리셋 저장'),
                      onPressed: _savePreset,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}