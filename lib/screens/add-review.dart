import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../components/submit-button.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';
import '../screens/profile-info-screen.dart';
import '../services/HttpNetwork.dart';
import '../services/messaging.dart';
import '../controllers/review-controller.dart';
import '../localization/language_constants.dart';

class AddReview extends StatefulWidget {
  final int userId;
  final String userFirebaseToken;

  const AddReview({required this.userId, required this.userFirebaseToken});

  @override
  _AddReviewState createState() => _AddReviewState();
}

class _AddReviewState extends State<AddReview> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late String _reviewTitle;
  late String _reviewMessage;
  late double _rating;
  bool _autoValidate = false;

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

  @override
  Widget build(BuildContext context) {
    final defaultSizedBox = SizedBox(
      height: ScreenUtil().setHeight(50),
    );
    return SafeArea(
      child: Scaffold(
        body: ModalProgressHUD(
          inAsyncCall: _saving,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(maxHeight: MediaQuery.of(context).size.height),
              child: Container(
                padding: EdgeInsets.symmetric(
                    vertical: ScreenUtil().setHeight(20),
                    horizontal: ScreenUtil().setWidth(50)),
                margin: EdgeInsets.symmetric(
                  vertical: ScreenUtil().setHeight(20),
                  horizontal: ScreenUtil().setWidth(100),
                ),
                child: Form(
                  key: _formKey,
                  autovalidate: _autoValidate,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FormField<bool>(
                        validator: (value) {
                          if (value == null)
                            return getTranslatedValues(
                                context, 'required_field');
                          else
                            return null;
                        },
                        builder: (FormFieldState state) {
                          return Column(
                            children: <Widget>[
                              SmoothStarRating(
                                  allowHalfRating: true,
                                  starCount: 5,
                                  size: ScreenUtil().setSp(70),
                                  isReadOnly: false,
                                  onRated: (rating) {
                                    _rating = rating;
                                    setState(() {
                                      state.didChange(true);
                                    });
                                  },
                                  filledIconData: Icons.star,
                                  halfFilledIconData: Icons.star_half,
                                  color: Colors.amber,
                                  borderColor: Colors.amber,
                                  spacing: 0.0),
                              if (state.hasError)
                                Text(
                                  state.errorText!,
                                  style: TextStyles.errorStyle,
                                )
                            ],
                          );
                        },
                      ),
                      defaultSizedBox,
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (String? val) {
                          _reviewTitle = val!;
                        },
                        maxLength: 200,
                        style: TextStyle(height: ScreenUtil().setHeight(3)),
                        decoration: InputDecoration(
                          errorStyle: TextStyles.errorStyle,
                          labelText:
                              getTranslatedValues(context, 'review_title'),
                          hintText:
                              getTranslatedValues(context, 'review_title'),
                          prefixIcon: Icon(
                            Icons.title,
                            color: Palette.lightPurple,
                          ),
                          labelStyle: TextStyle(
                              color: Palette.lightPurple,
                              fontSize: ScreenUtil().setSp(50),
                              fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(6)),
                            borderSide: BorderSide(
                                width: 1,
                                color: Colors.white,
                                style: BorderStyle.solid),
                          ),
                        ),
                      ),
                      defaultSizedBox,
                      TextFormField(
                        keyboardType: TextInputType.text,
                        minLines: 5,
                        maxLines: 10,
                        maxLength: 500,
                        onSaved: (String? val) {
                          _reviewMessage = val!;
                        },
                        decoration: InputDecoration(
                            labelText:
                                getTranslatedValues(context, 'review_message'),
                            hintText:
                                getTranslatedValues(context, 'review_message'),
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                                color: Palette.lightPurple,
                                fontSize: ScreenUtil().setSp(50),
                                fontWeight: FontWeight.w600),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                borderSide: BorderSide(
                                    width: 1,
                                    color: Colors.green,
                                    style: BorderStyle.solid))),
                      ),
                      defaultSizedBox,
                      SubmitButton(
                        title: getTranslatedValues(context, 'submit_button'),
                        onPressed: () async {
                          if (_validateInputs()) {
                            InternetConnectionStatus connectionStatus =
                                await InternetConnectionChecker()
                                    .connectionStatus;

                            if (connectionStatus !=
                                InternetConnectionStatus.connected) {
                              _turnOnCircularBar();

                              try {
                                ReviewController _reviewController =
                                    ReviewController();
                                print(widget.userId);
                                _reviewController
                                    .addReview(
                                        reviewTitle: _reviewTitle,
                                        reviewMessage: _reviewMessage,
                                        rating: _rating,
                                        toUserId: widget.userId)
                                    .then((value) {
                                  Toast.show(
                                      getTranslatedValues(
                                          context, 'review_added'),
                                      context,
                                      duration: Toast.lengthLong,
                                      gravity: Toast.bottom);
                                  Messaging.sendAndRetrieveMessage(
                                      title: 'Requester Rated you',
                                      body:
                                          'Requester added a rating to your profile',
                                      fcmToken: widget.userFirebaseToken);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => ProfileInfo(
                                                userId: widget.userId,
                                              )));
                                });
                              } on DioError catch (error) {
                                String errorMessage =
                                    HttpNetWork.checkNetworkExceptionMessage(
                                        error, context);
                                _showMessageDialog(errorMessage);
                              } finally {
                                _turnOffCircularBar();
                              }
                            }
                          } else
                            _showMessageDialog(
                                getTranslatedValues(context, 'offline_user'));
                        },
                        buttonColor: Palette.lightOrange,
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
