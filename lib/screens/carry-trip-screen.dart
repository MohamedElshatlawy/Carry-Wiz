import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../utilities/vertical_spacing.dart';
import '../models/Carry.dart';
import '../screens/carry_availability.dart';
import '../themes/palette.dart';
import '../utilities/text-styles.dart';
import '../blocs/flight_details_bloc.dart';
import '../models/airport.dart';
import '../data/airport/airport_lookup.dart';
import '../components/body_card.dart';
import '../components/flight-widget.dart';
import '../components/submit-button.dart';
import '../localization/language_constants.dart';

class CarryTrip extends StatefulWidget {
  static late Airport _departureAirport;
  static late Airport _arrivalAirport;

  static Airport get departureAirport => _departureAirport;

  static set departureAirport(Airport departureAirport) {
    _departureAirport = departureAirport;
  }

  static Airport get arrivalAirport => _arrivalAirport;

  static set arrivalAirport(Airport arrivalAirport) {
    _arrivalAirport = arrivalAirport;
  }

  @override
  _CarryTripState createState() => _CarryTripState();
}

class _CarryTripState extends State<CarryTrip>
    with AutomaticKeepAliveClientMixin<CarryTrip> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var yearFromToday = DateTime.now().add(Duration(days: 365));
  AirportLookup _newAirportLookup = AirportLookup();
  bool? _departureDateSelected = false;

  @override
  void initState() {
    super.initState();
    _newAirportLookup.getAirports();
  }

  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;

  String _format = 'yyyy-MMMM-dd';
  late DateTime _departureDate;
  late DateTime _returnDate;
  late String _departureDateValue;
  late String _returnDateValue;

  late String _departureDateFormatted;
  late String _returnDateFormatted;

  bool _autoValidate = false;

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

  void _showDepartureDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        backgroundColor: Theme.of(context).cardColor,
        showTitle: true,
        itemTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyText2!.color,
            fontSize: ScreenUtil().setSp(50)),
        confirm: Text(getTranslatedValues(context, 'confirm_button'),
            style: TextStyle(color: Colors.red)),
        cancel: Text(getTranslatedValues(context, 'cancel_button'),
            style: TextStyle(color: Colors.cyan)),
      ),
      minDateTime: DateTime.now(),
      maxDateTime: (_returnDate == null) ? yearFromToday : _returnDate,
      dateFormat: _format,
      locale: _locale,
      onClose: () => print('----- onClose -----'),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _departureDate = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _departureDate = dateTime;
          _departureDateSelected = true;
          _departureDateValue = DateFormat('dd MMMM yyyy').format(dateTime);
          _departureDateFormatted = DateFormat('yyyy-MM-dd').format(dateTime);
          print(_departureDateValue);
        });
      },
    );
  }

  void _showReturnDatePicker() {
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        backgroundColor: Theme.of(context).cardColor,
        showTitle: true,
        itemTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyText2!.color,
            fontSize: ScreenUtil().setSp(50)),
        confirm: Text(getTranslatedValues(context, 'confirm_button'),
            style: TextStyle(color: Colors.red)),
        cancel: Text(getTranslatedValues(context, 'cancel_button'),
            style: TextStyle(color: Colors.cyan)),
      ),
      minDateTime: _departureDate,
      maxDateTime: yearFromToday,
      initialDateTime: _departureDate,
      dateFormat: _format,
      locale: _locale,
      onClose: () => print('----- onClose -----'),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _returnDate = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _returnDate = dateTime;
          _returnDateValue = DateFormat('dd MMMM yyyy').format(dateTime);
          _returnDateFormatted = DateFormat('yyyy-MM-dd').format(dateTime);
          print(_returnDateValue);
        });
      },
    );
  }

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
                          getTranslatedValues(
                              context, 'when_are_you_travelling'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: ScreenUtil().setSp(50))),
                    ),
                    BodyCard(
                      topPadding: 70,
                      bottomPadding: 70,
                      leftPadding: 80,
                      rightPadding: 80,
                      widget: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Form(
                              key: _formKey,
                              autovalidate: _autoValidate,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: ScreenUtil().setWidth(565),
                                            child: Provider<FlightDetailsBloc>(
                                              create: (context) =>
                                                  FlightDetailsBloc(),
                                              dispose: (context, bloc) =>
                                                  bloc.dispose(),
                                              child: FlightWidget(
                                                airportLookup:
                                                    _newAirportLookup,
                                                fromAirport:
                                                    getTranslatedValues(context,
                                                        'departing_from'),
                                                toAirport: getTranslatedValues(
                                                    context, 'flying_to'),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),

                                  defaultSizedBoxHeight,
                                  //Departure Date
                                  _dateWidget(
                                      getTranslatedValues(
                                          context, 'departure_date'),
                                      _departureDateFormatted,
                                      _showDepartureDatePicker),
                                  defaultSizedBoxHeight,
                                  // Return Date
                                  _dateWidget(
                                      getTranslatedValues(
                                          context, 'return_date'),
                                      _returnDateFormatted,
                                      _showReturnDatePicker)
                                ],
                              )),
                          defaultSizedBoxHeight,
                          Center(
                            child: SubmitButton(
                              title: getTranslatedValues(context, 'next'),
                              onPressed: () {
                                if (_validateInputs()) {
                                  Carry carry = Carry(
                                      departureAirport:
                                          CarryTrip.departureAirport,
                                      arrivalAirport: CarryTrip.arrivalAirport,
                                      departureAirportId:
                                          CarryTrip.departureAirport.id,
                                      arrivalAirportId:
                                          CarryTrip.arrivalAirport.id,
                                      departureDate: _departureDateFormatted,
                                      returnDate: _returnDateFormatted);
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (_) => CarryAvailability(
                                        carry: carry,
                                      ),
                                    ),
                                  );
                                }
                              },
                              buttonColor: Palette.lightOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ),
        ),
      ),
    );
  }

  Widget _dateWidget(
      String title, String? dateValue, GestureTapCallback gestureTapCallback) {
    return ListBody(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(
//              color: Palette.deepGrey,
              fontSize: ScreenUtil().setSp(50),
              fontWeight: FontWeight.bold),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 210,
              child: GestureDetector(
                onTap: () {
                  if (_departureDateSelected!) {
                    gestureTapCallback();
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    autofocus: false,
                    keyboardType: TextInputType.datetime,
                    validator: (String? arg) {
                      if (dateValue == null)
                        return getTranslatedValues(context, 'required_field');
                      else
                        return null;
                    },
                    onSaved: (String? val) {
                      dateValue = val;
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: (dateValue == null)
                          ? '${getTranslatedValues(context, 'select')} $title'
                          : dateValue,
                      hintText: title,
                      // errorText: _validateDepartureDate ? '*select date' : null,
                      errorStyle: TextStyles.errorStyle,
                      labelStyle: TextStyle(
                        fontWeight: FontWeight.w600,
//                        color: Palette.deepPurple,
                        fontSize: ScreenUtil().setSp(50),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
