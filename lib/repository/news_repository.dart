import 'package:ibook/datasource/datasource.dart';
import 'package:ibook/model/news/newsdata.dart';

class NewsRepository{
  final DataSource dataSource;
  const NewsRepository({required this.dataSource});

  Future<NewsData> fetchNews() {
    return dataSource.fetchNews();
  }
}