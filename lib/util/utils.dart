
import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';

String getRandomString(int stringLength) => String.fromCharCodes(Iterable.generate(
    stringLength, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));