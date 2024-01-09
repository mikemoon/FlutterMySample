
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/services.dart';
import 'package:ibook/appstate.dart';
import 'package:ibook/videopage.dart';
import 'package:ibook/youtubepage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (create) => MyAppState(),
      child: MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    )
    );
  }
}

class MyHomePage extends StatefulWidget {

  @override
  State<StatefulWidget> createState()  => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    Widget page;
    switch(selectedIndex){
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = VideoPage();
        break;
      case 2:
        page = YoutubePage();
            break;
      default:
        throw UnimplementedError('');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                    icon: Icon(Icons.video_collection),
                    label: Text('Video')),
                NavigationRailDestination(
                    icon: Icon(Icons.video_collection_outlined),
                    label: Text('Youtube')),
              ],
              selectedIndex: selectedIndex,    // ← Change to this.
              onDestinationSelected: (value) {
                // ↓ Replace print with this.
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatefulWidget{
  @override
  GeneratorPageState createState() => GeneratorPageState();
}

class GeneratorPageState extends State<GeneratorPage>{
  late Future<NewsData> futureNews;
  var isItemSelect = false;
  dynamic webViewController; 

  @override
  void initState() {
    futureNews = fetchNews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Builder(builder: (context){
      if(isItemSelect){
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (isItemSelect) {
              setState(() {
                isItemSelect = false;
              });
            }
          },
          child: WebViewWidget(controller: webViewController),
        );
      }else{
        return FutureBuilder<NewsData>(
          future: futureNews,
          builder: (context, snap){
            if(snap.hasData) {
              return ListView(
                children: [
                  for(var news in snap.data!.articles!)
                    newsItem(news)
                ],
              );
            }else if(snap.hasError){
              return Text("News data get failed.");
            }else{
              return Text("News data lading...");
            }
          },
        );
      }
    },);
  }

  Future<NewsData> fetchNews() async{
    final response = await http
        .get(Uri.parse('https://newsapi.org/v2/top-headlines?country=kr&apiKey=bdd1e4f5e0ce4896b02637c9c24a5fa5'));
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return NewsData.fromJson(jsonDecode(response.body) as Map<String, dynamic>); //.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load');
    }
  }

  Widget newsItem(Articles news){
    return GestureDetector(
      onTap: (){
        webViewController = WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..setBackgroundColor(const Color(0x00000000))
            ..setNavigationDelegate(
              NavigationDelegate(
                onProgress: (int progress){

                },
                onPageStarted: (String url){},
                onPageFinished: (String url){},
                onWebResourceError: (WebResourceError error){},
                onNavigationRequest: (NavigationRequest request){
                  return NavigationDecision.navigate;
                }
              )
            )
            ..loadRequest(Uri.parse(news.url!));
        setState(() {
          isItemSelect = true;
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(news.title!, style: TextStyle(fontWeight: FontWeight.bold)),
            Text((news.description == null)? "" : news.description!),
            SizedBox(height: 10,),
            Divider(),
          ],
        ),
      ),
    );
  }
}



class NewsData {
  String? status;
  int? totalResults;
  List<Articles>? articles;

  NewsData({this.status, this.totalResults, this.articles});

  NewsData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    totalResults = json['totalResults'];
    if (json['articles'] != null) {
      articles = <Articles>[];
      json['articles'].forEach((v) {
        articles!.add(Articles.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['totalResults'] = totalResults;
    if (articles != null) {
      data['articles'] = articles!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Articles {
  Source? source;
  String? author;
  String? title;
  String? description;
  String? url;
  String? urlToImage;
  String? publishedAt;
  String? content;

  Articles(
      {this.source,
        this.author,
        this.title,
        this.description,
        this.url,
        this.urlToImage,
        this.publishedAt,
        this.content});

  Articles.fromJson(Map<String, dynamic> json) {
    source =
    json['source'] != null ? Source.fromJson(json['source']) : null;
    author = json['author'];
    title = json['title'];
    description = json['description'];
    url = json['url'];
    urlToImage = json['urlToImage'];
    publishedAt = json['publishedAt'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (source != null) {
      data['source'] = source!.toJson();
    }
    data['author'] = author;
    data['title'] = title;
    data['description'] = description;
    data['url'] = url;
    data['urlToImage'] = urlToImage;
    data['publishedAt'] = publishedAt;
    data['content'] = content;
    return data;
  }
}

class Source {
  dynamic id;
  String? name;

  Source({this.id, this.name});

  Source.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    return data;
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    return Card(
        color: theme.colorScheme.primary,
        child: Padding(padding: const EdgeInsets.all(20),
            child : Text(pair.asLowerCase, style : style, semanticsLabel: "${pair.first} ${pair.second}",)
        )
    );
  }
}

