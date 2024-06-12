import 'package:flutter/material.dart'; // Flutter의 UI 요소들을 사용하기 위한 패키지
import 'package:http/http.dart' as http; // HTTP 요청을 위해 사용하는 패키지
import 'dart:convert'; // JSON 변환을 위한 패키지

void main() {
  runApp(const MyApp()); // 애플리케이션 시작
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'), // 홈 페이지 지정
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String result = ' '; // 검색 결과를 저장할 변수
  List data = []; // 블로그 데이터를 저장할 리스트
  TextEditingController? _editingController; // 검색어 입력을 위한 컨트롤러

  // JSON 데이터를 가져오는 함수
  Future<String> getJSONData() async {
    var url = 'https://dapi.kakao.com/v2/search/blog?query=${_editingController!.value.text}'; // API 요청 URL
    var response = await http.get(Uri.parse(url),
        headers: {'Authorization': 'KakaoAK f43e9a74716276f4b03da03a4a309b4c'}); // API 요청 헤더

    if (response.statusCode == 200) {
      setState(() {
        var dataConvertedToJSON = json.decode(response.body); // 응답을 JSON으로 변환
        List result = dataConvertedToJSON['documents']; // 'documents' 키의 값 추출
        data = result; // 기존 데이터를 새 데이터로 대체
      });
    } else {
      print('Failed to load data: ${response.statusCode}'); // 에러 발생 시 출력
    }
    return response.body; // 응답 본문 반환
  }

  @override
  void initState() {
    super.initState();

    _editingController = TextEditingController(); // TextEditingController 초기화
  }

  @override
  void dispose() {
    _editingController?.dispose(); // 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _editingController,
          style: TextStyle(color: Colors.black), // 입력 텍스트 스타일
          keyboardType: TextInputType.text, // 입력 타입 설정
          decoration: InputDecoration(hintText: '검색할 단어를 입력하세요.'), // 힌트 텍스트 설정
        ),
      ),
      body: Container(
        child: Center(
          child: data.isEmpty
              ? Text(
            'The data is not available', // 데이터가 없을 때 출력할 텍스트
            style: TextStyle(fontSize: 20),
            textAlign: TextAlign.center,
          )
              : ListView.builder(
            itemBuilder: (context, index) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // 카드 내부 패딩 설정
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      data[index]['thumbnail'] != null &&
                          data[index]['thumbnail'].toString().isNotEmpty
                          ? Image.network(
                        data[index]['thumbnail'],
                        height: 100,
                        width: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.error); // 이미지 로드 실패 시 에러 아이콘
                        },
                      )
                          : Container(width: 100, height: 100), // 이미지가 없을 때의 플레이스홀더
                      SizedBox(width: 10), // 이미지와 텍스트 사이의 간격
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              data[index]['title'].toString(), // 블로그 제목
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(data[index]['blogname'].toString()), // 블로그 이름
                            Text(data[index]['contents'].toString()), // 블로그 내용
                            Text(data[index]['url'].toString()), // 블로그 URL
                            Text(data[index]['datetime'].toString()), // 게시 날짜
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
            itemCount: data.length, // 리스트 아이템 개수
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getJSONData(); // 데이터 요청 함수 호출
        },
        child: Icon(Icons.file_download), // 다운로드 아이콘
      ),
    );
  }
}
