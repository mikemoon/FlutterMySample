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