import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // ⏱️ timeout 처리용

class ConvertPage extends StatefulWidget {
  final String userId;
  const ConvertPage({super.key, required this.userId});

  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  final _textController = TextEditingController();
  String _result = '';
  String _autoPresetName = '';
  bool _loading = false;

  final String hostApiServer = 'https://tonecproject-production.up.railway.app';

  List<String> _presetList = [];
  String? _selectedPreset;

  @override
  void initState() {
    super.initState();
    _fetchPresets();
  }

  Future<void> _fetchPresets() async {
    final userId = widget.userId.trim();
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

  Future<void> _saveToHistory(String convertedText) async {
    final userId = widget.userId.trim();
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

  Future<void> _convertText() async {
    final userId = widget.userId.trim();
    if (_selectedPreset == null || userId.isEmpty) return;

    setState(() => _loading = true);
    final uri = Uri.parse('$hostApiServer/convert/from-preset');
    final requestBody = {
      "user_id": userId,
      "preset_name": _selectedPreset,
      "text": _textController.text.trim(),
    };

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 15)); // ⏱️ 타임아웃 추가

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final convertedText = jsonDecode(decoded)['converted_text'];
        setState(() => _result = convertedText);
        await _saveToHistory(convertedText);
      } else {
        throw Exception('변환 실패 (code: ${response.statusCode})');
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('서버 응답이 지연되고 있습니다. 다시 시도해주세요.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _copyResult() {
    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('결과가 복사되었습니다.')),
    );
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
                final shortened = name.length > 10 ? name.substring(0, 10) + '...' : name;
                return DropdownMenuItem(
                  value: name,
                  child: Text(shortened),
                );
              }).toList(),
              onChanged: _loading
                  ? null
                  : (value) {
                      setState(() => _selectedPreset = value);
                    },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _convertText, // ✅ 로딩 중에는 비활성화
                  child: _loading
                      ? const CircularProgressIndicator()
                      : const Text('변환하기'),
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
                      Text(
                        _result,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _copyResult,
                          icon: const Icon(Icons.copy),
                          label: const Text('복사'),
                        ),
                      )
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
