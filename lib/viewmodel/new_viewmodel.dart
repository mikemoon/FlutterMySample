
import 'package:flutter/cupertino.dart';
import 'package:ibook/model/news/articles.dart';
import 'package:ibook/model/news/newsdata.dart';
import 'package:ibook/repository/news_repository.dart';

class NewsViewModel with ChangeNotifier{
  var isDisposed = false;
  final NewsRepository newsRepository;
  List<Articles> articles = [];
  var isLoading = false;

  NewsViewModel({required this.newsRepository});

  Future<void> fetchNews() async{
    isLoading = true;
    notifyListeners();
    var response = await newsRepository.fetchNews();
    articles = response.articles!;
    isLoading = false;
    notifyListeners();
  }

  @override
  void notifyListeners() {
    if(!isDisposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    isDisposed = true;
    super.dispose();
  }
}