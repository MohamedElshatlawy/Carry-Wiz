import 'dart:async';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/carry_card.dart';
import '../components/default-app-bar-widget.dart';
import '../models/Carry.dart';
import '../models/CarryResponseList.dart';
import '../screens/carry-trip-screen.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';
import '../localization/language_constants.dart';

class CarriesList extends StatefulWidget {
  @override
  _CarriesListState createState() => _CarriesListState();
}

class _CarriesListState extends State<CarriesList>
    with AutomaticKeepAliveClientMixin<CarriesList> {
  ApiAuthProvider _apiAuthProvider = ApiAuthProvider();
  late Future<CarryResponseList?> carryResponseList;

  bool _saving = false;

  void _turnOnCircularBar() {
    setState(() {
      _saving = true;
    });
  }

  void _turnOffCircularBar() {
    setState(() {
      _saving = false;
    });
  }

  @override
  void initState() {
    super.initState();
    carryResponseList = _apiAuthProvider.getAllCarriesByUserId();
  }

  List<Carry> carries = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      carryResponseList = _apiAuthProvider.getAllCarriesByUserId();
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
//    ScreenUtil.init(context, allowFontScaling: true);
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
          appBar: DefaultAppBar(
            title: getTranslatedValues(context, 'package_appbar_title'),
          ),
          body: SmartRefresher(
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
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(35),
                  ),
                  ButtonTheme(
                    height: ScreenUtil().setHeight(200),
                    minWidth: ScreenUtil().setWidth(970),
                    child: RaisedButton(
                      onPressed: (() async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CarryTrip(),
                          ),
                        );
                      }),
                      shape: RoundedRectangleBorder(
                          side:
                              BorderSide(color: Palette.lightOrange, width: 3),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Text(
                        getTranslatedValues(context, 'add_package_button'),
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(50),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(35),
                  ),
                  FutureBuilder<CarryResponseList?>(
                    future: carryResponseList,
                    builder:
                        (context, AsyncSnapshot<CarryResponseList?> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                        case ConnectionState.active:
                        case ConnectionState.none:
                          return SizedBox(
                            height: ScreenUtil().screenHeight / 1.75,
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
                            if (connectionStatus !=
                                InternetConnectionStatus.connected) {
                              errorMessage = 'Oops, you appear to be offline';
                            } else {
                              errorMessage =
                                  HttpNetWork.checkNetworkErrorString(
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
                            if (snapshot.data!.carryResponsesList.isEmpty) {
                              return Center(
                                child: Text(
                                  getTranslatedValues(
                                      context, 'no_packages_yet'),
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(70)),
                                ),
                              );
                            } else
                              carries = snapshot.data!.carryResponsesList;
                            return Row(
                              children: <Widget>[
                                Expanded(
                                  child: ListView.builder(
                                    primary: false,
                                    shrinkWrap: true,
                                    itemCount: carries.length,
                                    itemBuilder: (context, int index) {
                                      return CarryCard(
                                        isExpanded: false,
                                        carry: carries[index],
                                        rightButtonTitle: getTranslatedValues(
                                            context, 'delete_button'),
                                        rightButtonCallback: () async {
                                          _showDeleteDialog(
                                              content: getTranslatedValues(
                                                  context, 'delete_alert'),
                                              okFunction: () async {
                                                var connectionStatus;
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);

                                                if (connectionStatus !=
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  _turnOnCircularBar();
                                                  try {
                                                    await _apiAuthProvider
                                                        .deleteCarry(
                                                            carries[index]
                                                                .carryId!)
                                                        .then(
                                                          (value) =>
                                                              setState(() {
                                                            carries.removeAt(
                                                                index);
                                                          }),
                                                        );
                                                  } on DioError catch (error) {
                                                    String errorMessage = '';
                                                    if (error.response
                                                            .toString()
                                                            .contains(
                                                                'REQUEST_IS_LINKED') ||
                                                        error.response
                                                            .toString()
                                                            .contains(
                                                                'ConstraintViolationException')) {
                                                      errorMessage =
                                                          getTranslatedValues(
                                                              context,
                                                              'cannot_delete_package');
                                                    } else
                                                      errorMessage = HttpNetWork
                                                          .checkNetworkExceptionMessage(
                                                              error, context);
                                                    _showMessageDialog(
                                                        errorMessage);
                                                  } finally {
                                                    _turnOffCircularBar();
                                                  }
                                                } else
                                                  _showMessageDialog(
                                                      getTranslatedValues(
                                                          context,
                                                          'offline_user'));
                                              });
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          }
                      }
                      return Center(
                        child: Text(
                          getTranslatedValues(context, 'error_getting_data'),
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: ScreenUtil().setSp(70)),
                        ),
                      );
                    },
                  ),
                  // _fixedButton(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(
      {required String content, required Function okFunction}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(getTranslatedValues(context, 'delete_space')),
          content: Text(content),
          contentTextStyle: TextStyle(color: Colors.red),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(getTranslatedValues(context, 'ok_button')),
              onPressed: () {
                okFunction();
                Navigator.of(context).pop();
              },
              textColor: Colors.red,
            ),
            FlatButton(
              child: Text(getTranslatedValues(context, 'cancel_button')),
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

  void _showMessageDialog(String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text('Error!'),
          content: Text(content),
          contentTextStyle: TextStyle(color: Colors.red),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text('Try again'),
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
