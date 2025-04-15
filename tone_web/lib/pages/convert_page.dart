import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final String userId = 'joshua'; // 사용자 ID
  final String hostApiServer = 'https://tonecproject-production.up.railway.app'; // 배포된 API 서버 주소

  final _textController = TextEditingController(); // 입력 텍스트 컨트롤러
  String _result = ''; // 변환 결과 텍스트
  String _autoPresetName = ''; // 자동 추천된 프리셋 이름
  bool _loading = false; // 로딩 여부

  List<String> _presetList = []; // 프리셋 목록
  String? _selectedPreset; // 선택된 프리셋 이름

  @override
  void initState() {
    super.initState();
    _fetchPresets(); // 프리셋 목록 로딩
  }

  // 프리셋 목록 불러오기
  Future<void> _fetchPresets() async {
    try {
      final uri = Uri.parse('$hostApiServer/presets/$userId');
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

  // 변환 결과를 히스토리에 저장
  Future<void> _saveToHistory(String convertedText) async {
    try {
      await http.post(
        Uri.parse('$hostApiServer/history/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"text": convertedText}),
      );
    } catch (e) {
      debugPrint('히스토리 저장 실패: $e');
    }
  }

  // 최근 대화 히스토리 가져오기 (자동 추천용)
  Future<List<String>> _getDialogueContext() async {
    try {
      final response = await http.get(Uri.parse('$hostApiServer/history/$userId'));
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

  // 선택된 프리셋으로 변환 요청
  Future<void> _convertText() async {
    if (_selectedPreset == null) return;
    setState(() => _loading = true);

    final uri = Uri.parse('$hostApiServer/convert/from-preset');
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

  // 자동 추천 프리셋으로 변환 요청
  Future<void> _autoConvert() async {
    setState(() {
      _loading = true;
      _autoPresetName = '';
    });

    final contextList = await _getDialogueContext();

    final uri = Uri.parse('$hostApiServer/convert/auto-preset');
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

  // UI 구성
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
                        Text("\u{1F9E0} 추천된 프리셋: $_autoPresetName",
                            style: const TextStyle(fontWeight: FontWeight.bold)),
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
