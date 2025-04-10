import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // ✅ 복사 기능을 위한 import
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String userId = 'joshua';
  List<String> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8000/history/$userId'));
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decoded);
        setState(() {
          _history = List<String>.from(data.reversed); // 최신 순서로 보기
        });
      } else {
        throw Exception('히스토리 불러오기 실패');
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
      appBar: AppBar(title: const Text('🕘 최근 변환 기록')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? const Center(child: Text('저장된 기록이 없습니다.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final sentence = _history[index];
                    return ListTile(
                      title: Text(sentence),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: sentence));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('복사되었습니다.')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
