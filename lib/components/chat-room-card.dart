import 'package:Carrywiz/components/user-circular-image.dart';
import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:Carrywiz/models/ChatRoom.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatRoomCard extends StatelessWidget {
  final ChatRoom chatRoom;
  final bool showDeletePanel;
  final int userId;

  final Function onPressedFunction;
  ChatRoomCard(
      {required this.chatRoom,
      required this.userId,
      required this.showDeletePanel,
      required this.onPressedFunction});

  final ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  @override
  Widget build(BuildContext context) {
    String? profileImageUrlVal = (chatRoom.chatInfo.sender.userId == userId)
        ? chatRoom.chatInfo.recipient.profileImageUrl
        : chatRoom.chatInfo.sender.profileImageUrl;
    String? chatWithUserName = (chatRoom.chatInfo.sender.userId == userId)
        ? chatRoom.chatInfo.recipient.name
        : chatRoom.chatInfo.sender.name;
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(30)),
          child: ListTile(
            leading: UserCircularImage(
              networkImageURL: profileImageUrlVal!,
              imageRadius: 70,
            ),
            // CachedNetworkImage(
            //   imageUrl: profileImageUrlVal,
            //   imageBuilder: (context, imageProvider) => Container(
            //     width: ScreenUtil().setWidth(150),
            //     height: ScreenUtil().setHeight(150),
            //     decoration: BoxDecoration(
            //       shape: BoxShape.circle,
            //       image:
            //           DecorationImage(image: imageProvider, fit: BoxFit.cover),
            //     ),
            //   ),
            //   placeholder: (context, url) => Image(
            //     width: ScreenUtil().setWidth(150),
            //     height: ScreenUtil().setHeight(150),
            //     image: AssetImage('assets/images/avatar-default.png'),
            //   ),
            //   errorWidget: (context, url, error) {
            //     return ClipOval(
            //       child: Image(
            //         width: ScreenUtil().setWidth(150),
            //         height: ScreenUtil().setHeight(150),
            //         image: AssetImage('assets/images/avatar-default.png'),
            //       ),
            //     );
            //   },
            // ),
            contentPadding: EdgeInsets.symmetric(
                vertical: ScreenUtil().setHeight(0),
                horizontal: ScreenUtil().setWidth(30)),
            title: AutoSizeText(
              '$chatWithUserName',
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: showDeletePanel
                ? IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () => onPressedFunction())
                : Text(
                    '${DateFormat('yyyy-MM-dd\nHH:mm').format(chatRoom.chatInfo.createdAt)}',
                    style: TextStyle(fontSize: ScreenUtil().setSp(35)),
                  ),
          ),
        ),
        _dividerWidget(),
      ],
    );
  }

  _dividerWidget() {
    return Padding(
        padding: EdgeInsets.only(),
        child: Divider(
          thickness: ScreenUtil().setHeight(2.5),
          color: Colors.grey,
          height: ScreenUtil().setHeight(0),
        ));
  }
}
