import 'package:ibook/model/youtube/snippet.dart';

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