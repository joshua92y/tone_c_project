import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final String userId = 'joshua';
  final _textController = TextEditingController();
  String _result = '';
  String _autoPresetName = '';
  bool _loading = false;

  List<String> _presetList = [];
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _fetchPresets();
  }

  Future<void> _fetchPresets() async {
    try {
      final uri = Uri.parse('http://localhost:8000/presets/$userId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        setState(() {
          _presetList = List<String>.from(jsonDecode(decoded));
          if (_presetList.isNotEmpty) {
            _selectedPreset = _presetList.first;
          }
        });
      } else {
        throw Exception('프리셋 목록 불러오기 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프리셋 로딩 오류: $e')));
    }
  }

  Future<void> _saveToHistory(String convertedText) async {
    try {
      await http.post(
        Uri.parse('http://localhost:8000/history/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"text": convertedText}),
      );
    } catch (e) {
      debugPrint('히스토리 저장 실패: $e');
    }
  }

  Future<List<String>> _getDialogueContext() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/history/$userId'));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> history = jsonDecode(decoded);
        return history.length >= 5
            ? List<String>.from(history.sublist(history.length - 5))
            : [];
      }
    } catch (e) {
      debugPrint('히스토리 불러오기 실패: $e');
    }
    return [];
  }

  Future<void> _convertText() async {
    if (_selectedPreset == null) return;
    setState(() => _loading = true);

    final uri = Uri.parse('http://localhost:8000/convert/from-preset');
    final requestBody = {
      "user_id": userId,
      "preset_name": _selectedPreset,
      "text": _textController.text.trim(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final convertedText = jsonDecode(decoded)['converted_text'];
        setState(() => _result = convertedText);

        await _saveToHistory(convertedText);
      } else {
        throw Exception('변환 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _autoConvert() async {
    setState(() {
      _loading = true;
      _autoPresetName = '';
    });

    final contextList = await _getDialogueContext();

    final uri = Uri.parse('http://localhost:8000/convert/auto-preset');
    final requestBody = {
      "user_id": userId,
      "text": _textController.text.trim(),
      "dialogue_context": contextList,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final json = jsonDecode(decoded);
        setState(() {
          _result = json['converted_text'];
          _autoPresetName = json['preset_name'];
        });
      } else {
        throw Exception('자동 변환 실패');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🗣️ 말투 변환')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: '변환할 문장 입력',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '프리셋 선택',
                border: OutlineInputBorder(),
              ),
              value: _selectedPreset,
              items: _presetList.map((name) {
                return DropdownMenuItem(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedPreset = value);
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _convertText,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('선택된 프리셋으로 변환'),
                ),
                ElevatedButton(
                  onPressed: _loading ? null : _autoConvert,
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('자동 추천으로 변환'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_autoPresetName.isNotEmpty)
                        Text("🧠 추천된 프리셋: $_autoPresetName",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
