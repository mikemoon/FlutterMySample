import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
//import 'package:google_sign_in/google_sign_in.dart';
//import 'package:ibook/appstate.dart';
//import 'package:provider/provider.dart';

class YoutubePage extends StatefulWidget {
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

  @override
  void initState() {
    fetchYoutubeList("").then((value) {
      setState(() {
        youtubeInfo = value;
        youtubeItems.addAll(value.items as Iterable<YoutubeItem>);
      });
    }
    );
    scrollController = ScrollController()..addListener(nextPageLoad);
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

    return Builder(
      builder: (context) {
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
    );
  }

  void onItemSelect(YoutubeItem youtubeItem) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => FullScreenPage(item: youtubeItem)));
  }

  void nextPageLoad() async {
     if(hasNextPage){
         if(youtubeInfo.nextPageToken != null && nextPageToken != youtubeInfo.nextPageToken){
           print('nextPageLoad request token ${youtubeInfo.nextPageToken} , $nextPageToken');
           nextPageToken = youtubeInfo.nextPageToken!;
           fetchYoutubeList(youtubeInfo.nextPageToken!).then((value){
             setState(() {
               youtubeInfo = value;
               for(var item in value.items!){
                 youtubeItems.add(item);
               }
             });
           });
         }
     }
  }

  @override
  void dispose() {
    scrollController.removeListener(nextPageLoad);
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

Future<YoutubeInfo> fetchYoutubeList(String pageToken) async {
  final response = await http.get(Uri.parse(
      'https://youtube.googleapis.com/youtube/v3/videos?part=snippet&chart=mostPopular&pageToken=$pageToken&maxResults=5&key=AIzaSyBCw08IB3tvHJcmNwH55RUxl9jIoOyg6m4'));

  if (response.statusCode == 200) {
    print("fetchYoutubeList success");
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return YoutubeInfo.fromJson(jsonDecode(response.body) as Map<String,
        dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception(
        'Failed to load YoutubeList ${response.statusCode} ${response.body}');
  }
}

class YoutubeInfo {
  String? kind;
  String? etag;
  List<YoutubeItem>? items;
  String? nextPageToken;
  PageInfo? pageInfo;

  YoutubeInfo(
      {this.kind, this.etag, this.items, this.nextPageToken, this.pageInfo});

  YoutubeInfo.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    etag = json['etag'];
    if (json['items'] != null) {
      items = <YoutubeItem>[];
      json['items'].forEach((v) {
        items!.add(YoutubeItem.fromJson(v));
      });
    }
    nextPageToken = json['nextPageToken'];
    pageInfo = json['pageInfo'] != null
        ? PageInfo.fromJson(json['pageInfo'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['etag'] = etag;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['nextPageToken'] = nextPageToken;
    if (pageInfo != null) {
      data['pageInfo'] = pageInfo!.toJson();
    }
    return data;
  }
}

class YoutubeItem {
  String? kind;
  String? etag;
  String? id;
  Snippet? snippet;

  YoutubeItem({this.kind, this.etag, this.id, this.snippet});

  YoutubeItem.fromJson(Map<String, dynamic> json) {
    kind = json['kind'];
    etag = json['etag'];
    id = json['id'];
    snippet =
    json['snippet'] != null ? Snippet.fromJson(json['snippet']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['kind'] = kind;
    data['etag'] = etag;
    data['id'] = id;
    if (snippet != null) {
      data['snippet'] = snippet!.toJson();
    }
    return data;
  }
}

class Snippet {
  String? publishedAt;
  String? channelId;
  String? title;
  String? description;
  Thumbnails? thumbnails;
  String? channelTitle;
  List<String>? tags;
  String? categoryId;
  String? liveBroadcastContent;
  Localized? localized;

  Snippet({this.publishedAt,
    this.channelId,
    this.title,
    this.description,
    this.thumbnails,
    this.channelTitle,
    this.tags,
    this.categoryId,
    this.liveBroadcastContent,
    this.localized});

  Snippet.fromJson(Map<String, dynamic> json) {
    publishedAt = json['publishedAt'];
    channelId = json['channelId'];
    title = json['title'];
    description = json['description'];
    thumbnails = json['thumbnails'] != null
        ? Thumbnails.fromJson(json['thumbnails'])
        : null;
    channelTitle = json['channelTitle'];
    tags = json['tags']?.cast<String>();
    categoryId = json['categoryId'];
    liveBroadcastContent = json['liveBroadcastContent'];
    localized = json['localized'] != null
        ? Localized.fromJson(json['localized'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['publishedAt'] = publishedAt;
    data['channelId'] = channelId;
    data['title'] = title;
    data['description'] = description;
    if (thumbnails != null) {
      data['thumbnails'] = thumbnails!.toJson();
    }
    data['channelTitle'] = channelTitle;
    data['tags'] = tags;
    data['categoryId'] = categoryId;
    data['liveBroadcastContent'] = liveBroadcastContent;
    if (localized != null) {
      data['localized'] = localized!.toJson();
    }
    return data;
  }
}

class Thumbnails {
  ThumbnailInfo? defaultThumb;
  ThumbnailInfo? medium;
  ThumbnailInfo? high;
  ThumbnailInfo? standard;
  ThumbnailInfo? maxres;

  Thumbnails(
      {this.defaultThumb, this.medium, this.high, this.standard, this.maxres});

  Thumbnails.fromJson(Map<String, dynamic> json) {
    defaultThumb = json['default'] != null
        ? ThumbnailInfo.fromJson(json['default'])
        : null;
    medium =
    json['medium'] != null ? ThumbnailInfo.fromJson(json['medium']) : null;
    high = json['high'] != null ? ThumbnailInfo.fromJson(json['high']) : null;
    standard = json['standard'] != null
        ? ThumbnailInfo.fromJson(json['standard'])
        : null;
    maxres =
    json['maxres'] != null ? ThumbnailInfo.fromJson(json['maxres']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (defaultThumb != null) {
      data['default'] = defaultThumb!.toJson();
    }
    if (medium != null) {
      data['medium'] = medium!.toJson();
    }
    if (high != null) {
      data['high'] = high!.toJson();
    }
    if (standard != null) {
      data['standard'] = standard!.toJson();
    }
    if (maxres != null) {
      data['maxres'] = maxres!.toJson();
    }
    return data;
  }
}

class ThumbnailInfo {
  String? url;
  int? width;
  int? height;

  ThumbnailInfo({this.url, this.width, this.height});

  ThumbnailInfo.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    width = json['width'];
    height = json['height'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['url'] = url;
    data['width'] = width;
    data['height'] = height;
    return data;
  }
}

class Localized {
  String? title;
  String? description;

  Localized({this.title, this.description});

  Localized.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}

class PageInfo {
  int? totalResults;
  int? resultsPerPage;

  PageInfo({this.totalResults, this.resultsPerPage});

  PageInfo.fromJson(Map<String, dynamic> json) {
    totalResults = json['totalResults'];
    resultsPerPage = json['resultsPerPage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['totalResults'] = totalResults;
    data['resultsPerPage'] = resultsPerPage;
    return data;
  }
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