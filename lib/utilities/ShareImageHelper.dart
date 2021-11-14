import 'dart:io';
import 'dart:typed_data';
import 'package:share/share.dart';
/// class that will take image url try to download it after that will preview share
class ShareImageHelper {
  ////////// singleton
  ShareImageHelper._privateConstructor();

  static ShareImageHelper? _instance;

  static ShareImageHelper get instance {
    if (_instance == null) {
      _instance = ShareImageHelper._privateConstructor();
    }
    return _instance!;
  }


  Future shareImage(File file) async {
    await Share.share(file.path);
        // "share image",
        // {
        //   'image.png': imageAsUint8List,
        // },
        // '*/*');
  }
}
