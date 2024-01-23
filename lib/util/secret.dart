class Secret {
  final String apiKey;  Secret({this.apiKey = ""});
  factory Secret.fromJson(Map<String, dynamic> jsonMap) {
    return Secret(apiKey: jsonMap["youtube_api_key"]);
  }
}