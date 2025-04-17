import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'analyze_page.dart';
import 'preset_page.dart';
import 'convert_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userController = TextEditingController();
  String? _selectedUser;
  List<String> _userIds = [];
  final String hostApiServer = 'https://tonecproject-production.up.railway.app';

  @override
  void initState() {
    super.initState();
    _fetchUserIds();
  }

  Future<void> _fetchUserIds() async {
    try {
      final uri = Uri.parse('$hostApiServer/user-ids');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        setState(() {
          _userIds = List<String>.from(jsonDecode(decoded));
        });
      } else {
        throw Exception('유저 목록 불러오기 실패');
      }
    } catch (e) {
      debugPrint('유저 목록 로딩 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('💬 말투 분석 시스템')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                return _userIds.where((id) => id.contains(textEditingValue.text));
              },
              onSelected: (value) => _userController.text = value,
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                controller.addListener(() {
                  _userController.text = controller.text;
                });
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: '사용자 ID 입력 또는 선택',
                    border: OutlineInputBorder(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final enteredId = _userController.text.trim();
                if (!_userIds.contains(enteredId)) {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('신규 사용자'),
                      content: Text('사용자 "${_userController.text.trim()}"는 존재하지 않습니다. 추가하시겠습니까?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('취소'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('확인'),
                        ),
                      ],
                    ),
                  );
                  if (confirm != true) return;
                  setState(() => _userIds.add(enteredId));
                }
                setState(() => _selectedUser = enteredId);
              },
              child: const Text('사용자 선택'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('말투 분석하기'),
              onPressed: userId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnalyzePage(userId: userId),
                        ),
                      );
                    },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync_alt),
              label: const Text('말투 변환'),
              onPressed: userId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConvertPage(userId: userId),
                        ),
                      );
                    },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.library_books),
              label: const Text('프리셋 관리'),
              onPressed: userId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PresetPage(userId: userId),
                        ),
                      );
                    },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.history),
              label: const Text('히스토리 보기'),
              onPressed: () {
                Navigator.pushNamed(context, '/history');
              },
            ),
          ],
        ),
      ),
    );
  }
}
