import 'package:Carrywiz/screens/chat-rooms-screen.dart';
import 'package:Carrywiz/screens/package-requests-replies-screen.dart';
import 'package:Carrywiz/screens/package-requests-screen.dart';
import 'package:Carrywiz/screens/settings-screen.dart';
import 'package:Carrywiz/screens/messaging-widget.dart';
import 'package:Carrywiz/themes/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'inbox',
      home: Inbox(),
    ),
  );
}

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  @override
  void initState() {
    super.initState();
  }

  _InboxState();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            bottom: TabBar(
              labelColor: Palette.lightOrange,
              unselectedLabelColor: Colors.white,
              tabs: [
                Tab(
                    icon: Icon(
                  Icons.assignment_late,
                  size: ScreenUtil().setSp(70),
                )),
                Tab(
                    icon: Icon(
                  Icons.assignment_turned_in,
                  size: ScreenUtil().setSp(70),
                )),
                Tab(
                    icon: Icon(
                  Icons.chat,
                  size: ScreenUtil().setSp(70),
                )),
                // Tab(
                //     icon: Icon(
                //   Icons.notifications,
                //   size: ScreenUtil().setSp(70),
                // )),
              ],
            ),
            actions: <Widget>[
              IconButton(
                padding: EdgeInsets.only(right: ScreenUtil().setWidth(50)),
                icon: Icon(
                  Icons.brightness_low,
                  size: ScreenUtil().setSp(50),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen()),
                ),
              )
            ],
            title: Text(
              'Inbox',
              style: TextStyle(fontSize: ScreenUtil().setSp(50)),
            ),
            toolbarHeight: ScreenUtil().setHeight(320),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              PackageRequestsScreen(),
              PackageRequestReplies(),
              ChatRoomsScreen(),
              // MessagingWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
