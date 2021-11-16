import 'package:Carrywiz/components/default-app-bar-widget.dart';
import 'package:Carrywiz/injector/injector.dart';
import 'package:Carrywiz/localization/language_constants.dart';
import 'package:Carrywiz/models/UserInfo.dart';
import 'package:Carrywiz/screens/reviews-screen.dart';
import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:Carrywiz/services/HttpNetwork.dart';
import 'package:Carrywiz/utilities/SharedPreferencesManager.dart';
import 'package:Carrywiz/utilities/text-styles.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'completed-trips-screen.dart';
import 'package-requests-screen.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin<Dashboard> {
  final TextStyle whiteText = TextStyle(color: Colors.white);
  //
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();
  late String _userName;
  late int _userId;
  late Future<UserInfo?> _userInfo;
  ApiAuthProvider _apiAuthProvider = ApiAuthProvider();

  @override
  void initState() {
    super.initState();
    _userName = _sharedPreferencesManager
        .getString(SharedPreferencesManager.keyUserName)!;
    _userId =
        _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId);
    _userInfo = _apiAuthProvider.getUserInfoByUserId(_userId);
  }

  //
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _userInfo = _apiAuthProvider.getUserInfoByUserId(
          _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId));
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: DefaultAppBar(
          title: getTranslatedValues(context, 'dashboard_app_bar_title'),
        ),
        body: SafeArea(
          child: SmartRefresher(
              header: WaterDropMaterialHeader(),
              footer: CustomFooter(
                builder: (BuildContext context, LoadStatus? mode) {
                  Widget body;
                  if (mode == LoadStatus.idle) {
                    body = Text("pull up load");
                  } else if (mode == LoadStatus.loading) {
                    body = CupertinoActivityIndicator();
                  } else if (mode == LoadStatus.failed) {
                    body = Text("Load Failed!Click retry!");
                  } else if (mode == LoadStatus.canLoading) {
                    body = Text("release to load more");
                  } else {
                    body = Text("No more Data");
                  }
                  return Container(
                    height: 55.0,
                    child: Center(child: body),
                  );
                },
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: _buildBody(context)),
        ));
  }

  Widget _buildBody(BuildContext context) {
    final defaultSizedBox = SizedBox(height: ScreenUtil().setHeight(40));
    return SingleChildScrollView(
      child: FutureBuilder<UserInfo?>(
        future: _userInfo,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
            case ConnectionState.none:
              return SizedBox(
                height: ScreenUtil().screenHeight / 1.3,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                String errorMessage = snapshot.error.toString();
                var connectionStatus;
                InternetConnectionChecker()
                    .connectionStatus
                    .then((value) => connectionStatus = value);
                if (connectionStatus != InternetConnectionStatus.connected) {
                  errorMessage = 'Oops, you appear to be offline';
                } else {
                  errorMessage = HttpNetWork.checkNetworkErrorString(
                      errorMessage, context);
                }
                return SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: Text(
                      'Error: $errorMessage',
                      style: TextStyles.errorStyle,
                    ),
                  ),
                );
              }
              if (snapshot.hasData) {
                var rating =
                    snapshot.data!.rating == 0 ? '--' : snapshot.data!.rating;
                var depAirportIata = snapshot.data!.nextCarry != null
                    ? snapshot.data!.nextCarry!.departureAirport.iata
                    : getTranslatedValues(context, 'not_yet');
                var arrAirportIata = snapshot.data!.nextCarry != null
                    ? snapshot.data!.nextCarry!.arrivalAirport.iata
                    : getTranslatedValues(context, 'not_yet');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _buildHeader(),
                    defaultSizedBox,
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(50)),
                      child: Text(
                        getTranslatedValues(context, 'next_trip'),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: ScreenUtil().setSp(55)),
                      ),
                    ),
                    Card(
                      elevation: 4.0,
                      margin: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(40),
                          horizontal: ScreenUtil().setHeight(50)),
                      child: Padding(
                        padding: EdgeInsets.all(ScreenUtil().setHeight(20)),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.flight_takeoff,
                              color: Theme.of(context)
                                  .primaryTextTheme
                                  .button!
                                  .color,
                              size: ScreenUtil().setSp(120),
                            ),
                            Expanded(
                              child: Container(
                                  child: Column(
                                children: [
                                  Text(
                                    getTranslatedValues(context, 'from'),
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                  AutoSizeText(
                                    '$depAirportIata',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                ],
                              )),
                            ),
                            Expanded(
                              child: Container(
                                  child: Column(
                                children: [
                                  Text(
                                    getTranslatedValues(context, 'to'),
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                  AutoSizeText(
                                    '$arrAirportIata',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                ],
                              )),
                            ),

                            // ListTile(
                            //   leading: Container(
                            //     alignment: Alignment.bottomCenter,
                            //     width: ScreenUtil().setWidth(100),
                            //   ),
                            //   title: Text('To'),
                            //   subtitle: AutoSizeText('$arrAirportIata'),
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setHeight(45)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewsScreen(
                                      userId: _userId,
                                    ),
                                  )),
                              child: _buildTile(
                                color: Colors.deepPurple,
                                icon: FaIcon(
                                  FontAwesomeIcons.solidStar,
                                  color: Colors.amber,
                                  size: ScreenUtil().setSp(50),
                                ),
                                title: getTranslatedValues(context, 'rating'),
                                data: rating.toString(),
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(45)),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PackageRequestsScreen(),
                                  )),
                              child: _buildTile(
                                color: Colors.grey,
                                icon: FaIcon(
                                  FontAwesomeIcons.box,
                                  color: Colors.white,
                                  size: ScreenUtil().setSp(50),
                                ),
                                title: getTranslatedValues(
                                    context, 'current_requests_dashboard'),
                                data: '${snapshot.data!.currentRequests}',
                              ),
                            ),
                          ),
                          SizedBox(width: ScreenUtil().setWidth(45)),
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CompletedTripsScreen(),
                                  )),
                              child: _buildTile(
                                color: Colors.deepPurple,
                                icon: FaIcon(
                                  FontAwesomeIcons.planeArrival,
                                  color: Colors.white,
                                  size: ScreenUtil().setSp(50),
                                ),
                                title: getTranslatedValues(
                                    context, 'completed_trips_dashboard'),
                                data: '${snapshot.data!.completedTrips}',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: ScreenUtil().setHeight(40)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setHeight(45)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Image.asset(
                              'assets/images/dashboard-image.png',
                              height: ScreenUtil().setHeight(450),
                              width: ScreenUtil().setWidth(500),
                              fit: BoxFit.fill,
                            ),
                            // _buildTile(
                            //   color: Colors.grey,
                            //   icon: FaIcon(
                            //     FontAwesomeIcons.adversal,
                            //     color: Colors.white,
                            //   ),
                            //   title: "Good deals / ads / notifications",
                            //   data: '',
                            // ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }

  Container _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        // gradient: LinearGradient(
        //     begin: Alignment.topRight,
        //     end: Alignment.bottomLeft,
        //     colors: [Colors.deepPurple, Colors.grey[300]])
      ),
      child: ListTile(
        title: AutoSizeText(
          '$_userName',
          textAlign: TextAlign.center,
          style: whiteText.copyWith(
              fontWeight: FontWeight.bold, fontSize: ScreenUtil().setSp(60)),
        ),
//            trailing: CircleAvatar(
//              radius: 25.0,
//              backgroundImage: NetworkImage(avatar),
//            ),
      ),
    );
  }

  Container _buildTile(
      {required Color color,
      required FaIcon icon,
      required String title,
      required String data}) {
    return Container(
      padding: EdgeInsets.all(ScreenUtil().setHeight(30)),
      height: ScreenUtil().setHeight(380),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: color,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Expanded(child: icon),
          Expanded(
            child: AutoSizeText(
              title,
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(45)),
            ),
          ),
          Expanded(
            child: AutoSizeText(
              data,
              style: whiteText.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: ScreenUtil().setSp(50)),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessageDialog(String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(
            getTranslatedValues(context, 'error'),
          ),
          content: Text(content),
          contentTextStyle: TextStyle(color: Colors.red),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(getTranslatedValues(context, 'error_getting_data')),
              onPressed: () {
                Navigator.of(context).pop();
              },
              textColor: Colors.red,
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
