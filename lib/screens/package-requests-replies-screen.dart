import 'dart:async';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toast/toast.dart';
import '../components/carry_card.dart';
import '../components/package_request_card.dart';
import '../components/request-card.dart';
import '../screens/chat-screen.dart';
import '../services/HttpNetwork.dart';
import '../services/messaging.dart';
import '../enums/PackageRequestReplyStatus.dart';
import '../models/PackageRequestRepliesList.dart';
import '../models/PackageRequestReply.dart';
import '../screens/add-review.dart';
import '../screens/profile-info-screen.dart';
import '../screens/qr_code_generation.dart';
import '../services/ApiAuthProvider.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';
import '../models/UserModel.dart';
import '../localization/language_constants.dart';

class PackageRequestReplies extends StatefulWidget {
  @override
  _PackageRequestRepliesState createState() => _PackageRequestRepliesState();
}

class _PackageRequestRepliesState extends State<PackageRequestReplies>
    with AutomaticKeepAliveClientMixin<PackageRequestReplies> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
  late Future<PackageRequestRepliesList?> packageRequestRepliesList;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    packageRequestRepliesList =
        apiAuthProvider.getPackageRequestRepliesByRequesterId();
  }

  List<PackageRequestReply> packageRequestReplies = [];

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      packageRequestRepliesList =
          apiAuthProvider.getPackageRequestRepliesByRequesterId();
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

  var connectionStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _saving,
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
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: ScreenUtil().setHeight(35),
                  ),
                  FutureBuilder<PackageRequestRepliesList?>(
                      future: packageRequestRepliesList,
                      builder: (context,
                          AsyncSnapshot<PackageRequestRepliesList?> snapshot) {
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
                              if (snapshot
                                  .data!.packageRequestReplyList.isEmpty) {
                                return Center(
                                  child: Text(
                                    getTranslatedValues(
                                        context, 'no_request_reply'),
                                    style: TextStyle(
                                      fontSize: ScreenUtil().setSp(70),
                                    ),
                                  ),
                                );
                              } else
                                packageRequestReplies =
                                    snapshot.data!.packageRequestReplyList;

                              return Row(
                                children: <Widget>[
                                  Expanded(
                                    child: ListView.builder(
                                      reverse: true,
                                      primary: false,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: packageRequestReplies.length,
                                      itemBuilder: (context, int index) {
                                        PackageRequestReply
                                            packageRequestReply =
                                            packageRequestReplies[index];
                                        int carrierId = packageRequestReply
                                            .carry.user!.userId!;
                                        if (packageRequestReply.requestStatus ==
                                            PackageRequestReplyStatus
                                                .APPROVED.index) {
                                          // approved
                                          return PackageRequestCard(
                                            isRead: packageRequestReply.isRead,
                                            onTapFunction: () {
                                              _getPackageRequestReplyReadById(
                                                  packageRequestReply, index);
                                            },
                                            actionWidget: Tooltip(
                                              message: getTranslatedValues(
                                                  context, 'qr_scan_tootip'),
                                              child: Image.asset(
                                                  'assets/images/qr_code.png'),
                                            ),
                                            actionButtonVoidCallBack: () async {
                                              var result =
                                                  await BarcodeScanner.scan();
                                              if (result.type.name !=
                                                      'Cancelled' &&
                                                  result.type.name !=
                                                      'Failed') {
                                                var connectionStatus;
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  _turnOnCircularBar();
                                                  try {
                                                    await apiAuthProvider
                                                        .confirmPackageRequestPickUp(
                                                            packageRequestReply
                                                                .packageRequestReplyId,
                                                            packageRequestReply
                                                                .requestCarry
                                                                .requestCarryId!,
                                                            result.rawContent)
                                                        .then((value) {
                                                      setState(
                                                        () {
                                                          packageRequestReply
                                                                  .requestStatus =
                                                              PackageRequestReplyStatus
                                                                  .PICKED_UP
                                                                  .index;
                                                          _saving = false;
                                                        },
                                                      );
                                                      Messaging.sendAndRetrieveMessage(
                                                          title: getTranslatedValues(
                                                              context,
                                                              'package_picked_up'),
                                                          body: getTranslatedValues(
                                                              context,
                                                              'package_picked_successfully'),
                                                          fcmToken:
                                                              packageRequestReply
                                                                  .carry
                                                                  .user!
                                                                  .firebaseToken!);
                                                      Toast.show(
                                                          getTranslatedValues(
                                                              context,
                                                              'pickup_confirmed'),
                                                          context,
                                                          duration:
                                                              Toast.lengthLong,
                                                          gravity:
                                                              Toast.bottom);
                                                    });
                                                  } on DioError catch (error) {
                                                    String errorMessage = '';
                                                    if (error.response
                                                        .toString()
                                                        .contains(
                                                            'QRCODE_NOT_MATCH'))
                                                      errorMessage =
                                                          getTranslatedValues(
                                                              context,
                                                              'qr_didnot_match');
                                                    else if (error.response
                                                        .toString()
                                                        .contains(
                                                            'QRCODE_NO_VALUE'))
                                                      errorMessage =
                                                          getTranslatedValues(
                                                              context,
                                                              'qr_no_value');
                                                    else
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
                                              }
                                            },
                                            messageTitle:
                                                '${getTranslatedValues(context, 'request_approved')}'
                                                '\n${getTranslatedValues(context, 'click_contact_carrier')}',
                                            cardWidget: RequestCard(
                                              requestCarry: packageRequestReply
                                                  .requestCarry,
                                              leftButtonTitle:
                                                  getTranslatedValues(context,
                                                      'contact_carrier_button'),
                                              rightButtonTitle:
                                                  getTranslatedValues(context,
                                                      'cancel_request_button'),
                                              leftButtonCallback: () async {
                                                connectionStatus;
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  _turnOnCircularBar();
                                                  try {
                                                    await apiAuthProvider
                                                        .getChatRoomIdBySenderAndRecipientId(
                                                            carrierId)
                                                        .then((value) => {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (_) => ChatScreen(
                                                                      chatRoomId:
                                                                          value!,
                                                                      recipient: packageRequestReply
                                                                          .carry
                                                                          .user!),
                                                                ),
                                                              )
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
                                                    getTranslatedValues(context,
                                                        'cancel_alert'),
                                                    () async {
                                                      _turnOnCircularBar();
                                                      try {
                                                        await apiAuthProvider
                                                            .cancelPackageRequestReply(
                                                                packageRequestReply
                                                                    .packageRequestReplyId,
                                                                packageRequestReply
                                                                    .carry
                                                                    .carryId!,
                                                                packageRequestReply
                                                                    .requestCarry
                                                                    .requestCarryId!)
                                                            .then((value) {
                                                          setState(
                                                            () {
                                                              packageRequestReplies
                                                                  .removeAt(
                                                                      index);
                                                              _saving = false;
                                                            },
                                                          );
                                                          Messaging.sendAndRetrieveMessage(
                                                              title: getTranslatedValues(
                                                                  context,
                                                                  'request_canceled'),
                                                              body: getTranslatedValues(
                                                                  context,
                                                                  'requester_canceled'),
                                                              fcmToken:
                                                                  packageRequestReply
                                                                      .carry
                                                                      .user!
                                                                      .firebaseToken!);
                                                        });
                                                      } on DioError catch (error) {
                                                        String errorMessage =
                                                            error.message;
                                                        _showMessageDialog(
                                                            errorMessage);
                                                      } finally {
                                                        _turnOffCircularBar();
                                                      }
                                                    },
                                                  );
                                                } else
                                                  _showMessageDialog(
                                                      getTranslatedValues(
                                                          context,
                                                          'offline_user'));
                                              },
                                            ),
                                          );
                                        } else if (packageRequestReply
                                                .requestStatus ==
                                            PackageRequestReplyStatus
                                                .DECLINED.index) {
                                          // declined
                                          return GestureDetector(
                                            onTap: () {
                                              _getPackageRequestReplyReadById(
                                                  packageRequestReply, index);
                                            },
                                            child: _dismissibleMessage(
                                              index: index,
                                              packageRequestReply:
                                                  packageRequestReply,
                                              messageTitle: getTranslatedValues(
                                                  context,
                                                  'your_request_declined'),
                                            ),
                                          );
                                        } else if (packageRequestReply
                                                .requestStatus ==
                                            PackageRequestReplyStatus
                                                .CANCELLED.index) {
                                          // cancelled
                                          return GestureDetector(
                                            onTap: () {
                                              _getPackageRequestReplyReadById(
                                                  packageRequestReply, index);
                                            },
                                            child: _dismissibleMessage(
                                                index: index,
                                                packageRequestReply:
                                                    packageRequestReply,
                                                messageTitle: getTranslatedValues(
                                                    context,
                                                    'your_carrier_canceled')),
                                          );
                                        } else if (packageRequestReply
                                                .requestStatus ==
                                            PackageRequestReplyStatus
                                                .MATCHED_BY_SERVER.index) {
                                          // server matched carry message
                                          int carrierId = packageRequestReply
                                              .carry.user!.userId!;
                                          return PackageRequestCard(
                                            isRead: packageRequestReply.isRead,
                                            onTapFunction: () {
                                              _getPackageRequestReplyReadById(
                                                  packageRequestReply, index);
                                            },
                                            actionWidget: Tooltip(
                                              message: getTranslatedValues(
                                                  context, 'delete_button'),
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                            actionButtonVoidCallBack: () async {
                                              InternetConnectionChecker()
                                                  .connectionStatus
                                                  .then((value) =>
                                                      connectionStatus = value);
                                              if (connectionStatus ==
                                                  InternetConnectionStatus
                                                      .connected) {
                                                _turnOnCircularBar();
                                                try {
                                                  await apiAuthProvider
                                                      .deletePackageReply(
                                                          packageRequestReply
                                                              .packageRequestReplyId)
                                                      .then(
                                                        (value) => setState(
                                                          () {
                                                            setState(() {
                                                              packageRequestReplies
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                        ),
                                                      );
                                                } on DioError catch (error) {
                                                  String errorMessage = HttpNetWork
                                                      .checkNetworkExceptionMessage(
                                                          error, context);
                                                  _showMessageDialog(
                                                      errorMessage);
                                                } finally {
                                                  _turnOffCircularBar();
                                                }
                                              } else
                                                _showMessageDialog(
                                                    getTranslatedValues(context,
                                                        'offline_user'));
                                            },
                                            messageTitle: getTranslatedValues(
                                                context, 'carry_wizard_found'),
                                            cardWidget: CarryCard(
                                              isExpanded: false,
                                              carry: packageRequestReply.carry,
                                              leftButtonTitle:
                                                  getTranslatedValues(context,
                                                      'send_request_button'),
                                              rightButtonTitle:
                                                  getTranslatedValues(context,
                                                      'check_profile_button'),
                                              leftButtonCallback: () async {
                                                //send request to carrier
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  _turnOnCircularBar();
                                                  try {
                                                    await apiAuthProvider
                                                        .sendPackageRequest(
                                                            packageRequestReply
                                                                .requestCarry
                                                                .requestCarryId!,
                                                            packageRequestReply
                                                                .carry.carryId!)
                                                        .then((value) async {
                                                      Messaging.sendAndRetrieveMessage(
                                                          title: getTranslatedValues(
                                                              context,
                                                              'request_received'),
                                                          body: getTranslatedValues(
                                                              context,
                                                              'requester_sent_package'),
                                                          fcmToken:
                                                              packageRequestReply
                                                                  .carry
                                                                  .user!
                                                                  .firebaseToken!);
                                                      await apiAuthProvider
                                                          .deletePackageReply(
                                                              packageRequestReply
                                                                  .packageRequestReplyId)
                                                          .then((value) {
                                                        setState(() {
                                                          packageRequestReplies
                                                              .removeAt(index);
                                                          _saving = false;
                                                        });
                                                        Toast.show(
                                                            getTranslatedValues(
                                                                context,
                                                                'request_sent_to_carrier'),
                                                            context,
                                                            duration: Toast
                                                                .lengthLong,
                                                            gravity:
                                                                Toast.bottom);
                                                      });
                                                    });
                                                  } on DioError catch (error) {
                                                    String errorMessage = '';
                                                    if (error.response
                                                        .toString()
                                                        .contains(
                                                            'KILOS_EXCEEDS')) {
                                                      errorMessage =
                                                          getTranslatedValues(
                                                              context,
                                                              'kilos_exceed');
                                                    } else {
                                                      errorMessage = HttpNetWork
                                                          .checkNetworkExceptionMessage(
                                                              error, context);
                                                    }
                                                  } finally {
                                                    _turnOffCircularBar();
                                                  }
                                                } else
                                                  _showMessageDialog(
                                                      getTranslatedValues(
                                                          context,
                                                          'offline_user'));
                                              },
                                              rightButtonCallback: () =>
                                                  Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => ProfileInfo(
                                                          userId: carrierId,
                                                        )),
                                              ),
                                            ),
                                          );
                                        } else if (packageRequestReply
                                                .requestStatus ==
                                            PackageRequestReplyStatus
                                                .PICKED_UP.index) {
                                          // pick up confirmed
                                          return PackageRequestCard(
                                            isRead: packageRequestReply.isRead,
                                            onTapFunction: () {
                                              _getPackageRequestReplyReadById(
                                                  packageRequestReply, index);
                                            },
                                            actionWidget: Tooltip(
                                              message: getTranslatedValues(
                                                  context,
                                                  'qr_generate_tooltip'),
                                              child: Image.asset(
                                                  'assets/images/qr_code.png'),
                                            ),
                                            actionButtonVoidCallBack: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) =>
                                                        QRCodeGeneration(
                                                            packageRequestReply
                                                                .packageRequestUniqueKey)),
                                              );
                                            },
                                            messageTitle:
                                                '${getTranslatedValues(context, 'pickup_confirmed')}\n${getTranslatedValues(context, 'click_contact_carrier')}}',
                                            cardWidget: RequestCard(
                                              requestCarry: packageRequestReply
                                                  .requestCarry,
                                              leftButtonTitle:
                                                  getTranslatedValues(context,
                                                      'contact_carrier_button'),
                                              rightButtonTitle:
                                                  getTranslatedValues(context,
                                                      'cancel_request_button'),
                                              leftButtonCallback: () =>
                                                  _chatWithCarrier(
                                                      packageRequestReply
                                                          .carry.user!),
                                              rightButtonCallback: () {
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus ==
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  _turnOnCircularBar();
                                                  _showDeleteDialog(
                                                    getTranslatedValues(context,
                                                        'cancel_alert'),
                                                    () async {
                                                      try {
                                                        await apiAuthProvider
                                                            .cancelPackageRequestReply(
                                                                packageRequestReply
                                                                    .packageRequestReplyId,
                                                                packageRequestReply
                                                                    .carry
                                                                    .carryId!,
                                                                packageRequestReply
                                                                    .requestCarry
                                                                    .requestCarryId!)
                                                            .then(
                                                              (value) =>
                                                                  setState(
                                                                () {
                                                                  packageRequestReplies
                                                                      .removeAt(
                                                                          index);
                                                                  _saving =
                                                                      false;
                                                                },
                                                              ),
                                                            );
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
                                                    },
                                                  );
                                                } else
                                                  _showMessageDialog(
                                                      getTranslatedValues(
                                                          context,
                                                          'offline_user'));
                                              },
                                            ),
                                          );
                                        } else {
                                          // delivered
                                          int carrierId = packageRequestReply
                                              .carry.user!.userId!;
                                          return PackageRequestCard(
                                            isRead: packageRequestReply.isRead,
                                            onTapFunction: () {
                                              _getPackageRequestReplyReadById(
                                                  packageRequestReply, index);
                                            },
                                            actionWidget: Tooltip(
                                              message: getTranslatedValues(
                                                  context, 'delete_button'),
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                              ),
                                            ),
                                            actionButtonVoidCallBack: () async {
                                              InternetConnectionChecker()
                                                  .connectionStatus
                                                  .then((value) =>
                                                      connectionStatus = value);
                                              if (connectionStatus ==
                                                  InternetConnectionStatus
                                                      .connected) {
                                                _turnOnCircularBar();
                                                try {
                                                  await apiAuthProvider
                                                      .deletePackageReply(
                                                          packageRequestReply
                                                              .packageRequestReplyId)
                                                      .then(
                                                        (value) => setState(
                                                          () {
                                                            setState(() {
                                                              packageRequestReplies
                                                                  .removeAt(
                                                                      index);
                                                            });
                                                          },
                                                        ),
                                                      );
                                                } on DioError catch (error) {
                                                  String errorMessage = HttpNetWork
                                                      .checkNetworkExceptionMessage(
                                                          error, context);
                                                  _showMessageDialog(
                                                      errorMessage);
                                                } finally {
                                                  _turnOffCircularBar();
                                                }
                                              } else
                                                _showMessageDialog(
                                                    getTranslatedValues(context,
                                                        'offline_user'));
                                            },
                                            messageTitle:
                                                '${getTranslatedValues(context, 'delivered')}\n${getTranslatedValues(context, 'click_to_rate_carrier')}',
                                            cardWidget: RequestCard(
                                              requestCarry: packageRequestReply
                                                  .requestCarry,
                                              leftButtonTitle:
                                                  getTranslatedValues(context,
                                                      'contact_carrier_button'),
                                              rightButtonTitle:
                                                  getTranslatedValues(context,
                                                      'rate_carrier_button'),
                                              leftButtonCallback: () =>
                                                  _chatWithCarrier(
                                                      packageRequestReply
                                                          .carry.user!),
                                              rightButtonCallback: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (_) =>
                                                            AddReview(
                                                              userId: carrierId,
                                                              userFirebaseToken:
                                                                  packageRequestReply
                                                                      .carry
                                                                      .user!
                                                                      .firebaseToken!,
                                                            )));
                                              },
                                            ),
                                          );
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _chatWithCarrier(UserModel carrier) async {
    InternetConnectionChecker()
        .connectionStatus
        .then((value) => connectionStatus = value);
    if (connectionStatus == InternetConnectionStatus.connected) {
      _turnOnCircularBar();
      try {
        await apiAuthProvider
            .getChatRoomIdBySenderAndRecipientId(carrier.userId!)
            .then((value) => {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatRoomId: value!,
                        recipient: carrier,
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

  _dismissibleMessage(
      {required PackageRequestReply packageRequestReply,
      required int index,
      required String messageTitle}) {
    {
      return Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          _onPackageRequestReplyDeletion(
              index, packageRequestReply.packageRequestReplyId);
        },
        child: Card(
          margin: EdgeInsets.symmetric(
              vertical: ScreenUtil().setHeight(13),
              horizontal: ScreenUtil().setHeight(20)),
          child: Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(30)),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    if (!packageRequestReply.isRead)
                      Icon(
                        Icons.brightness_1,
                        color: Colors.red,
                      ),
                    Text(
                      messageTitle,
                      style: TextStyles.expandedTitleTextStyle,
                    ),
                    Tooltip(
                      message: getTranslatedValues(context, 'delete_button'),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                        onPressed: () => _onPackageRequestReplyDeletion(
                            index, packageRequestReply.packageRequestReplyId),
                      ),
                    ),
                  ],
                ),
                RequestCarryInfo(
                  requestCarry: packageRequestReply.requestCarry,
                ),
              ],
            ),
          ),
          color: Theme.of(context).brightness == Brightness.light
              ? Palette.lightGrey
              : Theme.of(context).copyWith().cardColor,
          // color: Theme.of(context).brightness == Brightness.light ? Palette.lightGrey : Palette.deepGrey,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
//                                        margin: EdgeInsets.only(
//                                            bottom: ScreenUtil().setHeight(10)),
        ),
      );
    }
  }

  _getPackageRequestReplyReadById(
      PackageRequestReply packageRequestReply, int index) {
    {
      try {
        apiAuthProvider
            .getPackageRequestReplyReadById(
                packageRequestReply.packageRequestReplyId)
            .then((_) => setState(() {
                  packageRequestReply.isRead = true;
                }));
      } on DioError catch (error) {
        String errorMessage =
            HttpNetWork.checkNetworkExceptionMessage(error, context);
        _showMessageDialog(errorMessage);
      }
    }
  }

  _showSnackBar(context) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text(getTranslatedValues(context, 'message_deleted')),
      action: SnackBarAction(
        label: '',
        onPressed: () {},
      ),
    ));
  }

  void _onPackageRequestReplyDeletion(
      int index, int packageRequestReplyId) async {
    InternetConnectionChecker()
        .connectionStatus
        .then((value) => connectionStatus = value);
    if (connectionStatus == InternetConnectionStatus.connected) {
      _turnOnCircularBar();
      try {
        await apiAuthProvider.deletePackageReply(packageRequestReplyId).then(
              (value) => setState(() {
                packageRequestReplies.removeAt(index);
                _saving = false;
                _showSnackBar(context);
              }),
            );
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
              child: Text(getTranslatedValues(context, 'Try Again')),
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
