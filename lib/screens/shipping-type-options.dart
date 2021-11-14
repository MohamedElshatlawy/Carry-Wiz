import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/request-movement.dart';
import '../themes/palette.dart';
import '../localization/language_constants.dart';

class ShippingTypeOptions extends StatelessWidget {
 late String shippingType;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Container(
                color: Palette.deepPurple,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: ScreenUtil().setHeight(70),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.only(
                          top: ScreenUtil().setHeight(100),
                          bottom: ScreenUtil().setHeight(30)),
                      child: Text(
                          getTranslatedValues(context, 'space_question'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(50))),
                    ),
                    SizedBox(
                      height: ScreenUtil().setHeight(50),
                    ),
                    Card(
                      margin: EdgeInsets.symmetric(
                          horizontal: ScreenUtil().setWidth(130)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            Text(
                              getTranslatedValues(
                                  context, 'explore_your_options'),
                              style: TextStyle(
//                                  color: Palette.deepPurple,
                                  fontWeight: FontWeight.w800),
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(100),
                            ),
                            Row(
                              children: <Widget>[
                                _imagesWidget(context, 'Papers',
                                    'assets/images/request_options/docs.png'),
                                _imagesWidget(context, 'Luggage',
                                    'assets/images/request_options/luggage.png'),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(50),
                            ),
                            Row(
                              children: <Widget>[
                                _imagesWidget(context, 'Medication',
                                    'assets/images/request_options/medication.png'),
                                _imagesWidget(context, 'Tech',
                                    'assets/images/request_options/tech.png'),
                              ],
                            ),
                            SizedBox(
                              height: ScreenUtil().setHeight(50),
                            ),
                            Row(
                              children: <Widget>[
                                _imagesWidget(context, 'Clothing',
                                    'assets/images/request_options/clothing.png'),
                                _imagesWidget(context, 'Others',
                                    'assets/images/request_options/others.png'),
                              ],
                            ),
                          ],
                        ),
                      ),
//                      decoration: BoxDecoration(
////                          color: Colors.white,
//                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(30.0))),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _imagesWidget(
      BuildContext context, String shippingTypeVal, String path) {
    return Expanded(
      child: FlatButton(
        onPressed: () {
          shippingType = shippingTypeVal;
          print(shippingType);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => RequestMovement(
                      shippingType: shippingType,
                    )),
          );
        },
        child: Column(
          children: <Widget>[
            Image.asset(
              path,
              color: Theme.of(context).textTheme.bodyText2!.color,
            ),
          ],
        ),
      ),
    );
  }
}
