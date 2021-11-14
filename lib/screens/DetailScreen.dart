import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailScreen extends StatelessWidget {
  final String? imageURL;
  final File? imageFile;

  const DetailScreen({this.imageURL,this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: SizedBox(
            height: ScreenUtil().setHeight(1200),
            child: Hero(
              tag: 'imageHero',
              child: imageFile == null ? Image.network(
                imageURL!,
              ) : Image.file(imageFile!),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
