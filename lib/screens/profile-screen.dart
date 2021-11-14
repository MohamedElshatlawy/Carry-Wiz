import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import '../components/NetworkSensitive.dart';
import '../components/body_card.dart';
import '../components/default-app-bar-widget.dart';
import '../components/submit-button.dart';
import '../components/user-circular-image.dart';
import '../injector/injector.dart';
import '../screens/DetailScreen.dart';
import '../screens/profile-edit-screen.dart';
import '../services/HttpNetwork.dart';
import '../utilities/text-styles.dart';
import '../models/UserModel.dart';
import '../services/ApiAuthProvider.dart';
import '../themes/palette.dart';
import '../utilities/SharedPreferencesManager.dart';
import '../localization/language_constants.dart';

class Profile extends StatefulWidget {
  final bool route;

  const Profile(this.route);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile>
    with AutomaticKeepAliveClientMixin<Profile> {
  ApiAuthProvider? _apiAuthProvider = ApiAuthProvider();
  @override
  void initState() {
    super.initState();
    _userModelFuture = _apiAuthProvider!.getUserById(_sharedPreferencesManager
        .getInt(SharedPreferencesManager.keyUserId)) as Future<UserModel>?;
  }

  final double titleFontSize = ScreenUtil().setSp(20);
  final double valuesFontSize = ScreenUtil().setSp(13);
  late Future<UserModel>? _userModelFuture;
  late UserModel _userModel;
  String? _imageUrl;

  XFile? _imageFile;

  // To track the file uploading state
  bool _isUploading = false;
  bool _showUploadBtn = false;
  bool _showRemoveButton = false;
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  void _getImage(BuildContext context, ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
        _showUploadBtn = true;
      });
    }
    // Closes the bottom sheet
    Navigator.pop(context);
  }

  void _resetState() {
    setState(() {
      _isUploading = false;
//      _showRemoveButton = true;
      _showUploadBtn = false;
    });
  }

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

  void _openImagePickerModal(BuildContext context) {
    final flatButtonColor = Theme.of(context).primaryColor;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: ScreenUtil().setHeight(400),
            child: Column(
              children: <Widget>[
                Text(
                  getTranslatedValues(context, 'pick_image'),
                  style: TextStyle(
                    fontSize: ScreenUtil().setSp(40),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(35),
                ),
                FlatButton(
                    textColor: flatButtonColor,
                    child: Text(getTranslatedValues(context, 'open_camera'),
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: ScreenUtil().setSp(35))),
                    onPressed: () => _getImage(context, ImageSource.camera)),
                FlatButton(
                    textColor: flatButtonColor,
                    child: Text(
                      getTranslatedValues(context, 'open_gallery'),
                      style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontSize: ScreenUtil().setSp(35)),
                    ),
                    onPressed: () => _getImage(context, ImageSource.gallery)),
              ],
            ),
          );
        });
  }

  Widget _buildUploadBtn() {
    Widget btnWidget = Container();
    if (_isUploading) {
      // File is being uploaded then show a progress indicator
      btnWidget = Container(child: CircularProgressIndicator());
    } else if (!_isUploading && _showUploadBtn) {
      // If image is picked by the user then show a upload btn
      btnWidget = Container(
        padding: EdgeInsets.all(0),
        width: ScreenUtil().setWidth(160),
        child: ButtonTheme(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minWidth: ScreenUtil().setWidth(150),
          child: FlatButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil().setWidth(20),
            ),
            child: AutoSizeText(
              getTranslatedValues(context, 'upload_button'),
              maxLines: 1,
              style: TextStyle(fontSize: ScreenUtil().setSp(35)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () async {
              var connectionStatus;
              InternetConnectionChecker()
                  .connectionStatus
                  .then((value) => connectionStatus = value);
              if (connectionStatus == InternetConnectionStatus.connected) {
                _turnOnCircularBar();
                try {
                  setState(() {
                    _isUploading = true;
                  });
                  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
                  await apiAuthProvider
                      .uploadProfileImage(_imageFile!)
                      .then((value) {
                    Toast.show(
                        getTranslatedValues(context, 'image_uploaded_message'),
                        context,
                        duration: Toast.lengthLong,
                        gravity: Toast.bottom);
                  });
                } on DioError catch (error) {
                  String errorMessage =
                      HttpNetWork.checkNetworkExceptionMessage(error, context);
                  _showMessageDialog(errorMessage);
                } finally {
                  _resetState();
                  _turnOffCircularBar();
                }
              } else
                _showMessageDialog(
                    getTranslatedValues(context, 'offline_user'));
            },
            color: Palette.deepPurple,
            textColor: Colors.white,
          ),
        ),
      );
    }
    return btnWidget;
  }

  void _showMessageDialog(String content) async {
    await Future.delayed(Duration(microseconds: 1));
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: DefaultAppBar(
            title: getTranslatedValues(context, 'profile_app_bar_title')),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Center(
                child: BodyCard(
                  topPadding: 70,
                  bottomPadding: 40,
                  leftPadding: 100,
                  rightPadding: 100,
                  widget: _mainWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainWidget() {
    return Column(
      children: <Widget>[
        _imageWidget(),
        SizedBox(
          height: ScreenUtil().setHeight(60),
        ),
        if (widget.route)
          _textRow(
              getTranslatedValues(context, 'name'),
              FutureBuilder<UserModel>(
                future: _userModelFuture,
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.active:
                    case ConnectionState.none:
                      return Center(
                        child: CircularProgressIndicator(),
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
                        _userModel = UserModel(
                            name: snapshot.data!.name,
                            email: snapshot.data!.email,
                            country: snapshot.data!.country,
                            gender: snapshot.data!.gender,
                            dateOfJoin:
                                DateTime.parse('snapshot.data!.dateOfBirth'),
                            phoneNumber: snapshot.data!.phoneNumber);
                        _userModel.name = snapshot.data!.name;

                        return Column(
                          children: [
                            _textRow(
                              getTranslatedValues(context, 'name'),
                              Expanded(
                                child: AutoSizeText(
                                  snapshot.data!.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40)),
                                ),
                              ),
                            ),
                            _dividerWidget(),
                            _textRow(
                                getTranslatedValues(context, 'email'),
                                Expanded(
                                  child: Text(
                                    snapshot.data!.email ?? '',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40)),
                                    maxLines: 1,
                                  ),
                                )),
                            _dividerWidget(),
                            _textRow(
                                getTranslatedValues(context, 'country'),
                                Expanded(
                                  child: AutoSizeText(
                                      snapshot.data!.country ?? '',
                                      style: TextStyle(
                                          fontSize: ScreenUtil().setSp(40)),
                                      overflow: TextOverflow.ellipsis),
                                )),
                            _textRow(
                                getTranslatedValues(context, 'gender'),
                                AutoSizeText(
                                  snapshot.data!.gender ?? '',
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40)),
                                )),
                            _dividerWidget(),
                            _textRow(
                                getTranslatedValues(context, 'number'),
                                Expanded(
                                  child: AutoSizeText(
                                    '${snapshot.data!.countryDialCode}${snapshot.data!.phoneNumber}',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: ScreenUtil().setSp(40)),
                                  ),
                                )),
                            _dividerWidget(),
                            _textRow(
                                getTranslatedValues(context, 'dob'),
                                AutoSizeText(
                                  snapshot.data!.dateOfBirth ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: ScreenUtil().setSp(40)),
                                )),
                            SizedBox(
                              height: ScreenUtil().setHeight(30),
                            ),
                            ButtonTheme(
                              height: ScreenUtil().setHeight(90),
                              child: Container(
                                  width: ScreenUtil().setWidth(500),
                                  child: NetworkSensitive(
                                    child: SubmitButton(
                                        buttonColor: Palette.lightOrange,
                                        title: getTranslatedValues(
                                            context, 'edit_profile_button'),
                                        onPressed: () async {
                                          if (_userModel != null) {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileEditScreen(
                                                            user: _userModel)));
                                          } else
                                            _showMessageDialog(
                                                getTranslatedValues(context,
                                                    'no_profile_data'));
                                        }),
                                  )),
                            ),
                          ],
                        );
                      }
                  }
                  return CircularProgressIndicator();
                },
              )),
      ],
    );
  }

  _textRow(String title, Widget widget) {
    // User routedUser = widget.user;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          width: MediaQuery.of(context).size.width / 3.5,
          child: AutoSizeText(
            title,
            style: TextStyle(
                fontSize: ScreenUtil().setSp(35), fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        widget,
      ],
    );
  }

  Widget _dividerWidget() {
    return Padding(
        padding: EdgeInsets.only(),
        child: Divider(
          thickness: ScreenUtil().setHeight(1.5),
          color: Colors.grey,
          height: ScreenUtil().setHeight(65),
        ));
  }

  Widget _imageWidget() {
//    print('image file $_imageFile + imageUrl $_imageUrl + $_showRemoveButton');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        ButtonTheme(
          minWidth: ScreenUtil().setWidth(400),
          height: ScreenUtil().setHeight(120),
          child: RaisedButton(
            onPressed: (() => _openImagePickerModal(context)),
            textColor: Colors.white,
            color: Color(0xFFF9B107),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              getTranslatedValues(context, 'change_image'),
              style: TextStyle(fontSize: ScreenUtil().setSp(40)),
            ),
          ),
        ),
        if (_showUploadBtn) _buildUploadBtn(),
        FutureBuilder<UserModel>(
          future: _userModelFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError)
                  return CircleAvatar(
                      maxRadius: 30,
                      backgroundImage:
                          AssetImage('assets/images/avatar-default.png'));
                if (snapshot.hasData) {
                  _imageUrl = snapshot.data!.profileImageUrl;
                  // if ((_imageUrl == null ||
                  //         _imageUrl.isEmpty ||
                  //         _imageUrl.length == 0) &&
                  //     _imageFile == null) {
                  //   return CircleAvatar(
                  //       maxRadius: 30,
                  //       backgroundImage:
                  //           AssetImage('assets/images/avatar-default.png'));
                  // } else {
                  return GestureDetector(
                    child: Hero(
                      tag: 'Profile image',
                      child: UserCircularImage(
                        networkImageURL: _imageUrl!,
                        imageRadius: 90,
                      ),
                    ),
                    onTap: () {
                      if (_imageFile != null || _imageUrl != null)
                        Navigator.push(context, MaterialPageRoute(builder: (_) {
                          return DetailScreen(
                            imageURL: _imageUrl,
                            imageFile: File(_imageFile!.path),
                          );
                        }));
                    },
                  );
                  // }

//              if (imageUrl != null) _showRemoveButton = true;
//              return (_imageFile != null)
//                  ? CircleAvatar(
//                      maxRadius: 25,
//                      radius: 25,
//                      backgroundImage: FileImage(_imageFile),
//                    )
//                  : //

                }
            }

            return CircularProgressIndicator();
          },
        ),
      ],
    );
  }

  void _showDialog(String content, String buttonText) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          // title: new Text("Alert Dialog title"),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
