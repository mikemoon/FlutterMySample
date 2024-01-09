
import 'package:english_words/english_words.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyAppState extends ChangeNotifier{
  GoogleSignInAccount? currentGoogleUser;
  GoogleSignIn googleSignIn = GoogleSignIn(scopes: <String>[
    'email', 'https://www.googleapis.com/auth/youtube.readonly'
  ]);
  var current = WordPair.random();
  var favorites = <WordPair>[];

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite(){
    if(favorites.contains(current)){
      favorites.remove(current);
    }else{
      favorites.add(current);
    }
    notifyListeners();
  }

  Future<void> requestGoogleSignIn() async {
    try{
      print("google sign~~");
      var result  = await googleSignIn.signIn();
      print("google sign ret $result");
    }catch(error){
      print("google signIn err : $error");
    }
  }
}