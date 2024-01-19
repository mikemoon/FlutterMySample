import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ibook/database/app_database.dart';
import 'package:ibook/datasource/datasource.dart';
import 'package:ibook/main.dart';
import 'package:ibook/model/news/articles.dart';
import 'package:ibook/model/news/newsdata.dart';
import 'package:ibook/repository/map_repository.dart';
import 'package:ibook/repository/news_repository.dart';
import 'package:ibook/repository/youtube_repository.dart';
import 'package:ibook/ui/bluetooth_page.dart';
import 'package:ibook/ui/map_page.dart';
import 'package:ibook/ui/news_page.dart';
import 'package:ibook/ui/video_page.dart';
import 'package:ibook/viewmodel/appstate.dart';
import 'package:ibook/ui/youtube_page.dart';
import 'package:ibook/viewmodel/bluetooth_viewmodel.dart';
import 'package:ibook/viewmodel/mappage_viewmodel.dart';
import 'package:ibook/viewmodel/new_viewmodel.dart';
import 'package:ibook/viewmodel/youtube_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get_it/get_it.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  setupGetIt().then((_) => {
    runApp(const MyApp())
  }
  );

}

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async{
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  var dataSource = DataSource();
  var newsRepository = NewsRepository(dataSource: dataSource);
  var youtubeRepository = YoutubeRepository(dataSource: dataSource);
  var mapRepository = MapRepository(mapPositionDao: database.mapPositionDao);
  getIt.registerSingleton<DataSource>(dataSource);
  getIt.registerSingleton<NewsRepository>(newsRepository);
  getIt.registerSingleton<YoutubeRepository>(youtubeRepository);
  getIt.registerFactory(() => NewsViewModel(newsRepository: newsRepository));
  getIt.registerFactory(
      () => YoutubeViewModel(youtubeRepository: youtubeRepository));
  getIt.registerFactory(() => MapPageViewModel(mapRepository: mapRepository));
  getIt.registerFactory(() => BluetoothViewModel());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: MyAppState(),
        ),
        /*ChangeNotifierProvider<NewsViewModel>.value(
          value: getIt.get<NewsViewModel>(),
        )*/
      ],
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
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = NewsPage(newsViewModel: getIt.get<NewsViewModel>());
        break;
      case 1:
        page = VideoPage();
        break;
      case 2:
        page = YoutubePage(viewModel: getIt.get<YoutubeViewModel>());
        break;
      case 3:
        page = GoogleMapPage(
          mapPageViewModel: getIt.get<MapPageViewModel>(),
        );
        break;
      case 4:
        page = BluetoothPage(viewModel: getIt.get<BluetoothViewModel>());
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
                    icon: Icon(Icons.video_collection), label: Text('Video')),
                NavigationRailDestination(
                    icon: Icon(Icons.video_collection_outlined),
                    label: Text('Youtube')),
                NavigationRailDestination(
                    icon: Icon(Icons.map_rounded), label: Text('Map')),
                NavigationRailDestination(
                    icon: Icon(Icons.bluetooth_connected),
                    label: Text('Bluetooth')),
              ],
              selectedIndex: selectedIndex, // ← Change to this.
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
