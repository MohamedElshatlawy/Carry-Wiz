import 'dart:async';

import 'package:Carrywiz/components/default-app-bar-widget.dart';
import 'package:Carrywiz/injector/injector.dart';
import 'package:Carrywiz/services/ApiAuthProvider.dart';
import 'package:Carrywiz/services/HttpNetwork.dart';
import 'package:Carrywiz/services/messaging.dart';
import 'package:Carrywiz/utilities/Constants.dart';
import 'package:Carrywiz/utilities/SharedPreferencesManager.dart';
import 'package:Carrywiz/utilities/text-styles.dart';
import 'package:Carrywiz/themes/palette.dart';
import 'package:Carrywiz/models/ChatMessageList.dart';
import 'package:Carrywiz/models/UserModel.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import '../localization/language_constants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class ChatScreen extends StatefulWidget {
  int chatRoomId;
  final UserModel recipient;

  ChatScreen({
    required this.chatRoomId,
    required this.recipient,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageTextController = TextEditingController();

  late String _messageText;

//  Emoji emojiIcon;

  ApiAuthProvider _apiAuthProvider = ApiAuthProvider();

  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  @override
  Widget build(BuildContext context) {
    int chatRoomIdState = widget.chatRoomId;
    String? senderName = _sharedPreferencesManager
        .getString(SharedPreferencesManager.keyUserName);
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: DefaultAppBar(
          title: '💬 ️${widget.recipient.name}',
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: <Widget>[
                Container(
                  height: ScreenUtil().setHeight(1430),
                  child: chatRoomIdState != 0
                      ? MessagesStream(
                          chatRoomId: chatRoomIdState,
                        )
                      : Icon(
                          Icons.message,
                          size: ScreenUtil().setSp(100),
                        ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20)),
                        child: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 500,
                          controller: _messageTextController,
                          style: TextStyle(
                              height: ScreenUtil().setHeight(2),
                              fontSize: ScreenUtil().setSp(50)),
                          onChanged: (value) {
                            if (value.toString().trim().length != 0)
                              _messageText = value;
                          },
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: getTranslatedValues(
                                context, 'type_message_hint'),
                            hintStyle: TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: ScreenUtil().setSp(50)),
                            prefixIcon: Icon(
                              Icons.message,
                              color: Theme.of(context).accentColor,
                              size: ScreenUtil().setSp(50),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(60),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          right: ScreenUtil().setWidth(40),
                          bottom: ScreenUtil().setHeight(30)),
                      child: IconButton(
                        onPressed: () async {
                          if (_messageText != null &&
                              _messageText.isNotEmpty &&
                              _messageText != '') {
                            _messageTextController.clear();
                            var connectionStatus;
                            InternetConnectionChecker()
                                .connectionStatus
                                .then((value) => connectionStatus = value);
                            if (connectionStatus !=
                                InternetConnectionStatus.connected) {
                              try {
                                await _apiAuthProvider
                                    .sendMessage(
                                        messageBody: _messageText,
                                        chatRoomId: widget.chatRoomId,
                                        recipientId: widget.recipient.userId!)
                                    .then((value) {
                                  if (chatRoomIdState == 0) {
                                    setState(() {
                                      widget.chatRoomId = value!;
                                    });
                                  }
                                  _messageText = '';
                                  Messaging.sendAndRetrieveMessage(
                                      title: '$senderName sent you a message',
                                      body: _messageText,
                                      fcmToken:
                                          widget.recipient.firebaseToken!);
                                });
                              } on DioError catch (error) {
                                String errorMessage = '';
                                if (error.response
                                    .toString()
                                    .contains('GenericJDBCException')) {
                                  errorMessage = 'Character not allowed';
                                } else {
                                  errorMessage =
                                      HttpNetWork.checkNetworkExceptionMessage(
                                          error, context);
                                }

                                _showMessageDialog(errorMessage);
                              }
                            } else
                              _showMessageDialog(
                                  getTranslatedValues(context, 'offline_user'));
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Theme.of(context).accentColor,
                          size: ScreenUtil().setSp(70),
                        ),
                      ),
                    ),
                  ],
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
}

class MessagesStream extends StatefulWidget {
  final int chatRoomId;

  const MessagesStream({required this.chatRoomId});

  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream> {
  ApiAuthProvider _apiAuthProvider = ApiAuthProvider();

//  StreamController _streamController;
//  Stream _stream;
  late Stream<ChatMessagesList> _chatMessagesList;

  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  late int _userId;

  var _channel;

  @override
  void initState() {
    super.initState();
//    _stream = _streamController.stream;
//    _chatMessagesList = _streamController.stream;
    _chatMessagesList =
        _apiAuthProvider.getMessagesByChatRoomId(widget.chatRoomId);

    _userId =
        _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId);

    // _channel = _getChannel();
  }

  // _getChannel() {
  //   return IOWebSocketChannel.connect(Uri.parse(
  //     '${Constants.staticURL}/message/getMessagesByChatRoomId/${widget.chatRoomId}',
  //   ));
  // }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChatMessagesList>(
      stream: _channel.stream,
      builder: (context, snapshot) {
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

              if (connectionStatus == InternetConnectionStatus.disconnected) {
                errorMessage = 'Oops, you appear to be offline';
              } else {
                errorMessage =
                    HttpNetWork.checkNetworkErrorString(errorMessage, context);
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
              if (snapshot.data!.chatMessages.isEmpty) {
                return Center(
                  child: Text(
                    getTranslatedValues(context, 'no_messages'),
                    style: TextStyle(fontSize: ScreenUtil().setSp(70)),
                  ),
                );
              } else {
                final messages = snapshot.data!.chatMessages.reversed;
                List<MessageBubble> messageBubbles = [];
                for (var message in messages) {
                  final messageText = message.messageBody;
                  final messageSender = message.messageInfo.sender.name;

                  final messageBubble = MessageBubble(
                    sender: messageSender!,
                    text: messageText,
                    isMe: _userId == message.messageInfo.sender.userId,
                    time: DateFormat('dd MMM HH:mm')
                        .format(message.messageInfo.createdAt),
                  );
                  messageBubbles.add(messageBubble);
                }
                return ListView(
                  reverse: true,
                  padding: EdgeInsets.all(ScreenUtil().setWidth(20)),
                  children: messageBubbles,
                );
              }
            }
        }
        return Center(
          child: Text(
            getTranslatedValues(context, 'error_getting_data'),
            style:
                TextStyle(color: Colors.red, fontSize: ScreenUtil().setSp(70)),
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble(
      {required this.sender,
      required this.text,
      required this.isMe,
      required this.time});

  final String sender;
  final String text;
  final String time;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: ScreenUtil().setSp(35),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5.0,
            color: isMe ? Colors.yellow[100] : Colors.grey[300],
            child: Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(20),
                  horizontal: ScreenUtil().setWidth(30)),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      '$text',
                      style: TextStyle(
                        color: isMe ? Palette.darkPurple : Colors.black54,
                        fontSize: ScreenUtil().setSp(45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: ScreenUtil().setHeight(10),
          ),
          Text(
            '$time',
            style: TextStyle(
              fontSize: ScreenUtil().setSp(35),
            ),
          ),
        ],
      ),
    );
  }
}
