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
  final String userId = 'joshua'; // 사용자 ID
  final String hostApiServer = 'https://tonecproject-production.up.railway.app'; // ✅ 배포된 API 서버 주소

  List<String> _history = []; // 변환 히스토리 목록
  bool _loading = true; // 로딩 상태 여부

  @override
  void initState() {
    super.initState();
    _fetchHistory(); // 위젯이 초기화될 때 히스토리 불러오기 실행
  }

  // 서버에서 히스토리 불러오기
  Future<void> _fetchHistory() async {
    try {
      // API 호출
      final response = await http.get(Uri.parse('$hostApiServer/history/$userId'));
      if (response.statusCode == 200) {
        // UTF8 디코딩 및 JSON 파싱
        final decoded = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decoded);
        setState(() {
          _history = List<String>.from(data.reversed); // 최신순으로 정렬
        });
      } else {
        throw Exception('히스토리 불러오기 실패');
      }
    } catch (e) {
      // 에러 발생 시 메시지 출력
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류: $e')));
    } finally {
      setState(() => _loading = false); // 로딩 완료 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🕘 최근 변환 기록')),
      body: _loading
          ? const Center(child: CircularProgressIndicator()) // 로딩 중 표시
          : _history.isEmpty
              ? const Center(child: Text('저장된 기록이 없습니다.')) // 기록이 없을 때
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _history.length,
                  separatorBuilder: (_, __) => const Divider(), // 아이템 구분선
                  itemBuilder: (context, index) {
                    final sentence = _history[index];
                    return ListTile(
                      title: Text(sentence),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          // 문장 복사 기능
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
