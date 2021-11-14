import 'package:auto_size_text/auto_size_text.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../components/user-circular-image.dart';
import '../screens/DetailScreen.dart';
import '../models/UserModel.dart';
import '../services/ApiAuthProvider.dart';
import '../services/HttpNetwork.dart';
import '../utilities/text-styles.dart';
import '../localization/language_constants.dart';

class UserData extends StatefulWidget {
  final int userId;

  UserData({required this.userId});

  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  late Future<UserModel?> _user;

  @override
  void initState() {
    super.initState();
    _user = apiAuthProvider.getUserById(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: _user,
      builder: (context, AsyncSnapshot<UserModel?> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
          case ConnectionState.active:
          case ConnectionState.none:
            return Center(child: CircularProgressIndicator());
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
              return Row(
                children: <Widget>[
                  SizedBox(
                    width: ScreenUtil().setWidth(20),
                  ),
                  GestureDetector(
                    child: Hero(
                        tag: 'Profile image',
                        child: UserCircularImage(
                          networkImageURL: snapshot.data!.profileImageUrl!,
                          imageRadius: 100,
                        )

                        // CircleAvatar(
                        //   maxRadius: 30,
                        //   backgroundImage: (_imageFile == null)
                        //       ? NetworkImage(
                        //           _imageUrl,
                        //         )
                        //       : FileImage(
                        //           _imageFile,
                        //         ),
                        // ),
                        ),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return DetailScreen(
                          imageURL: snapshot.data!.profileImageUrl,
                        );
                      }));
                    },
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(60),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AutoSizeText(
                        snapshot.data!.name!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: ScreenUtil().setSp(60),
                            fontWeight: FontWeight.w500),
                      ),
                      AutoSizeText(
                        snapshot.data!.country ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: ScreenUtil().setSp(45.0)),
                      ),
                      AutoSizeText(
                        snapshot.data!.email!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: ScreenUtil().setSp(45.0)),
                      ),
                      AutoSizeText(
                        '${snapshot.data!.countryDialCode}${snapshot.data!.phoneNumber}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: ScreenUtil().setSp(45.0)),
                      ),
                    ],
                  ),
                ],
              );
            }
        }
        return CircularProgressIndicator();
      },
    );
  }
}
