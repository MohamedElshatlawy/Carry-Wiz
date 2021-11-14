import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_cupertino_datetime_picker/flutter_cupertino_datetime_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../components/counter-widget.dart';
import '../components/body_card.dart';
import '../components/stacked-app-bar.dart';
import '../components/submit-button.dart';
import '../screens/carry-confirmation-screen.dart';
import '../utilities/vertical_spacing.dart';
import '../models/Carry.dart';
import '../services/ApiAuthProvider.dart';
import '../provider/KilosCounterProvider.dart';
import '../themes/palette.dart';
import '../localization/language_constants.dart';

class CarryAvailability extends StatefulWidget {
  final Carry carry;

  CarryAvailability({required this.carry});

  @override
  _CarryAvailabilityState createState() => _CarryAvailabilityState();
}

class _CarryAvailabilityState extends State<CarryAvailability> {
  ApiAuthProvider apiAuthProvider = ApiAuthProvider();

  late String _shippingValue;
  List<String> _shippingItems = const [
    "Anything",
    "Clothing",
    "Luggage",
    "Papers",
    "Tech",
    "Medication",
    "Others"
  ];
  Set<String> _selectedShippingItems = Set();
  // List<String> _collectionLocations = ["Airport T1",
  //       "Airport T2",
  //       "Airport T3",
  //       "Airport T4"];

  late String _selectedLocation;

  bool _autoValidate = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  late String _timePickedValue;
  late DateTime _timePicked;
  late String _timePickedFormatted;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            StackedAppBar(
              title: getTranslatedValues(context, 'carry_appbar_title'),
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
                          getTranslatedValues(context, 'availability'),
                          style: TextStyle(
                              color: Palette.deepPurple,
                              fontSize: ScreenUtil().setSp(50),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
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
                      topPadding: 50,
                      bottomPadding: 50,
                      leftPadding: 80,
                      rightPadding: 80,
                      widget: _mainWidget(),
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

  Widget _mainWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _titleText(getTranslatedValues(context, 'available_space')),
        CounterWidget(),
        _titleText(getTranslatedValues(context, 'available_shipping_type')),
        Form(
          key: _formKey,
          autovalidate: _autoValidate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _shippingTypesFormField(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _selectedShippingTypeWidget(),
                ],
              ),
              defaultSizedBoxHeight,
              _titleText(getTranslatedValues(context, 'available_time')),
              _timePicker(),
              defaultSizedBoxHeight,
              _titleText(
                getTranslatedValues(context, 'available_location'),
              ),
              _availableLocationField(),
            ],
          ),
        ),
        defaultSizedBoxHeight,
        SubmitButton(
          title: getTranslatedValues(context, 'next_button'),
          buttonColor: Palette.lightOrange,
          onPressed: () async {
            if (_validateInputs()) {
              var counter =
                  Provider.of<KilosCounterProvider>(context, listen: false);
              Carry carry = widget.carry;
              carry.kilos = counter.kilos;
              carry.deliveryTime = _timePickedFormatted;
              carry.deliveryLocation = _selectedLocation;
              carry.shippingTypes = _selectedShippingItems.toList();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CarryConfirmationScreen(
                            carry: carry,
                          )));
            }
          },
        ),
      ],
    );
  }

  Widget _timePicker() {
    return FormField<String>(validator: (value) {
      if (value == null)
        return getTranslatedValues(context, 'required_field');
      else
        return null;
    }, onSaved: (value) {
      _timePickedValue = value!;
    }, builder: (FormFieldState<String> state) {
      return Container(
          width: ScreenUtil().setWidth(300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              InputDecorator(
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(0.0),
                ),
                child: GestureDetector(
                  onTap: () => {
                    DatePicker.showDatePicker(
                      context,
                      initialDateTime: _timePicked,
                      dateFormat: 'HH:mm',
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
                      onConfirm: (dateTime, List<int> index) {
                        _timePickedValue = DateFormat.jm().format(dateTime);
                        state.didChange(_timePickedValue);
                        _timePicked = dateTime;
                        _timePickedFormatted =
                            DateFormat('HH:mm').format(dateTime);
                      },
                    ),
                  },
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: (_timePicked == null)
                            ? getTranslatedValues(context, 'select_time')
                            : _timePickedValue,
                        hintText:
                            getTranslatedValues(context, 'collection_time'),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
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

  _shippingTypesFormField() {
    return FormField<String>(
      validator: (value) {
        if (value == null)
          return getTranslatedValues(context, 'required_field');
        else
          return null;
      },
      onSaved: (value) {
        _shippingValue = value!;
      },
      builder: (
        FormFieldState<String> state,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            InputDecorator(
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(0.0),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text(
                    getTranslatedValues(context, 'select_shipping_types'),
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(50),
                        fontWeight: FontWeight.w500),
                  ),
                  value: _shippingValue,
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(44),
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).textTheme.bodyText2!.color),
                  onChanged: (String? newValue) {
                    state.didChange(newValue);
                    setState(() {
                      _shippingValue = newValue!;
                      if (_shippingValue == 'Anything') {
                        _selectedShippingItems.clear();
                        _selectedShippingItems.add(_shippingValue);
                      }
                      if (!_selectedShippingItems.contains('Anything')) {
                        _selectedShippingItems.add(_shippingValue);
                      }
                    });
                  },
                  underline: Container(
                    height: 0,
                  ),
                  items: getTranslatedValues(context, 'shipping_items_list')
                      .split(",")
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            SizedBox(height: 5.0),
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

  _availableLocationField() {
    return FormField<String>(
      validator: (value) {
        if (value == null)
          return getTranslatedValues(context, 'required_field');
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
            InputDecorator(
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.all(0.0),
              ),
              child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                hint: Text(
                  getTranslatedValues(context, 'choose_shipping_location'),
                  style: TextStyle(
                      fontSize: ScreenUtil().setSp(50),
                      fontWeight: FontWeight.w500),
                ),
                value: _selectedLocation,
                elevation: 16,
                style: TextStyle(
                  fontSize: ScreenUtil().setSp(44),
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).textTheme.bodyText2!.color,
                ),
//                underline: Container(
//                  height: 0,
//                ),
                onChanged: (String? newValue) {
                  state.didChange(newValue);
                  setState(() {
                    _selectedLocation = newValue!;
                  });
                },
                items: getTranslatedValues(context, 'collection_locations_list')
                    .split(",")
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              )),
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

  Widget _selectedShippingTypeWidget() {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.all(0),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: _selectedShippingItems.length,
        itemBuilder: (context, int itemIndex) {
          return Row(
            children: <Widget>[
              Container(
                margin:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(12)),
                padding: EdgeInsets.symmetric(
                    horizontal: ScreenUtil().setWidth(20),
                    vertical: ScreenUtil().setHeight(8)),
                child: Row(
                  children: <Widget>[
                    AutoSizeText(
                      _selectedShippingItems.elementAt(itemIndex),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: ScreenUtil().setSp(12),
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                      minFontSize: 13.0,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(left: ScreenUtil().setHeight(40)),
                      child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedShippingItems.remove(
                                  _selectedShippingItems.elementAt(itemIndex));
                            });
                          },
                          child: Icon(
                            Icons.highlight_off,
                            size: ScreenUtil().setSp(50),
                            color: Colors.white,
                          )),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                    color: Palette.lightViolet,
                    borderRadius: BorderRadius.all(Radius.circular(15))),
              ),
            ],
          );
        },
      ),
    );
  }

  _titleText(String title) {
    return Text(
      title,
      textAlign: TextAlign.left,
      style: TextStyle(
          fontSize: ScreenUtil().setSp(50), fontWeight: FontWeight.w600),
    );
  }
}
