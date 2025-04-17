import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'analyze_page.dart';
import 'preset_page.dart';
import 'convert_page.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _userController = TextEditingController();
  List<String> _userIds = [];
  bool _loading = false;
  bool _isUserSelected = false;
  final String hostApiServer = 'https://tonecproject-production.up.railway.app';

  @override
  void initState() {
    super.initState();
    _fetchUserIds();
  }

  @override
  void dispose() {
    _userController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserIds() async {
    setState(() => _loading = true);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('유저 목록 로딩 오류: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleUserSelection(String userId) async {
    if (!_userIds.contains(userId)) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('신규 사용자'),
          content: Text('사용자 "$userId"가 존재하지 않습니다. 추가하시겠습니까?'),
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
      if (confirm == true) {
        setState(() {
          _userIds.add(userId);
          _isUserSelected = true;
        });
      } else {
        _userController.clear();
        setState(() => _isUserSelected = false);
        return;
      }
    } else {
      setState(() => _isUserSelected = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 말투 분석 시스템'),
        actions: [
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return _userIds;
                      }
                      return _userIds.where((id) => 
                        id.toLowerCase().contains(textEditingValue.text.toLowerCase())
                      );
                    },
                    onSelected: (value) {
                      _userController.text = value;
                      _handleUserSelection(value);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _userController.text = value;
                            _handleUserSelection(value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: '사용자 ID 입력 또는 선택',
                          hintText: '입력 후 Enter 또는 목록에서 선택',
                          border: const OutlineInputBorder(),
                          suffixIcon: controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.clear();
                                    _userController.clear();
                                    setState(() => _isUserSelected = false);
                                  },
                                )
                              : null,
                          prefixIcon: _isUserSelected
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: userId.isNotEmpty
                      ? () => _handleUserSelection(userId)
                      : null,
                  child: const Text('확인'),
                ),
              ],
            ),
            if (_isUserSelected) ...[
              const SizedBox(height: 16),
              Text(
                '현재 선택된 사용자: $userId',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
            const SizedBox(height: 20),
            _buildFeatureButton(
              icon: Icons.analytics,
              label: '말투 분석하기',
              enabled: _isUserSelected,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnalyzePage(userId: userId),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              icon: Icons.sync_alt,
              label: '말투 변환',
              enabled: _isUserSelected,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ConvertPage(userId: userId),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              icon: Icons.library_books,
              label: '프리셋 관리',
              enabled: _isUserSelected,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PresetPage(userId: userId),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildFeatureButton(
              icon: Icons.history,
              label: '히스토리 보기',
              enabled: _isUserSelected,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryPage(userId: userId),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: Text(label),
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 45),
      ),
    );
  }
}
