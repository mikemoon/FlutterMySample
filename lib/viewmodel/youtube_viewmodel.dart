
import 'package:flutter/cupertino.dart';
import 'package:ibook/datasource/datasource.dart';
import 'package:ibook/model/youtube/youtubeInfo.dart';
import 'package:ibook/model/youtube/youtubeitem.dart';
import 'package:ibook/repository/youtube_repository.dart';

class YoutubeViewModel with ChangeNotifier{
  final YoutubeRepository youtubeRepository;
  YoutubeInfo? _youtubeInfo;
  YoutubeInfo? get youtubeInfo => _youtubeInfo;
  List<YoutubeItem> youtubeItems = [];
  var nextPageToken = '';

  YoutubeViewModel({required this.youtubeRepository});

  Future<void> fetchYoutubeList(String pageToken) async{
    _youtubeInfo = await youtubeRepository.fetchYoutubeList(pageToken);
    for(var item in youtubeInfo!.items!){
      youtubeItems.add(item);
    }
    notifyListeners();
  }

  void nextPageLoad() async {
    if(youtubeInfo?.nextPageToken != null && nextPageToken != youtubeInfo?.nextPageToken){
      nextPageToken = youtubeInfo!.nextPageToken!;
      fetchYoutubeList(youtubeInfo!.nextPageToken!);
    }
  }
}