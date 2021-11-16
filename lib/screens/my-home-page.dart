import 'dart:async';

import 'package:Carrywiz/screens/request-carries-list-screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

import '../localization/language_constants.dart';
import 'carries-list-screen.dart';
import 'dashboard.dart';
import 'inbox.dart';
import 'profile-screen.dart';

class MyHomePage extends StatefulWidget {
  int bottomSelectedIndex;

  MyHomePage(this.bottomSelectedIndex);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.bottomSelectedIndex,
      keepPage: true,
    );
  }

  late PageController pageController;

  incrementBadge() {
    _tabBarCount = _tabBarCount + 1;
    _countController.sink.add(_tabBarCount);
  }

  decrementBadge() {
    _tabBarCount = _tabBarCount - 1;
    _countController.sink.add(_tabBarCount);
  }

  @override
  void dispose() {
    _countController.close();
    super.dispose();
  }

  StreamController<int> _countController = StreamController<int>();
  static int _tabBarCount = 0;

  final Color iconsColor = Color(0xFF9166B8);

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            // size: ScreenUtil().setSp(20),
          ),
          title: Text(
            getTranslatedValues(context, 'home_title'),
          )),
      BottomNavigationBarItem(
          icon: FaIcon(
            FontAwesomeIcons.box,
            // size: ScreenUtil().setSp(20),
          ),
          title: Text(
            getTranslatedValues(context, 'need_space_title'),
          )),
      BottomNavigationBarItem(
          icon: FaIcon(
            FontAwesomeIcons.suitcase,
            // size: ScreenUtil().setSp(20),
          ),
          title: Text(
            getTranslatedValues(context, 'have_space_title'),
          )),
      BottomNavigationBarItem(
          icon: Stack(
            children: <Widget>[
              Icon(
                Icons.inbox,
                // size: ScreenUtil().setSp(20),
              ),
              // Positioned(
              //   right: 0,
              //   child: StreamBuilder(
              //     stream: _countController.stream,
              //     initialData: _tabBarCount,
              //     builder: (_, snapshot) => BadgeIcon(
              //       badgeColor: Colors.red,
              //       showIfZero: true,
              //       icon: Icon(Icons.inbox, size: ScreenUtil().setSp(40)),
              //       badgeCount: snapshot.data,
              //     ),
              //   ),
              // ),
            ],
          ),
          title: Text(
            getTranslatedValues(context, 'inbox_title'),
          )),
      BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            // size: ScreenUtil().setSp(20),
          ),
          title: Text(
            getTranslatedValues(context, 'profile_title'),
          )),
    ];
  }

  Widget buildPageView() {
    return PageView(
      controller: pageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        Dashboard(),
        RequestCarriesListScreen(),
        CarriesList(),
        Inbox(),
        Profile(true),
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      widget.bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      widget.bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
    );
    return WillPopScope(
      onWillPop: _onBackButtonPressed,
      child: Scaffold(
        body: buildPageView(),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedFontSize: ScreenUtil().setSp(18),
          unselectedFontSize: ScreenUtil().setSp(18),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w600,
          ),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          currentIndex: widget.bottomSelectedIndex,
          iconSize: ScreenUtil().setSp(20),
          onTap: (index) {
            bottomTapped(index);
          },
          items: buildBottomNavBarItems(),
        ),
      ),
    );
  }

  DateTime? current;

  Future<bool> _onBackButtonPressed() {
    DateTime now = DateTime.now();
    if (current == null || now.difference(current!) > Duration(seconds: 2)) {
      current = now;
      Toast.show(getTranslatedValues(context, 'back_button_to_exit'), context,
          duration: Toast.lengthLong, gravity: Toast.bottom);
      return Future.value(false);
    } else {
      SystemNavigator.pop();
      return Future.value(true);
    }
  }
}
