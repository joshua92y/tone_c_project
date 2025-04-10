import 'package:flutter/material.dart';
import 'pages/home_page.dart'; // ✅ HomePage import
import 'pages/convert_page.dart'; // ✅ 변환 화면 import
import 'pages/history_page.dart'; // ✅ import

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 이 위젯은 애플리케이션의 루트(root) 위젯입니다.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tone_C',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // 이것은 애플리케이션의 테마입니다.
        //
        // 이렇게 해보세요: "flutter run"으로 애플리케이션을 실행해 보세요.
        // 보시면 애플리케이션에 보라색 툴바가 있을 거예요. 그런 다음 앱을 종료하지 않고,
        // 아래 colorScheme에서 seedColor를 Colors.green으로 바꿔보세요.
        // 그리고 "hot reload"를 실행해보세요 (변경 내용을 저장하거나,
        // Flutter 지원 IDE에서 "hot reload" 버튼을 누르거나,
        // 명령줄에서 실행했다면 "r" 키를 누르세요).
        //
        // 카운터가 0으로 초기화되지 않은 것을 확인할 수 있습니다;
        // 애플리케이션 상태는 reload 중에 유지됩니다.
        // 상태를 완전히 초기화하려면 "hot restart"를 사용하세요.
        //
        // 이것은 단순한 값 변경뿐만 아니라 코드에도 적용됩니다:
        // 대부분의 코드 변경은 hot reload만으로도 테스트할 수 있습니다.
      ),
      home: const HomePage(), // ✅ HomePage로 변경
      debugShowCheckedModeBanner: false,
      routes: {
        '/convert': (context) => const ConvertPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // 이 위젯은 애플리케이션의 홈 페이지입니다. 이 위젯은 stateful이며,
  // 즉, 외형에 영향을 주는 데이터를 포함한 State 객체(아래에 정의됨)를 가지고 있다는 의미입니다.

  // 이 클래스는 상태(State)에 대한 설정(configuration)을 나타냅니다.
  // 이 클래스는 부모 위젯(이 경우 App 위젯)으로부터 전달받은 값들(여기서는 title)을 저장하며,
  // 해당 값들은 State의 build 메서드에서 사용됩니다.
  // 위젯의 서브클래스에서 선언되는 필드들은 항상 "final"로 표시됩니다.

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // 이 setState 호출은 Flutter 프레임워크에 이 State 내에서 어떤 변경이 발생했음을 알려줍니다.
      // 그러면 Flutter는 아래에 있는 build 메서드를 다시 실행하여
      // 화면이 변경된 값을 반영하도록 합니다.
      // 만약 setState()를 호출하지 않고 _counter 값을 바꾼다면,
      // build 메서드는 다시 호출되지 않기 때문에
      // 화면에는 아무 변화도 나타나지 않게 됩니다.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 이 메서드는 setState가 호출될 때마다 다시 실행됩니다.
    // 예를 들어 위에 있는 _incrementCounter 메서드에서 setState가 호출된 경우가 이에 해당합니다.
    //
    // Flutter 프레임워크는 build 메서드를 반복해서 실행하는 작업이 빠르게 이루어지도록 최적화되어 있습니다.
    // 따라서 업데이트가 필요한 부분만 다시 빌드하면 되고,
    // 위젯 인스턴스를 개별적으로 일일이 수정할 필요는 없습니다.
    return Scaffold(
      appBar: AppBar(
        // 이렇게 해보세요: 여기 색상을 특정 색상(예: Colors.amber)으로 바꿔보세요.
        // 그런 다음 hot reload를 실행하면 AppBar의 색상만 변경되고,
        // 나머지 색상은 그대로인 것을 확인할 수 있습니다.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // 여기에서는 App.build 메서드에 의해 생성된 MyHomePage 객체에서 값을 가져와,
        // AppBar의 제목(title)을 설정하는 데 사용합니다.
        title: Text(widget.title),
      ),
      body: Center(
        // Center는 레이아웃 위젯입니다. 하나의 자식 위젯을 받아서
        // 부모 위젯의 중앙에 위치시키는 역할을 합니다.
        child: Column(
          // Column도 레이아웃 위젯입니다. 여러 자식 위젯들을 받아서
          // 수직으로 나열합니다. 기본적으로는 자식 위젯들의 가로 크기에 맞춰지고,
          // 세로 방향으로는 부모 위젯의 높이에 최대한 맞추려 합니다.
          //
          // Column은 크기 조절 방식과 자식 위젯의 배치 방식을 제어할 수 있는 다양한 속성을 가지고 있습니다.
          // 여기서는 mainAxisAlignment 속성을 사용하여 자식들을 세로 방향의 중앙에 배치합니다.
          // Column은 수직 방향 레이아웃이기 때문에 main axis는 세로축이며,
          // cross axis는 가로축이 됩니다.
          //
          // 이렇게 해보세요: IDE에서 "Toggle Debug Paint" 기능을 선택하거나,
          // 콘솔에서 "p" 키를 눌러서 디버그 페인팅을 활성화해 보세요.
          // 각 위젯의 와이어프레임(경계선)을 시각적으로 확인할 수 있습니다.

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // 이 끝에 있는 쉼표는 build 메서드에서 자동 포매팅을 더 깔끔하게 만들어줍니다.
    );
  }
}
