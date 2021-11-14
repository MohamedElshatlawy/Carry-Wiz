import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/RequestCarry.dart';
import '../screens/request-details.dart';
import '../themes/palette.dart';
import '../blocs/flight_details_bloc.dart';
import '../data/airport/airport_lookup.dart';
import '../components/stacked-app-bar.dart';
import '../components/body_card.dart';
import '../components/flight-widget.dart';
import '../components/submit-button.dart';
import '../models/airport.dart';
import '../localization/language_constants.dart';

class RequestMovement extends StatefulWidget {
  RequestMovement({
    required this.shippingType,
  });

  final String shippingType;
  static late Airport pickUpAirport;
  static late Airport dropOffAirport;

//  static Airport get pickUpAirport => _pickUpAirport;
//
//  static set pickUpfAirport(Airport pickUpAirport) {
//    _pickUpAirport = pickUpAirport;
//  }
//
//  static Airport get dropOffAirport => _dropOffAirport;
//
//  static set dropOffAirport(Airport dropOffAirport) {
//    _dropOffAirport = dropOffAirport;
//  }

  @override
  _RequestMovementState createState() => _RequestMovementState();
}

class _RequestMovementState extends State<RequestMovement>
    with AutomaticKeepAliveClientMixin<RequestMovement> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var yearFromToday = new DateTime.now().add(new Duration(days: 365));
  AirportLookup _newAirportLookup = new AirportLookup();

  @override
  void initState() {
    super.initState();
    _newAirportLookup.getAirports();
  }

  DateTimePickerLocale _locale = DateTimePickerLocale.en_us;
  String _dateFormat = 'dd-MMMM-yyyy';
  late DateTime _requestDate;
  late String _requestDateValue;
  late String _requestDateFormatted;

  late String _timePickedValue;

  late DateTime _timePicked;
  late String _timePickedFormatted;
  String _timeFormat = 'HH:mm';

  late String _selectedLocation;
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

  void _showRequestDatePicker() {
    print('ok');
    DatePicker.showDatePicker(
      context,
      pickerTheme: DateTimePickerTheme(
        backgroundColor: Theme.of(context).cardColor,
        showTitle: true,
        itemTextStyle: TextStyle(
            color: Theme.of(context).textTheme.bodyText2!.color,
            fontSize: ScreenUtil().setSp(50)),
        confirm: Text('Confirm', style: TextStyle(color: Colors.red)),
        cancel: Text('Cancel', style: TextStyle(color: Colors.cyan)),
      ),
      minDateTime: DateTime.now(),
      maxDateTime: yearFromToday,
      dateFormat: _dateFormat,
      locale: _locale,
      onClose: () => print('----- onClose -----'),
      onCancel: () => print('onCancel'),
      onChange: (dateTime, List<int> index) {
        setState(() {
          _requestDate = dateTime;
        });
      },
      onConfirm: (dateTime, List<int> index) {
        setState(() {
          _requestDateValue = DateFormat('dd MMMM yyyy').format(dateTime);
          _requestDateFormatted = DateFormat('yyyy-MM-dd').format(dateTime);
          print(_requestDateValue);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var defaultSizedBoxHeight = SizedBox(
      height: ScreenUtil().setHeight(25),
    );

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            StackedAppBar(
              title: 'REQUESTS',
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
                          widget.shippingType,
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
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                    ),
                    BodyCard(
                      topPadding: 70,
                      bottomPadding: 70,
                      leftPadding: 80,
                      rightPadding: 80,
                      widget: Column(
                        children: <Widget>[
                          Form(
                              key: _formKey,
                              autovalidate: _autoValidate,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                                                fromAirport: 'Picking Up From',
                                                toAirport: 'Dropping Off To',
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  //Departure Date
                                  _dateWidget('Request Date', _requestDateValue,
                                      _showRequestDatePicker),
                                  defaultSizedBoxHeight,
                                  _titleText('Preferred Time'),
                                  _timePicker(),
                                  defaultSizedBoxHeight,
                                  _titleText('Preferred Pick Up'),
                                  _availableLocationField(),
                                  // Return Date
                                ],
                              )),
                          defaultSizedBoxHeight,
                          Center(
                            child: SubmitButton(
                              title: 'Next',
                              onPressed: () {
                                if (_validateInputs()) {
                                  int pickUpAirportId =
                                      RequestMovement.pickUpAirport.id!;
                                  int dropOffAirportId =
                                      RequestMovement.dropOffAirport.id!;
                                  String shippingTypeVal = widget.shippingType;

                                  RequestCarry requestCarry = new RequestCarry(
                                      shippingType: shippingTypeVal,
                                      pickupAirportId: pickUpAirportId,
                                      dropOffAirportId: dropOffAirportId,
                                      requestDate: _requestDateFormatted,
                                      requestTime: _timePickedFormatted,
                                      pickUpLocation: _selectedLocation);
                                  Navigator.push(
                                    context,
                                    new MaterialPageRoute(
                                      builder: (_) => RequestDetails(
                                        requestCarry: requestCarry,
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPressed() {}

  _titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
//          color: Palette.deepGrey,
          fontSize: ScreenUtil().setSp(50),
          fontWeight: FontWeight.w600),
    );
  }

  _availableLocationField() {
    List<String> terminals =
        getTranslatedValues(context, 'collection_locations_list').split(",");
    return FormField<String>(
      validator: (value) {
        if (value == null)
          return "*select your location";
        else
          return null;
      },
      onSaved: (value) {
        _selectedLocation = value!;
      },
      builder: (
        FormFieldState<String> state,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: ScreenUtil().setWidth(550),
              child: InputDecorator(
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                ),
                child: DropdownButtonHideUnderline(
                    child: Theme(
                  data: Theme.of(context).copyWith(),
                  child: DropdownButton<String>(
//                iconEnabledColor: Palette.deepPurple,
                    hint: Text(
                      'Select location',
                      style: TextStyle(
                          fontSize: ScreenUtil().setSp(50),
//                        color: Palette.deepPurple,
                          fontWeight: FontWeight.w500),
                    ),
                    value: _selectedLocation,
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconSize: 24,
                    elevation: 16,
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(44),
                        fontWeight: FontWeight.w800,
                        color: Palette.deepGrey),
//                underline: Container(
//                  height: 0,
//                ),
                    onChanged: (newValue) {
                      state.didChange(newValue);
                      setState(() {
                        _selectedLocation = newValue!;
                      });
                    },
                    items: terminals.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                )),
              ),
            ),
            // SizedBox(height: 5.0),
            if (state.hasError)
              Text(
                state.errorText!,
                style: TextStyle(
                    color: Colors.redAccent.shade700,
                    fontSize: ScreenUtil().setSp(40)),
              ),
          ],
        );
      },
    );
  }

  _dateWidget(
      String title, String dateValue, GestureTapCallback gestureTapCallback) {
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
              width: ScreenUtil().setWidth(550),
              child: GestureDetector(
                onTap: gestureTapCallback,
                child: AbsorbPointer(
                  child: TextFormField(
                    autofocus: false,
//                    style: TextStyle(color: Colors.deepPurple),
                    keyboardType: TextInputType.datetime,
                    validator: (dateValue) {
                      if (dateValue == null)
                        return getTranslatedValues(context, 'required_field');
                      else
                        return null;
                    },
                    onSaved: (val) {
                      dateValue = val!;
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      labelText: (dateValue == null)
                          ? '${getTranslatedValues(context, 'select')} $title'
                          : dateValue,
                      hintText: title,
                      // errorText: _validateDepartureDate ? '*select date' : null,
                      errorStyle: TextStyle(
                          color: Colors.redAccent.shade700,
                          fontSize: ScreenUtil().setSp(40)),
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

  _timePicker() {
    return FormField<String>(validator: (value) {
      if (value == null)
        return getTranslatedValues(context, 'required_field');
      else
        return null;
    }, onSaved: (value) {
      _timePickedValue = value!;
      print(_timePickedValue);
    }, builder: (FormFieldState<String> state) {
      return Container(
          width: ScreenUtil().setWidth(300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InputDecorator(
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(0.0),
                  // labelText: 'choose a shipping type',
                ),
                child: GestureDetector(
                  onTap: () => {
                    DatePicker.showDatePicker(
                      context,
                      initialDateTime: _timePicked,
                      dateFormat: _timeFormat,
                      pickerMode: DateTimePickerMode.time,
                      // show TimePicker
                      pickerTheme: DateTimePickerTheme(
                        backgroundColor: Theme.of(context).cardColor,
                        showTitle: true,
                        itemTextStyle: TextStyle(
                            color: Theme.of(context).textTheme.bodyText2!.color,
                            fontSize: ScreenUtil().setSp(50)),
                        confirm: Text(
                            getTranslatedValues(context, 'confirm_button'),
                            style: TextStyle(color: Colors.red)),
                        cancel: Text(
                            getTranslatedValues(context, 'cancel_button'),
                            style: TextStyle(color: Colors.cyan)),
                      ),
                      onCancel: () {
                        debugPrint('onCancel');
                      },
                      onChange: (dateTime, List<int> index) {
                        setState(() {
                          _timePicked = dateTime;
                        });
                      },
                      onConfirm: (dateTime, List<int> index) {
                        _timePickedValue = DateFormat.jm().format(dateTime);
                        state.didChange(_timePickedValue);
                        setState(() {
                          _timePickedValue = DateFormat.jm().format(dateTime);
                          _timePickedFormatted =
                              DateFormat('HH:mm').format(dateTime);
                        });
                      },
                    ),
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight
                              .w800), // keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: (_timePickedValue == null)
                            ? getTranslatedValues(context, 'select_time')
                            : _timePickedValue,
                        hintText:
                            getTranslatedValues(context, 'collection_time'),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
//                          color: Palette.deepPurple,
                          fontSize: ScreenUtil().setSp(50),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (state.hasError)
                Text(
                  state.errorText!,
                  style: TextStyle(
                      color: Colors.redAccent.shade700,
                      fontSize: ScreenUtil().setSp(40)),
                ),
            ],
          ));
    });
  }

  @override
  bool get wantKeepAlive => true;
}
