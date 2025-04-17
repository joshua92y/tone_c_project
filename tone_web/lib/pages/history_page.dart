import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // ✅ 복사 기능을 위한 import
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final String userId;  // userId를 필수 파라미터로 추가
  const HistoryPage({super.key, required this.userId});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String hostApiServer = 'https://tonecproject-production.up.railway.app';
  List<String> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() => _loading = true);
    try {
      final response = await http.get(
        Uri.parse('$hostApiServer/history/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decoded);
        setState(() {
          _history = List<String>.from(data.reversed);
        });
      } else {
        throw Exception('히스토리 불러오기 실패 (${response.statusCode})');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('히스토리 로딩 오류: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshHistory() async {
    await _fetchHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕘 최근 변환 기록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory,
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshHistory,
              child: _history.isEmpty
                  ? ListView(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: Text('저장된 기록이 없습니다.')),
                        ),
                      ],
                    )
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
                                const SnackBar(
                                  content: Text('복사되었습니다.'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            tooltip: '복사하기',
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
