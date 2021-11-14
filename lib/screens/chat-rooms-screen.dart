import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../components/chat-room-card.dart';
import '../injector/injector.dart';
import '../screens/chat-screen.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../utilities/SharedPreferencesManager.dart';
import '../utilities/text-styles.dart';
import '../models/ChatRoom.dart';
import '../models/ChatRoomsList.dart';
import '../models/UserModel.dart';
import '../localization/language_constants.dart';

enum PageEnum {
  Delete,
  google,
  yahoo,
}

class ChatRoomsScreen extends StatefulWidget {
  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen>
    with AutomaticKeepAliveClientMixin<ChatRoomsScreen> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();
  late int _userId;

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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    setState(() {
      chatRoomsList = apiAuthProvider.getChatRoomsByUserId();
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
  void initState() {
    super.initState();
    chatRoomsList = apiAuthProvider.getChatRoomsByUserId();
    _userId =
        _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId);
  }

  late Future<ChatRoomsList?> chatRoomsList;
  List<ChatRoom>? chatRooms;

  void _showMenu(Offset offset, int value) async {
    double left = offset.dx;
    double top = offset.dy;
    await showMenu(
      position: RelativeRect.fromLTRB(left, top, 0, 0),
      context: context,
      items: [
        PopupMenuItem(
          value: value,
          height: ScreenUtil().setHeight(50),
          child: Text("Delete"),
        ),
      ],
      elevation: 8.0,
    );
  }

  bool _showDeletePanel = false;
  String _currText = "";

  _onSelect(int index) {
    setState(() {
      chatRooms!.remove(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                FutureBuilder<ChatRoomsList?>(
                  future: chatRoomsList,
                  builder: (context, AsyncSnapshot<ChatRoomsList?> snapshot) {
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

                          if (connectionStatus !=
                              InternetConnectionStatus.connected) {
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
                          if (snapshot.data!.chatRoomsList.isEmpty) {
                            return Center(
                              child: Text(
                                getTranslatedValues(context, 'no_chats'),
                                style:
                                    TextStyle(fontSize: ScreenUtil().setSp(70)),
                              ),
                            );
                          } else
                            chatRooms = snapshot.data!.chatRoomsList;
                          return Row(
                            children: <Widget>[
                              Expanded(
                                child: ListView.builder(
                                  primary: false,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: chatRooms!.length,
                                  itemBuilder: (context, int index) {
                                    return GestureDetector(
                                      onTap: () {
                                        UserModel chatWithUser =
                                            (chatRooms![index]
                                                        .chatInfo
                                                        .sender
                                                        .userId ==
                                                    _userId)
                                                ? chatRooms![index]
                                                    .chatInfo
                                                    .recipient
                                                : chatRooms![index]
                                                    .chatInfo
                                                    .sender;
                                        if (!_showDeletePanel)
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => ChatScreen(
                                                        chatRoomId:
                                                            chatRooms![index]
                                                                .id,
                                                        recipient: chatWithUser,
                                                      )));
                                        else
                                          setState(() {
                                            _showDeletePanel = false;
                                          });
                                      },
                                      // onLongPress: () {
                                      //   setState(() {
                                      //     _showDeletePanel = true;
                                      //   });
                                      // },
                                      child: ChatRoomCard(
                                        userId: _userId,
                                        chatRoom: chatRooms![index],
                                        showDeletePanel: _showDeletePanel,
                                        onPressedFunction: () {
                                          _showDeleteDialog(
                                              content: getTranslatedValues(
                                                  context, 'delete_alert'),
                                              okFunction: () {
                                                var connectionStatus;
                                                InternetConnectionChecker()
                                                    .connectionStatus
                                                    .then((value) =>
                                                        connectionStatus =
                                                            value);
                                                if (connectionStatus !=
                                                    InternetConnectionStatus
                                                        .connected) {
                                                  try {
                                                    if (chatRooms![index]
                                                            .chatInfo
                                                            .sender
                                                            .userId ==
                                                        _userId) {
                                                      apiAuthProvider
                                                          .deleteChatRoomBySenderId(
                                                              chatRooms![index]
                                                                  .id)
                                                          .then((value) {
                                                        setState(() {
                                                          chatRooms!
                                                              .removeAt(index);
                                                        });
                                                      });
                                                    } else {
                                                      apiAuthProvider
                                                          .deleteChatRoomByRecipientId(
                                                              chatRooms![index]
                                                                  .id)
                                                          .then((value) {
                                                        setState(() {
                                                          chatRooms!
                                                              .removeAt(index);
                                                        });
                                                      });
                                                    }
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
                                              });
                                        },
                                      ),
                                    );
//                                     return Center(
//                                       child: PopupMenuButton<int>(
//                                         offset: Offset.zero,
//                                         onSelected: (_) {
//                                           _showDeleteDialog(
//                                               'Are you sure to delete?', () {
//                                             print(chatRooms![index].id);
//                                             setState(() {
//                                               chatRooms.removeAt(index);
//                                             });
//                                           });
//                                         },
//                                         child: ChatRoomCard(
//                                           userId: _userId,
//                                           chatRoom: chatRooms![index],
//                                         ),
//                                         itemBuilder: (context) =>
//                                             <PopupMenuEntry<int>>[
//                                           PopupMenuItem<int>(
//                                             value: index,
//                                             child: Icon(
//                                               Icons.delete,
//                                               color: Colors.red,
//                                             ),
//                                           ),
// //                                      PopupMenuItem<PageEnum>(
// //                                        value: PageEnum.google,
// //                                        child: Text("Google"),
// //                                      ),
// //                                      PopupMenuItem<PageEnum>(
// //                                        value: PageEnum.yahoo,
// //                                        child: Text("Yahoo"),
// //                                      ),
//                                         ],
//                                       ),
//                                     );
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
              ],
            ),
          ),
        ),
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

  void _showDeleteDialog(
      {required String content, required Function okFunction}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text(getTranslatedValues(context, 'delete_request_alert')),
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
