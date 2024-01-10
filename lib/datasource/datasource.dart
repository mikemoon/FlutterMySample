import 'dart:convert';

import 'package:ibook/model/news/newsdata.dart';
import 'package:ibook/model/youtube/youtubeInfo.dart';
import 'package:http/http.dart' as http;

class DataSource{

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
}