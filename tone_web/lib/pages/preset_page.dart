import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PresetPage extends StatefulWidget {
  final String userId;
  const PresetPage({super.key, required this.userId});

  @override
  State<PresetPage> createState() => _PresetPageState();
}

class _PresetPageState extends State<PresetPage> {
  final String hostApiServer = 'https://tonecproject-production.up.railway.app';
  List<String> _presetNames = [];
  String? _selectedPreset;
  Map<String, dynamic>? _presetDetail;
  bool _loading = false;

  final _nameController = TextEditingController();
  final _toneController = TextEditingController();
  final _emotionController = TextEditingController();
  final _formalityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPresetList();
  }

  Future<void> _loadPresetList() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$hostApiServer/presets/${widget.userId}');
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

  Future<void> _loadPresetDetail(String presetName) async {
    setState(() {
      _selectedPreset = presetName;
      _presetDetail = null;
      _loading = true;
    });
    try {
      final uri = Uri.parse('$hostApiServer/presets/${widget.userId}/$presetName');
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

  Future<void> _deletePreset(String presetName) async {
    try {
      final uri = Uri.parse('$hostApiServer/presets/${widget.userId}/$presetName');
      final response = await http.delete(uri);
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제됨')));
        await _loadPresetList();
      } else {
        throw Exception('삭제 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('삭제 오류: $e')));
    }
  }

  Future<void> _savePreset() async {
    final uri = Uri.parse('$hostApiServer/presets/${widget.userId}');
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
        await _loadPresetList();
      } else {
        throw Exception('프리셋 저장 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 오류: $e')));
    }
  }

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
