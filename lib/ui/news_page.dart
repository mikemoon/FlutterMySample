import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ibook/model/news/articles.dart';
import 'package:ibook/viewmodel/new_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsPage extends StatefulWidget{
  final NewsViewModel newsViewModel;

  const NewsPage({required this.newsViewModel});

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends State<NewsPage> with WidgetsBindingObserver{
  var isItemSelect = false;
  dynamic webViewController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.newsViewModel.fetchNews();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    widget.newsViewModel.fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context){
      if(isItemSelect){
        return PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (isItemSelect) {
              setState(() {
                isItemSelect = false;
              });
            }
          },
          child: WebViewWidget(controller: webViewController),
        );
      }else{
        return ChangeNotifierProvider.value(
          value: widget.newsViewModel,
          child: Consumer<NewsViewModel>(
            builder: (context, provider, child){
              if(provider.isLoading){
                return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child : Center(child : Text("News list loading..."))
                );
              }else {
                var newsList = provider.articles;
                return ListView(
                  children: [
                    for(var news in newsList)
                      newsItem(news)
                  ],
                );
              }
            },
          ),
        );
      }
    },);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget newsItem(Articles news){
    return GestureDetector(
      onTap: (){
        webViewController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(const Color(0x00000000))
          ..setNavigationDelegate(
              NavigationDelegate(
                  onProgress: (int progress){

                  },
                  onPageStarted: (String url){},
                  onPageFinished: (String url){},
                  onWebResourceError: (WebResourceError error){},
                  onNavigationRequest: (NavigationRequest request){
                    return NavigationDecision.navigate;
                  }
              )
          )
          ..loadRequest(Uri.parse(news.url!));
        setState(() {
          isItemSelect = true;
        });
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(news.title!, style: TextStyle(fontWeight: FontWeight.bold)),
            Text((news.description == null)? "" : news.description!),
            SizedBox(height: 10,),
            Divider(),
          ],
        ),
      ),
    );
  }
}