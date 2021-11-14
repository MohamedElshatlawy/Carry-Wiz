import 'dart:async';

import 'package:country_code_picker/country_code.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:country_code_picker/country_code_picker.dart';
import '../components/gender.dart';
import '../components/body_card.dart';
import '../components/default-app-bar-widget.dart';
import '../components/submit-button.dart';
import '../injector/injector.dart';
import '../screens/my-home-page.dart';
import '../services/HttpNetwork.dart';
import '../themes/palette.dart';
import '../utilities/validations.dart';
import '../models/UserModel.dart';
import '../services/ApiAuthProvider.dart';
import '../utilities/SharedPreferencesManager.dart';
import '../localization/language_constants.dart';
import '../utilities/text-styles.dart';

class ProfileEditScreen extends StatefulWidget {
  late UserModel? user;

  ProfileEditScreen({required this.user});

  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen>
    with AutomaticKeepAliveClientMixin<ProfileEditScreen> {
  TextEditingController? _nameController;

  TextEditingController? _phoneNumberController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user?.name);
    _dateOfBirthEditingController =
        TextEditingController(text: widget.user?.dateOfBirth);
    _phoneNumberController =
        TextEditingController(text: widget.user?.phoneNumber);
    _apiUser =
        _sharedPreferencesManager.getBool(SharedPreferencesManager.keyApiUser)!;
    _country = widget.user!.country!;
    _countryDialCode = widget.user!.countryDialCode!;
  }

  String? _gender;
  DateTime? _date;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController? _dateOfBirthEditingController;
  String? _name;
  String? _phoneNumber;
  String? _country;
  String _countryDialCode = '+20';

  String? _countryCode;
  bool _autoValidate = false;
  bool _saving = false;
  bool _apiUser = false;

  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  void _enforceFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Date Widget
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: (widget.user!.dateOfBirth == null ||
                widget.user!.dateOfBirth!.isEmpty)
            ? DateTime(1990, 1)
            : DateTime.parse(widget.user!.dateOfBirth!),
        firstDate: DateTime(1950, 1),
        lastDate: DateTime.now().subtract(Duration(days: (5 * 356))),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: Theme.of(context).brightness == Brightness.light
                ? ThemeData.light().copyWith(
                    buttonTheme:
                        ButtonThemeData(colorScheme: ColorScheme.light()),
                    buttonBarTheme: ButtonBarThemeData(
                        buttonTextTheme: ButtonTextTheme.accent),
                    //selection color
                    //dialogBackgroundColor: Colors.white,//Background color
                  )
                : ThemeData.dark().copyWith(),
            child: child!,
          );
        });

    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
        _dateOfBirthEditingController!.text =
            DateFormat('yyyy-MM-dd').format(_date!);
      });
    }
    _enforceFocus();
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

  void _onCountryChange(CountryCode countryCode) {
    setState(() {
      _country = countryCode.name;
      _countryCode = countryCode.code;
      _countryDialCode = countryCode.dialCode!;
    });
    _enforceFocus();
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

  @override
  void dispose() {
    _nameController!.dispose();
    _dateOfBirthEditingController!.dispose();
    _phoneNumberController!.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    var defaultSizedBox = SizedBox(
      height: ScreenUtil().setHeight(35),
    );
    return SafeArea(
      child: ModalProgressHUD(
        inAsyncCall: _saving,
        child: Scaffold(
          appBar: DefaultAppBar(
              title:
                  getTranslatedValues(context, 'profile_edit_app_bar_title')),
          body: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Center(
                  child: BodyCard(
                    topPadding: 90,
                    bottomPadding: 55,
                    leftPadding: 100,
                    rightPadding: 100,
                    widget: Center(
                      child: Form(
                        key: _formKey,
                        autovalidate: _autoValidate,
                        child: Column(
                          children: <Widget>[
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.text,
                              validator: (val) {
                                return Validations.validateName(
                                    _nameController!.text, context);
                              },
                              onSaved: (String? val) {
                                _name = val!;
                              },
                              style: TextStyle(
                                  height: ScreenUtil().setHeight(3),
                                  fontSize: ScreenUtil().setSp(50)),
                              decoration: InputDecoration(
                                labelText: getTranslatedValues(context, 'name'),
                                hintText: getTranslatedValues(context, 'name'),
                                hintStyle: TextStyles.textFieldStyle,
                                prefixIcon: Icon(
                                  Icons.assignment,
                                  color: Palette.lightOrange,
                                  size: ScreenUtil().setSp(45),
                                ),
                                labelStyle: TextStyles.textFieldStyle,
                                errorStyle: TextStyles.errorStyle,
                              ),
                            ),
                            defaultSizedBox,
                            FormField(
                              builder: (FormFieldState state) {
                                return DropdownButtonHideUnderline(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      InputDecorator(
                                        decoration: InputDecoration(
                                          isDense: true,
                                          fillColor: Colors.white,
                                          prefixIcon: Icon(
                                            Icons.location_on,
                                            color: Palette.lightOrange,
                                          ),
                                          suffixIcon: Icon(
                                            Icons.arrow_drop_down,
                                            size: ScreenUtil().setSp(80),
                                          ),
                                          errorStyle: TextStyles.errorStyle,
                                          labelText: getTranslatedValues(
                                              context, 'select_country'),
                                          labelStyle: TextStyles.textFieldStyle,
                                        ),
                                        child: CountryCodePicker(
                                          onChanged: _onCountryChange,
                                          textStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryTextTheme
                                                  .button!
                                                  .color,
                                              fontSize: ScreenUtil().setSp(50)),
                                          textOverflow: TextOverflow.ellipsis,

                                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                          initialSelection: _country != null
                                              ? _country
                                              : 'EG',
                                          favorite: ['+02', 'EG'],
                                          // optional. Shows only country name and flag
                                          showCountryOnly: true,
                                          // optional. Shows only country name and flag when popup is closed.
                                          showOnlyCountryWhenClosed: true,

                                          // optional. aligns the flag and the Text left
                                          alignLeft: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            defaultSizedBox,
                            GestureDetector(
                              onTap: () => _selectDate(context),
                              child: AbsorbPointer(
                                child: TextFormField(
                                  controller: _dateOfBirthEditingController,
                                  style: TextStyle(
                                      height: ScreenUtil().setHeight(3),
                                      fontSize: ScreenUtil().setSp(50)),
                                  validator: (String? val) {
                                    if (val!.length == 0)
                                      return '*date of birth is requires';
                                  },
                                  decoration: InputDecoration(
                                    labelText:
                                        getTranslatedValues(context, 'dob'),
                                    hintText:
                                        getTranslatedValues(context, 'dob'),
                                    errorStyle: TextStyles.errorStyle,
                                    prefixIcon: Icon(
                                      Icons.date_range,
                                      color: Palette.lightOrange,
                                      size: ScreenUtil().setSp(80),
                                    ),
                                    labelStyle: TextStyles.textFieldStyle,
                                  ),
                                ),
                              ),
                            ),
                            defaultSizedBox,
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 2,
                                  child: DropdownButtonHideUnderline(
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        isDense: true,
                                        fillColor: Colors.white,
                                        labelStyle: TextStyles.textFieldStyle,
                                      ),
                                      child: CountryCodePicker(
                                        onChanged: (CountryCode code) {
                                          setState(() {
                                            _countryDialCode = code.dialCode!;
                                          });
                                        },
                                        textStyle: TextStyle(
                                            color: Theme.of(context)
                                                .primaryTextTheme
                                                .button!
                                                .color,
                                            fontSize: ScreenUtil().setSp(50)),
                                        textOverflow: TextOverflow.ellipsis,
                                        // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                        initialSelection:
                                            _countryDialCode == null
                                                ? 'EG'
                                                : _countryDialCode,
                                        favorite: ['+02', 'EG'],
                                        // optional. Shows only country name and flag
                                        showCountryOnly: false,
                                        // optional. Shows only country name and flag when popup is closed.
                                        showOnlyCountryWhenClosed: false,
                                        flagWidth: ScreenUtil().setSp(40),
                                        // optional. aligns the flag and the Text left
                                        alignLeft: true,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    validator: (val) {
                                      return Validations.validatePhone(
                                          _nameController!.text, context);
                                    },
                                    controller: _phoneNumberController,
                                    onSaved: (String? val) {
                                      _phoneNumber = val;
                                      print(_phoneNumber);
                                    },
                                    style: TextStyle(
                                        height: ScreenUtil().setHeight(3),
                                        fontSize: ScreenUtil().setSp(50)),
                                    decoration: InputDecoration(
                                        isDense: true,
                                        labelText: getTranslatedValues(
                                            context, 'phone_number'),
                                        hintText: getTranslatedValues(
                                            context, 'phone_number'),
                                        prefixIcon: Icon(
                                          Icons.local_phone,
                                          color: Palette.lightOrange,
                                        ),
                                        labelStyle: TextStyles.textFieldStyle,
                                        errorStyle: TextStyles.errorStyle,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(6)),
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        )),
                                  ),
                                ),
                              ],
                            ),
                            defaultSizedBox,
                            if (_apiUser)
                              Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Gender(
                                    darkText: true,
                                  )),
                                ],
                              ),
                            SubmitButton(
                              title:
                                  getTranslatedValues(context, 'save_button'),
                              buttonColor: Palette.lightOrange,
                              onPressed: () async {
                                if (_validateInputs()) {
                                  var connectionStatus;
                                  InternetConnectionChecker()
                                      .connectionStatus
                                      .then(
                                          (value) => connectionStatus = value);
                                  if (connectionStatus ==
                                      InternetConnectionStatus.connected) {
                                    _turnOnCircularBar();
                                    if (_apiUser)
                                      widget.user!.gender = Gender.gender;
                                    try {
                                      ApiAuthProvider apiAuthProvider =
                                          ApiAuthProvider();
                                      await apiAuthProvider
                                          .updateUser(
                                              name: _nameController!.text,
                                              country: _country != null
                                                  ? _country!
                                                  : 'مصر',
                                              dateOfBirth:
                                                  _dateOfBirthEditingController!
                                                      .text,
                                              phoneNumber: _phoneNumber!,
                                              countryDialCode: _countryDialCode,
                                              gender: widget.user!.gender!)
                                          .then((value) {
                                        _sharedPreferencesManager.putString(
                                            SharedPreferencesManager
                                                .keyUserName,
                                            _nameController!.text);
                                        Toast.show(
                                            getTranslatedValues(context,
                                                'profile_updated_message'),
                                            context,
                                            duration: Toast.lengthLong,
                                            gravity: Toast.bottom);
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) => MyHomePage(4)));
                                      });
                                    } on DioError catch (error) {
                                      String errorMessage =
                                          HttpNetWork.checkUserExceptionMessage(
                                              error, context);
                                      _showMessageDialog(errorMessage);
                                    } finally {
                                      _turnOffCircularBar();
                                    }
                                  } else
                                    _showMessageDialog(getTranslatedValues(
                                        context, 'offline_user'));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
