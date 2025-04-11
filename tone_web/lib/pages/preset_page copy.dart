import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PresetPage extends StatefulWidget {
  const PresetPage({super.key});

  @override
  State<PresetPage> createState() => _PresetPageState();
}

class _PresetPageState extends State<PresetPage> {
  final String userId = 'joshua'; // 임시 사용자 ID
  List<String> _presetNames = [];
  String? _selectedPreset;
  Map<String, dynamic>? _presetDetail;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadPresetList();
  }

  Future<void> _loadPresetList() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('http://localhost:8000/presets/$userId');
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
      final uri = Uri.parse('http://localhost:8000/presets/$userId/$presetName');
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
      final uri = Uri.parse('http://localhost:8000/presets/$userId/$presetName');
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
            Text("📌 이름: ${_presetDetail!['name']}"),
            Text("🎯 톤: ${_presetDetail!['tone']}"),
            Text("😊 감정: ${_presetDetail!['emotion_tendency']}"),
            Text("📏 격식: ${_presetDetail!['formality']}"),
            const SizedBox(height: 6),
            Text("🗣️ 어휘 스타일: ${_presetDetail!['vocab_style'].join(', ')}"),
          ],
        ),
      ),
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
                  ],
                ),
              ),
      ),
    );
  }
}
