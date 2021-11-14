import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../components/default-app-bar-widget.dart';
import '../components/submit-button.dart';
import '../screens/my-home-page.dart';
import '../themes/palette.dart';
import '../utilities/ShareImageHelper.dart';
import '../localization/language_constants.dart';

class QRCodeGeneration extends StatefulWidget {
  final String _stringData;

  const QRCodeGeneration(this._stringData);

  @override
  _QRCodeGenerationState createState() => _QRCodeGenerationState();
}

class _QRCodeGenerationState extends State<QRCodeGeneration> {
  GlobalKey _globalKey = new GlobalKey();

  Future<void> _captureAndSharePng() async {
    try {
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject()! as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage();
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();
      ShareImageHelper.instance.shareImage(File.fromRawPath(pngBytes));
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: DefaultAppBar(
          title: getTranslatedValues(context, 'qr_code_generation'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                child: RepaintBoundary(
                  key: _globalKey,
                  child: QrImage(
                    backgroundColor: Palette.lightPurple,
                    data: widget._stringData,
                    size: ScreenUtil().setWidth(600),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                  size: 30,
                ),
                onPressed: () => _captureAndSharePng(),
              ),
              Text(
                getTranslatedValues(context, 'qr_share_warning'),
                style: TextStyle(
                    color: Colors.red, fontSize: ScreenUtil().setSp(40)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(280),
                    vertical: ScreenUtil().setHeight(100)),
                child: SubmitButton(
                  title: getTranslatedValues(context, 'back_to_inbox'),
                  buttonColor: Palette.lightOrange,
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => MyHomePage(3))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
