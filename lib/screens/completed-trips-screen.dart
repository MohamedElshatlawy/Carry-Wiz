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
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../utilities/text-styles.dart';
import '../models/Carry.dart';
import '../models/CarryResponseList.dart';
import '../localization/language_constants.dart';

class CompletedTripsScreen extends StatefulWidget {
  @override
  _CompletedTripsScreenState createState() => _CompletedTripsScreenState();
}

class _CompletedTripsScreenState extends State<CompletedTripsScreen>
    with AutomaticKeepAliveClientMixin<CompletedTripsScreen> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
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
    carryResponseList = apiAuthProvider.getCompletedCarriesByUserId();
  }

  List<Carry> carries = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      carryResponseList = apiAuthProvider.getAllCarriesByUserId();
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
                                      context, 'no_completed_trips_yet'),
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
                                                    await apiAuthProvider
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
                                                            'LINKED_WITH_REQUESTS')) {
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
