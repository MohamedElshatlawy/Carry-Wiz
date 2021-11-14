import 'package:flutter/material.dart';
import '../localization/language_constants.dart';

class Validations {
  static String? validateEmail(String value, BuildContext context) {
      RegExp regex = new RegExp(r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    if (value.length == 0 || value.isEmpty) {
      return getTranslatedValues(context, 'required_field');
    } else if (!regex.hasMatch(value) || regex.hasMatch(" ")) {
      return getTranslatedValues(context, 'enter_valid_email');
    } else {
      return null;
    }
  }

  static String? validatePassword(String value, BuildContext context) {
    // Pattern pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z!@#$%&*-_?\d]{8,}$';
    RegExp regex = new RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z!@#$%&*-_?\d]{8,}$');

    if (value.length == 0 || value.isEmpty) {
      return getTranslatedValues(context, 'required_field');
    } else if (!regex.hasMatch(value) || regex.hasMatch(" ")) {
      return getTranslatedValues(context, 'password_pattern');
    } else {
      return null;
    }
  }

  static String? validatePhone(String value, BuildContext context) {
    RegExp regex = new RegExp(r'^(?:)?[0-9]{10,15}$');
    if (value.length == 0 || value.isEmpty) {
      return getTranslatedValues(context, 'required_field');
    } else if (value.startsWith('0') || value.startsWith('+')) {
      return getTranslatedValues(context, 'invalid_phone_number');
    } else if (!regex.hasMatch(value) || regex.hasMatch(" ")) {
      return getTranslatedValues(context, 'phone_number_pattern');
    } else {
      return null;
    }
  }

  static String? validateName(String value, BuildContext context) {
    RegExp regex = new RegExp(r'^[a-zA-Z0-9-_.?\d\s]{3,}$');

    if (value.length == 0 || value.isEmpty) {
      return getTranslatedValues(context, 'required_field');
    } else if (!regex.hasMatch(value)) {
      return getTranslatedValues(context, 'incorrect_input');
    } else
      return null;
  }
}
