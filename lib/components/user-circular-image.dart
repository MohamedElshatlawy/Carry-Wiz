import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserCircularImage extends StatelessWidget {
  final String networkImageURL;
  final double imageRadius;

  UserCircularImage({required this.networkImageURL, required this.imageRadius});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: networkImageURL,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: ScreenUtil().setSp(imageRadius),
        backgroundImage: NetworkImage(
          networkImageURL,
        ),
      ),
      placeholder: (context, url) => Image(
        width: ScreenUtil().setWidth(150),
        height: ScreenUtil().setHeight(210),
        image: AssetImage('assets/images/avatar-default.png'),
      ),
      errorWidget: (context, url, error) {
        return ClipOval(
          child: Image(
            width: ScreenUtil().setWidth(170),
            height: ScreenUtil().setHeight(210),
            image: AssetImage('assets/images/avatar-default.png'),
          ),
        );
      },
    );
  }
}
