import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:ibook/util/secret.dart' show Secret, rootBundle;

class SecretLoader {
  final String secretPath;

  SecretLoader({required this.secretPath});
  Future<Secret> loadYoutubeApiKey() {
    return rootBundle.loadStructuredData<Secret>(secretPath,
            (jsonStr) async {
          final secret = Secret.fromJson(json.decode(jsonStr));
          return secret;
        });
  }
}