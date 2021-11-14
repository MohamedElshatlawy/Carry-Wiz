import 'dart:io';

import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../components/NetworkSensitive.dart';
import '../screens/DetailScreen.dart';
import '../services/HttpNetwork.dart';
import '../themes/palette.dart';
import '../models/RequestCarry.dart';
import '../screens/finding-matched-carry.dart';
import '../services/ApiAuthProvider.dart';
import '../components/stacked-app-bar.dart';
import '../components/body_card.dart';
import '../components/submit-button.dart';
import '../localization/language_constants.dart';

class RequestDetails extends StatefulWidget {
  final RequestCarry requestCarry;

  RequestDetails({required this.requestCarry});

  @override
  _RequestDetailsState createState() => _RequestDetailsState();
}

class _RequestDetailsState extends State<RequestDetails>
    with AutomaticKeepAliveClientMixin<RequestDetails> {
  final double titleFontSize = 14;
  final double valuesFontSize = 13;
  int _availableKilos = 1;
  var _currentSelectedValue = 'cm';
  XFile? _imageFile;
  late double _width;
  late double _height;
  String? _detailsText;

  bool _autoValidate = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isUploading = false;
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

  TextEditingController _detailsTextController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  bool _validateInputs() {
    if (_formKey.currentState!.validate()) {
//    If all data are correct then save data to out variables
      _formKey.currentState!.save();
      return true;
    } else {
//    If all data are not valid then start auto validation.
      setState(() {
        _autoValidate = true;
      });
      return false;
    }
  }

  _incrementKilos() {
    setState(() {
      _availableKilos++;
    });
  }

  _decrementKilos() {
    setState(() {
      if (_availableKilos >= 2) {
        _availableKilos--;
      }
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
                    fontSize: ScreenUtil().setSp(50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: ScreenUtil().setHeight(35),
                ),
                FlatButton(
                    textColor: flatButtonColor,
                    child: Text(getTranslatedValues(context, 'open_camera'),
                        style: TextStyle(color: Colors.amber[800])),
                    onPressed: () => _getImage(context, ImageSource.camera)),
                FlatButton(
                    textColor: flatButtonColor,
                    child: Text(getTranslatedValues(context, 'open_gallery'),
                        style: TextStyle(color: Colors.amber[800])),
                    onPressed: () => _getImage(context, ImageSource.gallery)),
              ],
            ),
          );
        });
  }

  void _getImage(BuildContext context, ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
    // Closes the bottom sheet
    Navigator.pop(context);
  }

  // Future<Map<String, dynamic>> _uploadImage(
  //     File image, int requestCarryId) async {
  //   setState(() {
  //     _isUploading = true;
  //   });
  //   // Find the mime type of the selected file by looking at the header bytes of the file
  //   final mimeTypeData =
  //       lookupMimeType(image.path, headerBytes: [0xFF, 0xD8]).split('/');

  //   // Intilize the multipart request
  //   final imageUploadRequest =
  //       http.MultipartRequest('POST', Uri.parse('/$requestCarryId'));
  //   // Attach the file in the request
  //   final file = await http.MultipartFile.fromPath('image', image.path,
  //       contentType: MediaType(mimeTypeData[0], mimeTypeData[1]));
  //   // Explicitly pass the extension of the image with request body
  //   // Since image_picker has some bugs due which it mixes up
  //   // image extension with file name like this filenamejpge
  //   // Which creates some problem at the server side to manage
  //   // or verify the file extension
  //   imageUploadRequest.fields['ext'] = mimeTypeData[1];
  //   imageUploadRequest.files.add(file);
  //   try {
  //     final streamedResponse = await imageUploadRequest.send();
  //     final response = await http.Response.fromStream(streamedResponse);
  //     final int statusCode = response.statusCode;
  //     print('statusCode $statusCode');
  //     if (statusCode < 200 || statusCode > 400 || json == null) {
  //       throw new Exception('Error while fetching data');
  //     }
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //     _resetState();
  //     return responseData;
  //   } on FormatException catch (e) {
  //     print(e);
  //     return null;
  //   }
  // }

  void _resetState() {
    setState(() {
      _isUploading = false;
    });
  }

  // void _startUploading(int requestCarryId) async {
  //   final Map<String, dynamic> response =
  //       await _uploadImage(_imageFile, requestCarryId);
  //   print('response $response');
  //   _addPackageImageURL = response.toString();
  //   // Check if any error occured
  //   if (response == null || response.containsKey('error')) {
  //     Toast.show('Image Upload Failed!!!', context,
  //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //   } else {
  //     print(response);
  //     Toast.show('Image Uploaded Successfully!!!', context,
  //         duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    double defaultSizedBoxHeight = ScreenUtil().setHeight(40);
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Stack(
            children: <Widget>[
              StackedAppBar(
                title: getTranslatedValues(context, 'requests_title'),
                height: ScreenUtil().setHeight(250),
              ),
              Positioned.fill(
                top: ScreenUtil().setHeight(198),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(550),
                        height: ScreenUtil().setHeight(100),
                        child: Center(
                          child: Text(
                            getTranslatedValues(context, 'luggage'),
                            style: TextStyle(
                                color: Palette.deepPurple,
                                fontSize: ScreenUtil().setSp(50),
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              new BoxShadow(
                                color: Colors.grey,
                                blurRadius: 3.0,
                              ),
                            ],
                            border: Border.all(
                              style: BorderStyle.none,
                              color: Colors.grey,
                            ),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                      ),
                      BodyCard(
                        topPadding: 50,
                        bottomPadding: 50,
                        leftPadding: 50,
                        rightPadding: 50,
                        widget: _mainWidget(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mainWidget() {
    List<String> units = getTranslatedValues(context, 'units_list').split(",");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _titleText(
          getTranslatedValues(context, 'details_about_request'),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(80),
        ),
        _titleText(
          getTranslatedValues(context, 'size'),
        ),
        _counterWidget(),
        SizedBox(
          height: ScreenUtil().setHeight(40),
        ),
        _titleText(
          getTranslatedValues(context, 'dimensions'),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(40),
        ),
        Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.center,
                  maxLength: 5,
                  style: TextStyle(height: 1.35),
                  enableInteractiveSelection: false,
                  validator: (String? val) {
                    if (val!.length == 0) return '';
                  },
                  onSaved: (String? val) {
                    _width = double.parse(val!);
                  },
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                        top: ScreenUtil().setHeight(32),
                        left: ScreenUtil().setWidth(50),
                        right: ScreenUtil().setWidth(50),
                        bottom: ScreenUtil().setWidth(32),
                      ),
                      hintText: getTranslatedValues(context, 'width'),
                      counterText: '',
                      hintStyle: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
                          fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide:
                              BorderSide(width: 1, style: BorderStyle.solid))),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setHeight(35),
                    horizontal: ScreenUtil().setWidth(10)),
                child: Icon(
                  Icons.close,
                ),
              ),
              Expanded(
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  textAlignVertical: TextAlignVertical.center,
                  maxLength: 5,
                  style: TextStyle(height: 1.35),
                  validator: (String? val) {
                    if (val!.length == 0) return '';
                  },
                  onSaved: (String? val) {
                    _height = double.parse(val!);
                  },
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: ScreenUtil().setHeight(32),
                          horizontal: ScreenUtil().setWidth(45)),
                      hintText: getTranslatedValues(context, 'height'),
                      counterText: '',
                      hintStyle: TextStyle(
//                          color: Palette.deepGrey,
                          fontSize: ScreenUtil().setSp(50),
                          fontWeight: FontWeight.w600),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide:
                              BorderSide(width: 1, style: BorderStyle.solid))),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(30),
              ),
              Expanded(child: FormField<String>(
                builder: (FormFieldState<String> state) {
                  return InputDecorator(
                    decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: ScreenUtil().setWidth(20)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: DropdownButtonHideUnderline(
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(canvasColor: Colors.white),
                        child: DropdownButton<String>(
                          value: _currentSelectedValue,
                          style: TextStyle(
                              color: Palette.deepGrey,
                              fontSize: ScreenUtil().setSp(50)),
                          onChanged: (String? newValue) {
                            setState(() {
                              _currentSelectedValue = newValue!;
                              state.didChange(newValue);
                            });
                          },
                          items: <String>['cm', 'inch'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              )),
            ],
          ),
        ),
        Text(
          _autoValidate ? getTranslatedValues(context, 'required_field') : '',
          style: TextStyle(
              color: Colors.redAccent.shade700,
              fontSize: ScreenUtil().setSp(40)),
        ),
        _titleText(
          getTranslatedValues(context, 'details'),
        ),
        SizedBox(
          height: ScreenUtil().setHeight(40),
        ),
        TextFormField(
          autofocus: false,
          keyboardType: TextInputType.text,
          minLines: 2,
          maxLines: 4,
          controller: _detailsTextController,
          decoration: InputDecoration(
              labelStyle: TextStyle(
                  color: Palette.lightPurple,
                  fontSize: ScreenUtil().setSp(50),
                  fontWeight: FontWeight.w600),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                  borderSide: BorderSide(
                      width: 1,
                      color: Colors.green,
                      style: BorderStyle.solid))),
        ),
        FlatButton(
          textColor: Palette.lightPurple,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.camera_alt,
                color: _imageFile != null ? Palette.lightViolet : Colors.grey,
              ),
              SizedBox(
                width: ScreenUtil().setWidth(20),
              ),
              Text(
                getTranslatedValues(context, 'upload_image'),
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(50),
                ),
              ),
              SizedBox(
                width: ScreenUtil().setWidth(50),
              ),
              if (_imageFile != null)
                GestureDetector(
                  child: Hero(
                      tag: 'Package image',
                      child: Container(
                        margin: EdgeInsets.all(ScreenUtil().setHeight(20)),
                        width: ScreenUtil().setWidth(200),
                        height: ScreenUtil().setHeight(200),
                        child: Image.file(File(_imageFile!.path)),
                      )),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) {
                      return DetailScreen(
                        imageFile: File(_imageFile!.path),
                      );
                    }));
                  },
                )
            ],
          ),
          onPressed: (() => _openImagePickerModal(context)),
        ),
        NetworkSensitive(
          child: SubmitButton(
            title: getTranslatedValues(context, 'add_request'),
            buttonColor: Palette.lightOrange,
            onPressed: () async {
              if (_validateInputs()) {
                var connectionStatus;
                InternetConnectionChecker()
                    .connectionStatus
                    .then((value) => connectionStatus = value);
                if (connectionStatus == InternetConnectionStatus.connected) {
                  _turnOnCircularBar();
                  RequestCarry requestCarry = widget.requestCarry;
                  requestCarry.kilos = _availableKilos;
                  requestCarry.packageWidth = _width;
                  requestCarry.packageHeight = _height;
                  requestCarry.requestDetailsText = _detailsTextController.text;
                  if (_imageFile != null) {
                    requestCarry.imageFile = File(_imageFile!.path);
                  }
                  ApiAuthProvider apiAuthProvider = ApiAuthProvider();
                  try {
                    await apiAuthProvider
                        .addRequest(requestCarry, File(_imageFile!.path))
                        .then((requestCarryResponse) {
                      Toast.show(getTranslatedValues(context, 'request_saved'),
                          context,
                          duration: Toast.lengthLong, gravity: Toast.bottom);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FindingMatchedCarry(
                            requestCarry: requestCarryResponse!,
                          ),
                        ),
                      );
                    });
                  } on DioError catch (error) {
                    String errorMessage =
                        HttpNetWork.checkNetworkExceptionMessage(
                            error, context);
                    _showMessageDialog(errorMessage);
                  } finally {
                    _turnOffCircularBar();
                  }
                } else
                  _showMessageDialog(
                      getTranslatedValues(context, 'offline_user'));
              }
            },
          ),
        ),
      ],
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

  Widget _titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
//          color: Palette.deepGrey,
          fontSize: ScreenUtil().setSp(50),
          fontWeight: FontWeight.w600),
    );
  }

  _counterWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(
            Icons.exposure_neg_1,
            size: ScreenUtil().setSp(80),
          ),
          onPressed: () => _decrementKilos(),
        ),
        Container(
          padding: EdgeInsets.all(5),
          child: Text(
            '$_availableKilos' ' ${getTranslatedValues(context, 'kg')}',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.exposure_plus_1,
            size: ScreenUtil().setSp(80),
          ),
          onPressed: () => _incrementKilos(),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
