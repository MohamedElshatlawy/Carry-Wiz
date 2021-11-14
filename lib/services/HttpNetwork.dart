import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import '../injector/injector.dart';
import '../utilities/Constants.dart';
import '../utilities/DioConnectivityRequestRetrier.dart';
import '../utilities/DioLoggingInterceptors.dart';
import '../utilities/SharedPreferencesManager.dart';
import '../localization/language_constants.dart';

class HttpNetWork {
  static final Dio _dio = Dio();
  final String _baseUrl = Constants.staticURL;
  final String clientId = 'trusted-optiadv-app';
  final String clientSecret = '@ptimalADV0003';
  late int _userId;
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  HttpNetWork() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = 10000; //5s
    _dio.options.receiveTimeout = 5000;
    _userId =
        _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId);
    // _dio.interceptors.add(DioLoggingInterceptors(
    //   _dio,
    //   DioConnectivityRequestRetrier(
    //     dio: _dio,
    //     connectivity: Connectivity(),
    //   ),
    // ));
  }

  Future<dynamic> getData(
      {required String url,
      required List<Map<String, dynamic>> headers}) async {
    var jsonResponse;
    _dio.options.baseUrl = _baseUrl;
    headers == null
        ? null
        : headers[0]['Authorization'] != null
            ? _dio.options.headers = headers[0]
            : _dio.options.headers.clear();

    try {
      final response = await _dio.get('/$url');
      jsonResponse = _handelResponse(response);
    } on DioError catch (e) {
      if (DioErrorType.other == e.type) {
        if (e.message.contains('SocketException')) {
          return jsonResponse = 'internet';
        }
      }
    }
    return jsonResponse;
  }

  Future<dynamic> postData(
      {required FormData formData,
      required Map<String, dynamic> headers,
      required String url}) async {
    _dio.options.headers = headers;

    var jsonResponse;
    Response response = await _dio.post(url, data: formData);
    // jsonResponse = json.decode(response.toString());
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // jsonResponse = json.decode(response.toString());
      return jsonResponse;
    } else {
      return response;
    }
  }

  Future<dynamic> deleteData(
      {required String url,
      required List<Map<String, dynamic>> headers}) async {
    var jsonResponse;
    _dio.options.baseUrl = _baseUrl;

    _dio.options.headers = headers[0];

    Response response = await _dio.delete('/$url').catchError((err) {});
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      jsonResponse = json.decode(response.toString());
      return jsonResponse;
    } else {
      return response;
    }
  }

  dynamic _handelResponse(Response response) {
    switch (response.statusCode!) {
      case 200:
        var responseJson = json.decode(response.toString());
        return responseJson;
      case 400:
        var jsonResponse = 'unauth';
        return jsonResponse;
      case 401:
        var jsonResponse = 'unauth';
        return jsonResponse;
      case 403:
        var jsonResponse = 'unauth';
        return jsonResponse;
      case 500:
        var jsonResponse = 'server error';
        return jsonResponse;

      default:
        var jsonResponse = 'server error';
        return jsonResponse;
    }
  }

  static String checkNetworkErrorString(
      String error, BuildContext context) {
    String errorMessage = '';
    if (error.contains('SocketException'))
      errorMessage = getTranslatedValues(context, 'server_cannot_be_reached');
    else if (error.contains('invalid_token') ||
        error.contains('unauthorized'))
      errorMessage =
          errorMessage = getTranslatedValues(context, 'unauthorized_access');
    // else if (error.contains('NoSuchMethodError') ||
    //     error.type == DioErrorType.response)
    //   getTranslatedValues(context, 'server_down');
    // else if (error.type == DioErrorType.connectTimeout)
    //   errorMessage = getTranslatedValues(context, 'connection_timeout');
    // else if (error.type == DioErrorType.connectTimeout)
      // errorMessage = getTranslatedValues(context, 'receive_timeout');
    else if (error.contains('NoSuchMethodError'))
      getTranslatedValues(context, 'server_down');
    else
      errorMessage = error;
    return errorMessage;
  }

  static String checkNetworkExceptionMessage(
      DioError error, BuildContext context) {
    String errorMessage = '';
    if (error.message.contains('SocketException'))
      errorMessage = getTranslatedValues(context, 'server_cannot_be_reached');
    else if (error.message.contains('invalid_token') ||
        error.message.contains('unauthorized'))
      errorMessage =
          errorMessage = getTranslatedValues(context, 'unauthorized_access');
    else if (error.message.contains('NoSuchMethodError') ||
        error.type == DioErrorType.response)
      getTranslatedValues(context, 'server_down');
    else if (error.type == DioErrorType.connectTimeout)
      errorMessage = getTranslatedValues(context, 'connection_timeout');
    else if (error.type == DioErrorType.connectTimeout)
      errorMessage = getTranslatedValues(context, 'receive_timeout');
    else if (error.message.contains('NoSuchMethodError') ||
        error.type == DioErrorType.response)
      getTranslatedValues(context, 'server_down');
    else
      errorMessage = error.message;
    return errorMessage;
  }

  static String checkUserExceptionMessage(
      DioError error, BuildContext context) {
    String errorMessage = '';
    if (error.response.toString().contains('USER_NOT_FOUND'))
      errorMessage = getTranslatedValues(context, 'couldnot_find_user');
    else if (error.response.toString().contains('email_UNIQUE'))
      errorMessage = getTranslatedValues(context, 'email_exists');
    else if (error.response.toString().contains('Bad credentials'))
      errorMessage = getTranslatedValues(context, 'incorrect_password');
    else if (error.response.toString().contains('USER_NOT_ACTIVE'))
      errorMessage = getTranslatedValues(context, 'account_suspended');
    else if (error.response.toString().contains('USER_NOT_VERIFIED'))
      errorMessage = getTranslatedValues(context, 'account_not_verified');
    else if (error.message.contains('SocketException'))
      errorMessage = getTranslatedValues(context, 'server_cannot_be_reached');
    else if (error.message.contains('invalid_token') ||
        error.message.contains('unauthorized'))
      errorMessage = getTranslatedValues(context, 'unauthorized_access');
    else if (error.type == DioErrorType.connectTimeout)
      errorMessage = getTranslatedValues(context, 'connection_timeout');
    else if (error.type == DioErrorType.receiveTimeout)
      errorMessage = getTranslatedValues(context, 'receive_timeout');
    else if (error.message.contains('NoSuchMethodError') ||
        error.type == DioErrorType.response)
      getTranslatedValues(context, 'server_down');
    else
      errorMessage = error.message;
    return errorMessage;
  }
}
