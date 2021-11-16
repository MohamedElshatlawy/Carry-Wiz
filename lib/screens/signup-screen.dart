import 'dart:async';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:toast/toast.dart';

import '../components/NetworkSensitive.dart';
import '../components/gender.dart';
import '../components/submit-button.dart';
import '../components/switch-buttons.dart';
import '../localization/language_constants.dart';
import '../models/UserModel.dart';
import '../screens/verification-code-screen.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';
import '../utilities/validations.dart';
import '../utilities/vertical_spacing.dart';

class UserRegister extends StatefulWidget {
  final String genderValue = 'Prefer not to say';

  @override
  _UserRegisterState createState() => _UserRegisterState();
}

class _UserRegisterState extends State<UserRegister> {
  late String _gender;
  late DateTime _date;
  String? _dateOnlyValue;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _name;
  late String _email;
  late String _phoneNumber;
  late String _password;
  late String _country = 'مصر';
  late String _countryDialCode = '+20';
  late String _countryCode = 'EG';
  bool _autoValidate = false;
  bool _saving = false;

  var _nameController = TextEditingController();
  var _emailController = TextEditingController();
  var _dateOfBirthEditingController = TextEditingController();
  var _phoneNumberController = TextEditingController();
  var _passwordController = TextEditingController();

  // Date Widget
  Future<void> _selectDate(BuildContext context) async {
    _date = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1),
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
      },
    );

    if (picked != null && picked != _date) {
      print('Date Selected: ${_date.toString()}');
      setState(() {
        _date = picked;
        _dateOnlyValue = DateFormat('yyyy-MM-dd').format(_date);
        _dateOfBirthEditingController.text = _dateOnlyValue!;
        print(_dateOnlyValue);
      });
    }
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
    _country = countryCode.name!;
    _countryDialCode = countryCode.dialCode!;
    setState(() {
      _countryCode = countryCode.code!;
    });
    _enforceFocus();
  }

  void _enforceFocus() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dateOfBirthEditingController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Palette.deepPurple,
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
                // maxHeight: MediaQuery.of(context).size.height
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setHeight(30),
                    horizontal: ScreenUtil().setWidth(25)),
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      RichText(
                        text: TextSpan(
                          text: getTranslatedValues(context, 'carry'),
                          style: TextStyle(
                              fontSize: ScreenUtil().setSp(35),
                              fontWeight: FontWeight.w300,
                              color: Colors.white),
                          children: <TextSpan>[
                            TextSpan(
                              text: getTranslatedValues(context, 'wiz'),
                              style: TextStyle(
                                  fontSize: ScreenUtil().setSp(35),
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      defaultSizedBoxHeight,
                      SwitchButtons(),
                      defaultSizedBoxHeight,
                      Theme(
                        data: ThemeData(
                          primaryColor: Palette.deepPurple,
                          hintColor: Colors.white,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.text,
                          controller: _nameController,
                          style: TextStyle(
                              color: Colors.white,
                              height: ScreenUtil().setHeight(1.5)),
                          validator: (val) {
                            return Validations.validateName(
                                _nameController.text, context);
                          },
                          maxLength: 20,
                          onSaved: (val) {
                            _name = val!;
                          },
                          decoration: InputDecoration(
                              labelText: getTranslatedValues(context, 'name'),
                              hintText: getTranslatedValues(context, 'name'),
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.assignment,
                                color: Palette.lightOrange,
                                size: ScreenUtil().setSp(20),
                              ),
                              counterText: '',
                              labelStyle: TextStyles.textFieldStyle,
                              errorStyle: TextStyles.errorStyle,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Palette.lightOrange, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                      ),
                      SizedBox(
                        height: ScreenUtil().setHeight(30),
                      ),
                      Theme(
                        data: ThemeData(
                          primaryColor: Palette.lightOrange,
                          hintColor: Colors.white,
                        ),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          style: TextStyle(
                              color: Colors.white,
                              height: ScreenUtil().setHeight(1.5)),
                          validator: (val) {
                            return Validations.validateEmail(val!, context);
                          },
                          maxLength: 30,
                          onSaved: (val) {
                            _email = val!.toLowerCase();
                          },
                          decoration: InputDecoration(
                              labelText:
                                  getTranslatedValues(context, 'email_address'),
                              // alignLabelWithHint: true,
                              hintText:
                                  getTranslatedValues(context, 'email_address'),
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.email,
                                color: Palette.lightOrange,
                                size: ScreenUtil().setSp(20),
                              ),
                              counterText: '',
                              labelStyle: TextStyles.textFieldStyle,
                              errorStyle: TextStyles.errorStyle,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Palette.lightOrange, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                      ),
                      FormField(
                        builder: (FormFieldState state) {
                          return DropdownButtonHideUnderline(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                isDense: true,
                                prefixIcon: Icon(
                                  Icons.location_on,
                                  color: Palette.lightOrange,
                                  size: ScreenUtil().setSp(20),
                                ),
                                suffixIcon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                  size: ScreenUtil().setSp(30),
                                ),
                                errorStyle: TextStyles.errorStyle,
                                labelText: getTranslatedValues(
                                    context, 'select_country'),
                                labelStyle: TextStyles.textFieldStyle,
                              ),
                              child: CountryCodePicker(
                                onChanged: _onCountryChange,
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: ScreenUtil().setSp(25)),
                                textOverflow: TextOverflow.ellipsis,
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'EG',
                                favorite: ['+02', 'EG'],
                                // optional. Shows only country name and flag
                                showCountryOnly: true,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: true,
                                // optional. aligns the flag and the Text left
                                alignLeft: true,
                              ),
                            ),
                          );
                        },
                      ),
                      defaultSizedBoxHeight,
                      Row(
                        children: <Widget>[
                          Expanded(
                              child: Gender(
                            darkText: false,
                          )),
                        ],
                      ),
                      defaultSizedBoxHeight,
                      Theme(
                        data: ThemeData(
                          primaryColor: Palette.lightOrange,
                          hintColor: Colors.white,
                        ),
                        child: GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: TextFormField(
                              controller: _dateOfBirthEditingController,
                              style: TextStyle(color: Colors.white, height: 1),
                              validator: (val) {
                                if (val!.length == 0 || val.isEmpty)
                                  return getTranslatedValues(
                                      context, 'required_field');
                              },
                              decoration: InputDecoration(
                                labelText: getTranslatedValues(context, 'dob'),
                                hintText: getTranslatedValues(context, 'dob'),
                                errorStyle: TextStyles.errorStyle,
                                prefixIcon: Icon(
                                  Icons.date_range,
                                  color: Palette.lightOrange,
                                  size: ScreenUtil().setSp(20),
                                ),
                                labelStyle: TextStyles.textFieldStyle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 2,
                            child: DropdownButtonHideUnderline(
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                  fillColor: Colors.white,
                                  isDense: true,
                                ),
                                child: CountryCodePicker(
                                  padding: EdgeInsets.symmetric(vertical: 10),

                                  onChanged: _onCountryChange,
                                  textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: ScreenUtil().setSp(20)),
                                  textOverflow: TextOverflow.ellipsis,
                                  // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                  initialSelection: _countryCode,
                                  favorite: ['+02', 'EG'],
                                  // optional. Shows only country name and flag
                                  showCountryOnly: false,
                                  // optional. Shows only country name and flag when popup is closed.
                                  showOnlyCountryWhenClosed: false,
                                  flagWidth: ScreenUtil().setSp(30),
                                  // optional. aligns the flag and the Text left
                                  alignLeft: true,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Theme(
                              data: ThemeData(
                                primaryColor: Palette.lightOrange,
                                hintColor: Colors.white,
                              ),
                              child: TextFormField(
                                keyboardType: TextInputType.phone,
                                controller: _phoneNumberController,
                                validator: (val) {
                                  return Validations.validatePhone(
                                      _phoneNumberController.text, context);
                                },
                                onSaved: (val) {
                                  _phoneNumber = val!;
                                },
                                onChanged: (val) {
                                  _phoneNumber = val;
                                },
                                style: TextStyle(
                                    color: Colors.white,
                                    height: ScreenUtil().setHeight(1.5)),
                                decoration: InputDecoration(
                                    labelText: getTranslatedValues(
                                        context, 'phone_number'),
                                    hintText: getTranslatedValues(
                                        context, 'phone_number'),
                                    isDense: true,
                                    prefixIcon: Icon(
                                      Icons.local_phone,
                                      color: Palette.lightOrange,
                                      size: ScreenUtil().setSp(20),
                                    ),
                                    labelStyle: TextStyles.textFieldStyle,
                                    hintStyle: TextStyles.textFieldStyle,
                                    errorStyle: TextStyles.errorStyle,
                                    errorMaxLines: 2,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Palette.lightOrange, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                      borderSide:
                                          BorderSide(color: Colors.white),
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                      defaultSizedBoxHeight,
                      Theme(
                        data: ThemeData(
                          primaryColor: Palette.lightOrange,
                          hintColor: Colors.white,
                        ),
                        child: TextFormField(
                          obscureText: true,
                          keyboardType: TextInputType.text,
                          controller: _passwordController,
                          style: TextStyle(
                              color: Colors.white,
                              height: ScreenUtil().setHeight(1.5)),
                          validator: (val) {
                            return Validations.validatePassword(val!, context);
                          },
                          onSaved: (val) {
                            _password = val!;
                          },
                          decoration: InputDecoration(
                              labelText:
                                  getTranslatedValues(context, 'password'),
                              hintText:
                                  getTranslatedValues(context, 'password'),
                              isDense: true,
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Palette.lightOrange,
                                size: ScreenUtil().setSp(20),
                              ),
                              labelStyle: TextStyles.textFieldStyle,
                              errorStyle: TextStyles.errorStyle,
                              errorMaxLines: 5,
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: Palette.lightOrange, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                      ),
                      defaultSizedBoxHeight,
                      NetworkSensitive(
                        child: SubmitButton(
                          title: getTranslatedValues(context, 'continue'),
                          buttonColor: Palette.lightOrange,
                          onPressed: () async {
                            if (_validateInputs()) {
                              // var connectionStatus;
                              // await InternetConnectionChecker()
                              //     .connectionStatus
                              //     .then((value) {
                              //   connectionStatus = value;
                              //   print("connection Status:${value}");
                              // });
                              // if (connectionStatus ==
                              //     InternetConnectionStatus.connected) {
                              // try {
                              // _turnOnCircularBar();
                              // ApiAuthProvider apiAuthProvider =
                              //     ApiAuthProvider();
                              // await apiAuthProvider
                              //     .checkUserUniqueData(
                              //         phoneNumber: _phoneNumber,
                              //         emailAddress: _email)
                              //     .then((value) async {
                              //   await apiAuthProvider
                              //       .sendRegistrationActivationCode(
                              //     email: _email,
                              //     userName: _name,
                              //   )
                              //       .then((activationCode) async {
                              _gender = Gender.gender;
                              UserModel newUser = UserModel(
                                  name: _name,
                                  dateOfBirth: _dateOnlyValue,
                                  gender: _gender,
                                  phoneNumber: _phoneNumber,
                                  countryDialCode: _countryDialCode,
                                  email: _email,
                                  password: _password,
                                  country: _country
                                  // != null ? _country : 'مصر'
                                  );
                              Toast.show(
                                  getTranslatedValues(
                                      context, 'verification_code_sent'),
                                  context,
                                  duration: Toast.lengthLong,
                                  gravity: Toast.bottom);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => VerificationCodeScreen(
                                          userModel: newUser,
                                          // activationCode: activationCode!,
                                          registration: true,
                                        )),
                              );
                              //   });
                              // });
                              // } on DioError catch (error) {
                              //   String errorMessage = '';
                              //   if (error.response
                              //       .toString()
                              //       .contains('phone_number_UNIQUE')) {
                              //     errorMessage = getTranslatedValues(
                              //         context, 'phone_exists');
                              //   } else if (error.response
                              //       .toString()
                              //       .contains('Couldn\'t send email to')) {
                              //     errorMessage =
                              //         '${getTranslatedValues(context, 'couldnot_send_email')} $_email ${getTranslatedValues(context, 'check_email_address')}';
                              //   } else {
                              //     errorMessage =
                              //         HttpNetWork.checkUserExceptionMessage(
                              //             error, context);
                              //   }
                              //   _showMessageDialog(errorMessage);
                              // } finally {
                              //   _turnOffCircularBar();
                              // }
                              // } else {
                              //   _showMessageDialog(getTranslatedValues(
                              //       context, 'offline_user'));
                              // }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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
