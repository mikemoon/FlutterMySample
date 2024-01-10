import 'package:ibook/model/youtube/localized.dart';
import 'package:ibook/model/youtube/thumbnails.dart';

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