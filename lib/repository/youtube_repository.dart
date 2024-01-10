import 'package:ibook/datasource/datasource.dart';
import 'package:ibook/model/youtube/youtubeInfo.dart';

class YoutubeRepository{
  final DataSource dataSource;
  const YoutubeRepository({required this.dataSource});

  Future<YoutubeInfo> fetchYoutubeList(String pageToken){
    return dataSource.fetchYoutubeList(pageToken);
  }
}