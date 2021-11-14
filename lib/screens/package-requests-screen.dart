import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/package_request_card.dart';
import '../components/request-card.dart';
import '../screens/chat-screen.dart';
import '../services/HttpNetwork.dart';
import '../services/messaging.dart';
import '../enums/PackageRequestReplyStatus.dart';
import '../enums/PackageRequestStatus.dart';
import '../models/PackageRequest.dart';
import '../models/PackageRequestList.dart';
import '../screens/qr_code_generation.dart';
import '../models/UserModel.dart';
import '../localization/language_constants.dart';
import '../services/ApiAuthProvider.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';

class PackageRequestsScreen extends StatefulWidget {
  @override
  _PackageRequestsscreenstate createState() => _PackageRequestsscreenstate();
}

class _PackageRequestsscreenstate extends State<PackageRequestsScreen>
    with AutomaticKeepAliveClientMixin<PackageRequestsScreen> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
  late Future<PackageRequestsList?> packageRequestsList;

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
    packageRequestsList = apiAuthProvider.getPackageRequestsByCarrierId();
  }

  List<PackageRequest> packageRequests = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      packageRequestsList = apiAuthProvider.getPackageRequestsByCarrierId();
    });
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    if (mounted)
      setState(() {
//        packageRequestsList = apiAuthProvider.getPackageRequestsByCarrierId();
      });
    _refreshController.loadComplete();
  }

  var connectionStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
          body: SmartRefresher(
            controller: _refreshController,
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
            onRefresh: _onRefresh,
            onLoading: _onLoading,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(35),
                  ),
                  FutureBuilder<PackageRequestsList?>(
                      future: packageRequestsList,
                      builder: (context,
                          AsyncSnapshot<PackageRequestsList?> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                          case ConnectionState.none:
                            return SizedBox(
                              height: ScreenUtil().screenHeight / 1.35,
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

                              if (connectionStatus ==
                                  InternetConnectionStatus.disconnected) {
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
                              if (snapshot.data!.packageRequestList.isEmpty) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height / 1.35,
                                  child: Center(
                                    child: Text(
                                      getTranslatedValues(
                                          context, 'you_have_no_requests'),
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(70)),
                                    ),
                                  ),
                                );
                              } else
                                packageRequests =
                                    snapshot.data!.packageRequestList;
                              return Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ListView.builder(
                                      reverse: true,
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: packageRequests.length,
                                      itemBuilder: (context, int index) {
                                        PackageRequest packageRequest = snapshot
                                            .data!.packageRequestList[index];
                                        if (packageRequest.requestStatus ==
                                            PackageRequestStatus
                                                .PENDING.index) {
                                          // pending
                                          return PackageRequestCard(
                                            isRead: packageRequest.isRead,
                                            onTapFunction: () {
                                              _getPackageRequestReadById(
                                                  packageRequest, index);
                                            },
                                            messageTitle: getTranslatedValues(
                                                context, 'coming_request'),
                                            cardWidget: RequestCard(
                                              requestCarry: packageRequest
                                                  .requestCarryResponse,
                                              leftButtonTitle:
                                                  getTranslatedValues(
                                                      context, 'accept_button'),
                                              rightButtonTitle:
                                                  getTranslatedValues(context,
                                                      'decline_button'),
                                              leftButtonCallback: () async {
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .connected) {
//                                            send acceptation
                                                  _turnOnCircularBar();
                                                  try {
                                                    await apiAuthProvider
                                                        .sendPackageRequestResponse(
                                                            packageRequestId:
                                                                packageRequest
                                                                    .packageRequestId,
                                                            requestCarryId:
                                                                packageRequest
                                                                    .requestCarryResponse
                                                                    .requestCarryId!,
                                                            carryId:
                                                                packageRequest
                                                                    .carry
                                                                    .carryId!,
                                                            requestStatus:
                                                                PackageRequestReplyStatus
                                                                    .APPROVED
                                                                    .index)
                                                        .then((value) {
                                                      setState(() {
                                                        packageRequest
                                                                .requestStatus =
                                                            PackageRequestReplyStatus
                                                                .APPROVED.index;
                                                        _saving = false;
                                                      });
                                                      Messaging.sendAndRetrieveMessage(
                                                          title: getTranslatedValues(
                                                              context,
                                                              'request_accepted'),
                                                          body: getTranslatedValues(
                                                              context,
                                                              'carrier_accept'),
                                                          fcmToken: packageRequest
                                                              .requestCarryResponse
                                                              .user!
                                                              .firebaseToken!);
                                                    });
                                                  } on DioError catch (error) {
                                                    String errorMessage = '';
                                                    if (error.response
                                                        .toString()
                                                        .contains(
                                                            'SPACE_EXCEEDS'))
                                                      errorMessage =
                                                          getTranslatedValues(
                                                              context,
                                                              'request_exceed');
                                                    else
                                                      HttpNetWork
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
                                              },
                                              rightButtonCallback: () async {
//                                            send decline
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  try {
                                                    _turnOnCircularBar();
                                                    await apiAuthProvider
                                                        .sendPackageRequestResponse(
                                                            packageRequestId:
                                                                packageRequest
                                                                    .packageRequestId,
                                                            requestCarryId:
                                                                packageRequest
                                                                    .requestCarryResponse
                                                                    .requestCarryId!,
                                                            carryId:
                                                                packageRequest
                                                                    .carry
                                                                    .carryId!,
                                                            requestStatus:
                                                                PackageRequestReplyStatus
                                                                    .DECLINED
                                                                    .index)
                                                        .then((_) {
                                                      setState(() {
                                                        packageRequests
                                                            .removeAt(index);
                                                      });
                                                      Messaging.sendAndRetrieveMessage(
                                                          title: getTranslatedValues(
                                                              context,
                                                              'request_declined'),
                                                          body: getTranslatedValues(
                                                              context,
                                                              'carrier_declined'),
                                                          fcmToken: packageRequest
                                                              .requestCarryResponse
                                                              .user!
                                                              .firebaseToken!);
                                                    });
                                                  } on DioError catch (error) {
                                                    String errorMessage =
                                                        HttpNetWork
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
                                              },
                                            ),
                                          );
                                        } else if (packageRequest
                                                .requestStatus ==
                                            PackageRequestStatus
                                                .APPROVED.index) {
                                          // approved
                                          return PackageRequestCard(
                                              isRead: packageRequest.isRead,
                                              onTapFunction: () {
                                                _getPackageRequestReadById(
                                                    packageRequest, index);
                                              },
                                              actionWidget: Tooltip(
                                                message: getTranslatedValues(
                                                    context,
                                                    'qr_generate_tooltip'),
                                                child: Image.asset(
                                                    'assets/images/qr_code.png'),
                                              ),
                                              actionButtonVoidCallBack: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          QRCodeGeneration(
                                                              packageRequest
                                                                  .packageRequestUniqueKey)),
                                                );
                                              },
                                              messageTitle: getTranslatedValues(
                                                  context, 'request_waiting'),
                                              cardWidget: RequestCard(
                                                requestCarry: packageRequest
                                                    .requestCarryResponse,
                                                leftButtonTitle:
                                                    getTranslatedValues(context,
                                                        'contact_requester_button'),
                                                rightButtonTitle:
                                                    getTranslatedValues(context,
                                                        'cancel_button'),
                                                leftButtonCallback: () =>
                                                    _chatWithRequester(
                                                        packageRequest
                                                            .requestCarryResponse
                                                            .user!),
                                                rightButtonCallback: () {
                                                  InternetConnectionChecker()
                                                      .connectionStatus
                                                      .then((value) =>
                                                          connectionStatus =
                                                              value);
                                                  if (connectionStatus ==
                                                      InternetConnectionStatus
                                                          .connected) {
                                                    _showDeleteDialog(
                                                        getTranslatedValues(
                                                            context,
                                                            'cancel_alert'),
                                                        () async {
                                                      _turnOnCircularBar();
                                                      try {
                                                        apiAuthProvider
                                                            .sendPackageRequestResponse(
                                                                packageRequestId:
                                                                    packageRequest
                                                                        .packageRequestId,
                                                                requestCarryId:
                                                                    packageRequest
                                                                        .requestCarryResponse
                                                                        .requestCarryId!,
                                                                carryId:
                                                                    packageRequest
                                                                        .carry
                                                                        .carryId!,
                                                                requestStatus:
                                                                    PackageRequestReplyStatus
                                                                        .CANCELLED
                                                                        .index)
                                                            .then((value) {
                                                          setState(() {
                                                            packageRequests
                                                                .removeAt(
                                                                    index);
                                                          });
                                                          Messaging.sendAndRetrieveMessage(
                                                              title: getTranslatedValues(
                                                                  context,
                                                                  'request_declined'),
                                                              body: getTranslatedValues(
                                                                  context,
                                                                  'carrier_declined'),
                                                              fcmToken: packageRequest
                                                                  .requestCarryResponse
                                                                  .user!
                                                                  .firebaseToken!);
                                                        });
                                                      } on DioError catch (error) {
                                                        String errorMessage =
                                                            HttpNetWork
                                                                .checkNetworkExceptionMessage(
                                                                    error,
                                                                    context);
                                                        _showMessageDialog(
                                                            errorMessage);
                                                      } finally {
                                                        _turnOffCircularBar();
                                                      }
                                                    });
                                                  } else
                                                    _showMessageDialog(
                                                        getTranslatedValues(
                                                            context,
                                                            'offline_user'));
                                                },
                                              ));
                                        } else if (packageRequest
                                                .requestStatus ==
                                            PackageRequestStatus
                                                .CANCELLED.index) {
                                          // cancelled
                                          return _dismissibleMessage(
                                              index: index,
                                              packageRequest: packageRequest,
                                              messageTitle: getTranslatedValues(
                                                  context,
                                                  'requester_canceled'));
                                        } else if (packageRequest
                                                .requestStatus ==
                                            PackageRequestStatus
                                                .PICKED_UP.index) {
                                          // pick up confirmed
                                          return PackageRequestCard(
                                              isRead: packageRequest.isRead,
                                              onTapFunction: () {
                                                _getPackageRequestReadById(
                                                    packageRequest, index);
                                              },
                                              actionWidget: Tooltip(
                                                message: getTranslatedValues(
                                                    context, 'qr_scan_tootip'),
                                                child: Image.asset(
                                                    'assets/images/qr_code.png'),
                                              ),
                                              actionButtonVoidCallBack:
                                                  () async {
                                                var result =
                                                    await BarcodeScanner.scan();
                                                print(result.type
                                                    .name); // The result type (barcode, cancelled, failed)
                                                print(result
                                                    .rawContent); // The barcode content
                                                print(result.format);
                                                if (result.type.name !=
                                                    'Cancelled') {
                                                  InternetConnectionChecker()
                                                      .connectionStatus
                                                      .then((value) =>
                                                          connectionStatus =
                                                              value);
                                                  if (connectionStatus ==
                                                      InternetConnectionStatus
                                                          .connected) {
                                                    try {
                                                      await apiAuthProvider
                                                          .confirmPackageRequestDelivery(
                                                              packageRequest
                                                                  .packageRequestId,
                                                              packageRequest
                                                                  .requestCarryResponse
                                                                  .requestCarryId!,
                                                              result.rawContent)
                                                          .then((value) {
                                                        setState(
                                                          () {
                                                            packageRequest
                                                                    .requestStatus =
                                                                PackageRequestReplyStatus
                                                                    .DELIVERED
                                                                    .index;
                                                          },
                                                        );
                                                        Messaging.sendAndRetrieveMessage(
                                                            title: getTranslatedValues(
                                                                context,
                                                                'request_delivered'),
                                                            body: getTranslatedValues(
                                                                context,
                                                                'request_delivered_message'),
                                                            fcmToken: packageRequest
                                                                .requestCarryResponse
                                                                .user!
                                                                .firebaseToken!);
                                                      });
                                                    } on DioError catch (error) {
                                                      String errorMessage = '';
                                                      if (error.response
                                                          .toString()
                                                          .contains(
                                                              'QR_CODE_NOT_MATCH')) {
                                                        errorMessage =
                                                            getTranslatedValues(
                                                                context,
                                                                'qr_didnot_match');
                                                      } else if (error.response
                                                          .toString()
                                                          .contains(
                                                              'QRCODE_NO_VALUE')) {
                                                        errorMessage =
                                                            getTranslatedValues(
                                                                context,
                                                                'qr_no_value');
                                                      } else {
                                                        errorMessage = HttpNetWork
                                                            .checkNetworkExceptionMessage(
                                                                error, context);
                                                      }
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
                                                }
                                              },
                                              messageTitle: getTranslatedValues(
                                                  context, 'pickup_confirmed'),
                                              cardWidget: RequestCard(
                                                requestCarry: packageRequest
                                                    .requestCarryResponse,
                                                rightButtonTitle:
                                                    getTranslatedValues(context,
                                                        'contact_requester'),
                                                oneButtonColor: Colors.amber,
                                                // rightButtonTitle:
                                                //     'Add to calendar',
                                                rightButtonCallback: () =>
                                                    _chatWithRequester(
                                                        packageRequest
                                                            .requestCarryResponse
                                                            .user!),
                                                // rightButtonCallback: () {
                                                //   // TODO: add to calendar
                                                // },
                                              ));
                                        } else {
                                          // delivery confirmed
                                          return PackageRequestCard(
                                              isRead: packageRequest.isRead,
                                              onTapFunction: () {
                                                _getPackageRequestReadById(
                                                    packageRequest, index);
                                              },
                                              actionWidget: Tooltip(
                                                message: getTranslatedValues(
                                                    context, 'delete_button'),
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              actionButtonVoidCallBack: () =>
                                                  _onPackageRequestDeletion(
                                                      index,
                                                      packageRequest
                                                          .packageRequestId),
                                              messageTitle: getTranslatedValues(
                                                  context, 'package_delivered'),
                                              cardWidget: RequestCard(
                                                requestCarry: packageRequest
                                                    .requestCarryResponse,
                                                leftButtonTitle:
                                                    getTranslatedValues(context,
                                                        'contact_requester'),
                                                rightButtonTitle:
                                                    getTranslatedValues(context,
                                                        'delete_button'),
                                                leftButtonCallback: () =>
                                                    _chatWithRequester(
                                                        packageRequest
                                                            .requestCarryResponse
                                                            .user!),
                                                rightButtonCallback: () =>
                                                    _onPackageRequestDeletion(
                                                        index,
                                                        packageRequest
                                                            .packageRequestId),
                                              ));
                                        }
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
                      }),
                  // _fixedButton(context)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _dismissibleMessage(
      {required PackageRequest packageRequest,
      required int index,
      messageTitle}) {
    {
      return Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          _onPackageRequestDeletion(index, packageRequest.packageRequestId);
        },
        child: Card(
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setHeight(13),
              horizontal: ScreenUtil().setHeight(13)),
          child: Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(30)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: AutoSizeText(
                        messageTitle,
                        style: TextStyles.expandedTitleTextStyle,
                      ),
                    ),
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => _onPackageRequestDeletion(
                            index, packageRequest.packageRequestId),
                      ),
                    ),
                  ],
                ),
                RequestCarryInfo(
                  requestCarry: packageRequest.requestCarryResponse,
                ),
              ],
            ),
          ),
          color: Theme.of(context).brightness == Brightness.light
              ? Palette.lightGrey
              : Theme.of(context).copyWith().cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
        ),
      );
    }
  }

  _getPackageRequestReadById(PackageRequest packageRequest, int index) {
    {
      try {
        apiAuthProvider
            .getPackageRequestReadById(packageRequest.packageRequestId)
            .then((_) => setState(() {
                  packageRequest.isRead = true;
                }));
      } on DioError catch (error) {
        String errorMessage =
            HttpNetWork.checkNetworkExceptionMessage(error, context);
        _showMessageDialog(errorMessage);
      }
    }
  }

  _chatWithRequester(UserModel requester) async {
    InternetConnectionChecker()
        .connectionStatus
        .then((value) => connectionStatus = value);
    if (connectionStatus == InternetConnectionStatus.connected) {
      try {
        await apiAuthProvider
            .getChatRoomIdBySenderAndRecipientId(requester.userId!)
            .then((value) => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatRoomId: value!,
                        recipient: requester,
                      ),
                    ),
                  )
                });
      } on DioError catch (error) {
        String errorMessage =
            HttpNetWork.checkNetworkExceptionMessage(error, context);
        _showMessageDialog(errorMessage);
      } finally {
        _turnOffCircularBar();
      }
    } else
      _showMessageDialog(getTranslatedValues(context, 'offline_user'));
  }

  void _onPackageRequestDeletion(int index, int packageRequestId) async {
    InternetConnectionChecker()
        .connectionStatus
        .then((value) => connectionStatus = value);
    if (connectionStatus == InternetConnectionStatus.connected) {
      try {
        _turnOnCircularBar();
        await apiAuthProvider
            .deletePackageRequest(packageRequestId)
            .then((value) => setState(
                  () {
                    packageRequests.removeAt(index);
                    _showSnackBar(context);
                  },
                ));
      } on DioError catch (error) {
        String errorMessage =
            HttpNetWork.checkNetworkExceptionMessage(error, context);
        _showMessageDialog(errorMessage);
      } finally {
        _turnOffCircularBar();
      }
    }
    _showMessageDialog(getTranslatedValues(context, 'offline_user'));
  }

  _showSnackBar(context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(
        getTranslatedValues(context, 'message_deleted'),
      ),
      action: SnackBarAction(
        label: '',
        onPressed: () {},
      ),
    ));
  }

  void _showMessageDialog(String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(getTranslatedValues(context, 'error')),
          content: Text(content),
          contentTextStyle: TextStyle(color: Colors.red),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: Text(getTranslatedValues(context, 'try_again')),
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

  void _showDeleteDialog(String content, Function okFunction) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(getTranslatedValues(context, 'delete_package_request')),
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

  @override
  bool get wantKeepAlive => true;
}
