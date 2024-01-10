import 'package:flutter/material.dart';
import 'package:ibook/model/youtube/youtubeInfo.dart';
import 'package:ibook/model/youtube/youtubeitem.dart';
import 'package:ibook/viewmodel/youtube_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:ibook/appstate.dart';
//import 'package:provider/provider.dart';

class YoutubePage extends StatefulWidget {
  final YoutubeViewModel viewModel;

  const YoutubePage({required this.viewModel}) : super();

  @override
  YoutubePageState createState() => YoutubePageState();
}

class YoutubePageState extends State<YoutubePage> {
  //late Future<YoutubeInfo> futureYoutubeList;
  late ScrollController scrollController;
  bool hasNextPage = true;
  var nextPageToken = '';
  late YoutubeInfo youtubeInfo;
  List<YoutubeItem> youtubeItems = [];
  //YoutubeViewModel viewModel;

  @override
  void initState() {
    widget.viewModel.fetchYoutubeList('');
    scrollController = ScrollController()..addListener(widget.viewModel.nextPageLoad);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    //구글 OAuth2 를 사용한 youtube api call
    /*var appState = context.watch<MyAppState>();
    appState.googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) async {
      print("google sign $account");
      setState(() {
        appState.currentGoogleUser = account;
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    //var appState = context.watch<MyAppState>();
    //var currentGoogleUser = appState.currentGoogleUser;

    return ChangeNotifierProvider.value(
      value: widget.viewModel,
      child: Consumer<YoutubeViewModel>(
        builder: (context, youtubeProvider, child) {
          youtubeItems = youtubeProvider.youtubeItems;
          return ListView.builder(
            controller: scrollController,
            itemCount: youtubeItems.length,
            itemBuilder: (BuildContext context, int index) {
              return youtubeListItem(
                  context, youtubeItems[index],
                  onItemSelect);
            },
          );
        },
      ),
    );
  }

  void onItemSelect(YoutubeItem youtubeItem) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FullScreenPage(item: youtubeItem)));
  }

  @override
  void dispose() {
    scrollController.removeListener(widget.viewModel.nextPageLoad);
    super.dispose();
  }
}

Widget youtubeListItem(BuildContext context, YoutubeItem? item, Function(YoutubeItem) click) {
  //InkWell <-- if need ripple effect
  return GestureDetector(
      onTap: () {
        click(item);
      },
      child: SizedBox(
        height: 260,
        child: Card(
            child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                    children: <Widget>[
                Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                child:
                  Image.network(
                  item!.snippet!.thumbnails!.high!.url!.toString(),
                  width: 300,
                  height: double.maxFinite,
                  ),
                ),
        Expanded(
            flex: 1,
            child: SizedBox(
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.snippet!.title!.toString(),
                    style:
                    Theme
                        .of(context)
                        .textTheme
                        .headlineSmall,
                  ),
                  Text(item.snippet!.channelTitle!.toString())
                ],
              ),
            ))
        ],
      ))),
  )
  );
}

class FullScreenPage extends StatefulWidget{
  final YoutubeItem item;
  const FullScreenPage({required this.item});

  @override
  FullScreenPageState createState()  => FullScreenPageState();
}

class FullScreenPageState extends State<FullScreenPage>{
  late YoutubePlayerController controller;

  @override
  void initState() {
    controller = YoutubePlayerController(
      initialVideoId: widget.item.id!,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    )..addListener(() {
      print("listener $this");
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: YoutubePlayer(controller: controller),
    );
  }

  @override
  void deactivate() {
    controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    controller.pause();
    super.dispose();
  }

}