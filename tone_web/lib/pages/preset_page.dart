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
  final _vocabController = TextEditingController();
  final _sentenceController = TextEditingController();
  final _expressionController = TextEditingController();
  final _intentController = TextEditingController();
  final _notesController = TextEditingController();
  final _aiToneController = TextEditingController();

  final _newPresetControllers = {
    'name': TextEditingController(),
    'tone': TextEditingController(),
    'emotion': TextEditingController(),
    'formality': TextEditingController(),
    'vocab': TextEditingController(),
    'sentence': TextEditingController(),
    'expression': TextEditingController(),
    'intent': TextEditingController(),
    'notes': TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    _loadPresetList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _toneController.dispose();
    _emotionController.dispose();
    _formalityController.dispose();
    _vocabController.dispose();
    _sentenceController.dispose();
    _expressionController.dispose();
    _intentController.dispose();
    _notesController.dispose();
    _aiToneController.dispose();

    _newPresetControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _clearNewPresetControllers() {
    _newPresetControllers.values.forEach((controller) => controller.clear());
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
        final data = jsonDecode(decoded);
        setState(() {
          _presetDetail = data;
          _nameController.text = data['name'] ?? '';
          _toneController.text = data['tone'] ?? '';
          _emotionController.text = data['emotion_tendency'] ?? '';
          _formalityController.text = data['formality'] ?? '';
          _vocabController.text = (data['vocab_style'] as List).join(', ');
          _sentenceController.text = (data['sentence_style'] as List).join(', ');
          _expressionController.text = (data['expression_freq'] as List).join(', ');
          _intentController.text = (data['intent_bias'] as List).join(', ');
          _notesController.text = data['notes'] ?? '';
          _aiToneController.text = data['ai_recommendation_tone'] ?? '';
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

  Future<bool> _checkPresetExists(String name) async {
    try {
      final uri = Uri.parse('$hostApiServer/presets/${widget.userId}/$name');
      final response = await http.get(uri);
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _savePreset({bool isNew = false, Map<String, TextEditingController>? controllers}) async {
    final effectiveControllers = controllers ?? {
      'name': _nameController,
      'tone': _toneController,
      'emotion': _emotionController,
      'formality': _formalityController,
      'vocab': _vocabController,
      'sentence': _sentenceController,
      'expression': _expressionController,
      'intent': _intentController,
      'notes': _notesController,
    };

    final name = effectiveControllers['name']!.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프리셋 이름을 입력해주세요.')),
      );
      return;
    }

    if (isNew || (name != _selectedPreset)) {
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
    }

    final uri = Uri.parse('$hostApiServer/presets/${widget.userId}');
    final presetData = {
      "name": name,
      "tone": effectiveControllers['tone']!.text.trim(),
      "emotion_tendency": effectiveControllers['emotion']!.text.trim(),
      "formality": effectiveControllers['formality']!.text.trim(),
      "vocab_style": effectiveControllers['vocab']!.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "sentence_style": effectiveControllers['sentence']!.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "expression_freq": effectiveControllers['expression']!.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "intent_bias": effectiveControllers['intent']!.text.trim().split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      "relationship_tendency": [],
      "sample_phrases": [],
      "notes": effectiveControllers['notes']!.text.trim(),
    };

    if (!isNew) {
      presetData["ai_recommendation_tone"] = _aiToneController.text.trim();
    }

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(presetData),
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${isNew ? "새 프리셋이" : "프리셋이"} 저장되었습니다.')),
        );
        if (isNew) {
          _clearNewPresetControllers();
          Navigator.pop(context);
        }
        await _loadPresetList();
      } else {
        throw Exception('저장 실패 (${response.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 오류: $e')),
      );
    }
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
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: '프리셋 이름')),
            TextField(controller: _toneController, decoration: const InputDecoration(labelText: '말투 톤')),
            TextField(controller: _emotionController, decoration: const InputDecoration(labelText: '감정 경향')),
            TextField(controller: _formalityController, decoration: const InputDecoration(labelText: '격식 수준')),
            TextField(controller: _vocabController, decoration: const InputDecoration(labelText: '어휘 스타일 (콤마 구분)')),
            TextField(controller: _sentenceController, decoration: const InputDecoration(labelText: '문장 스타일 (콤마 구분)')),
            TextField(controller: _expressionController, decoration: const InputDecoration(labelText: '표현 빈도 (콤마 구분)')),
            TextField(controller: _intentController, decoration: const InputDecoration(labelText: '의도 성향 (콤마 구분)')),
            TextField(controller: _notesController, decoration: const InputDecoration(labelText: '비고')),
            TextField(
              controller: _aiToneController,
              decoration: const InputDecoration(labelText: 'AI 추천 톤'),
              enabled: false,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('프리셋 수정 저장'),
              onPressed: () => _savePreset(isNew: false),
            ),
          ],
        ),
      ),
    );
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
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('프리셋 삭제 확인'),
                  content: Text('정말 "$name" 프리셋을 삭제하시겠습니까?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('삭제')),
                  ],
                ),
              );
              if (confirm == true) {
                await _deletePreset(name);
                if (_selectedPreset == name) {
                  setState(() {
                    _selectedPreset = null;
                    _presetDetail = null;
                  });
                }
              }
            },
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📚 프리셋 관리')),
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
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('새 프리셋 저장'),
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('새 프리셋 생성'),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: _newPresetControllers['name'],
                                    decoration: const InputDecoration(labelText: '프리셋 이름'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['tone'],
                                    decoration: const InputDecoration(labelText: '말투 톤'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['emotion'],
                                    decoration: const InputDecoration(labelText: '감정 경향'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['formality'],
                                    decoration: const InputDecoration(labelText: '격식 수준'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['vocab'],
                                    decoration: const InputDecoration(labelText: '어휘 스타일 (콤마 구분)'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['sentence'],
                                    decoration: const InputDecoration(labelText: '문장 스타일 (콤마 구분)'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['expression'],
                                    decoration: const InputDecoration(labelText: '표현 빈도 (콤마 구분)'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['intent'],
                                    decoration: const InputDecoration(labelText: '의도 성향 (콤마 구분)'),
                                  ),
                                  TextField(
                                    controller: _newPresetControllers['notes'],
                                    decoration: const InputDecoration(labelText: '비고'),
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  _clearNewPresetControllers();
                                  Navigator.pop(context);
                                },
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => _savePreset(
                                  isNew: true,
                                  controllers: _newPresetControllers,
                                ),
                                child: const Text('저장'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
