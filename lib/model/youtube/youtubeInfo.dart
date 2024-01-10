import 'package:ibook/model/youtube/pageinfo.dart';
import 'package:ibook/model/youtube/youtubeitem.dart';

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