import 'package:ibook/model/youtube/thumbnailinfo.dart';

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