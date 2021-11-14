import 'dart:convert';
import 'dart:io';

import 'package:Carrywiz/injector/injector.dart';
import 'package:Carrywiz/models/Carry.dart';
import 'package:Carrywiz/models/CarryResponseList.dart';
import 'package:Carrywiz/models/ChatMessageList.dart';
import 'package:Carrywiz/models/ChatRoomsList.dart';
import 'package:Carrywiz/models/LoginResponse.dart';
import 'package:Carrywiz/models/PackageRequestList.dart';
import 'package:Carrywiz/models/PackageRequestRepliesList.dart';
import 'package:Carrywiz/models/RequestCarriesListResponse.dart';
import 'package:Carrywiz/models/RequestCarry.dart';
import 'package:Carrywiz/models/ReviewResponseList.dart';
import 'package:Carrywiz/models/UserModel.dart';
import 'package:Carrywiz/utilities/Constants.dart';
import 'package:Carrywiz/utilities/SharedPreferencesManager.dart';
import 'package:Carrywiz/models/Token.dart';
import 'package:Carrywiz/models/UserInfo.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class ApiAuthProvider {
  static final Dio _dio = Dio();
  final String _baseUrl = Constants.staticURL;
  final String clientId = 'trusted-optiadv-app';
  final String clientSecret = '@ptimalADV0003';
  late int _userId;
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();

  ApiAuthProvider() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = 15000; //10s
    _dio.options.receiveTimeout = 3000;
    // _userId =
    //     _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId) ??
    //         0;
    _userId = 0;
    // _dio.interceptors.add(
    //   DioLoggingInterceptors(
    //     _dio,
    //     DioConnectivityRequestRetrier(
    //       dio: _dio,
    //       connectivity: Connectivity(),
    //     ),
    //   ),
    // );
  }

  dynamic _handelResponse(Response response) {
    switch (response.statusCode!) {
      case 200:
        // var responseJson = json.decode(response.toString());
        return response;
      case 400:
      case 401:
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

  Future<Token?> authenticate() async {
    print('inside auth token');
    var response;
    response = await _dio.post(
      '/oauth/token',
      data: FormData.fromMap({'grant_type': 'client_credentials'}),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {
          'Authorization': 'Basic ${base64Encode(
            utf8.encode('$clientId:$clientSecret'),
          )}',
        },
      ),
    );
    print('after getting token');
    Token token = Token.fromJson(response.data);
    _sharedPreferencesManager.putString(
        SharedPreferencesManager.keyAccessToken, token.accessToken);
    var responseHandle = _handelResponse(response);
    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return token;
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<LoginResponse?> login(
      {required String email, required String password}) async {
    final response = await _dio.post(
      '/user/userLogin',
      data: FormData.fromMap({
        'email': email,
        'password': password,
      }),
      options: Options(
        headers: {
          'requiresToken': false,
        },
      ),
    );

    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      // If server returns an OK response, parse the JSON.
      return LoginResponse.fromJson(response.data);
    } else if (response.statusCode! == 400) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<UserModel?> getUserById(int userId) async {
    // var response;
    // try {
    final response = await _dio.get(
      '/user/getUser/$userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    // response = _handelResponse(response);
    // } on DioError catch (e) {
    //   if (DioErrorType.DEFAULT == e.type) {
    //     throw DioError(error: e);
    //     if (e.message.contains('SocketException')) {
    //       print('socket');
    //       // return response = 'internet';
    //     }
    //   }
    // }

    // print(response);
    // if (_dio.options.connectTimeout >= 10000) {
    //   print('errrorrrrrrrrrrrrrr response');
    //   throw SocketException('no internet');
    // }
    // var responseData = Map<String, dynamic>.from(response.data);
    int statusCode = response.statusCode!; // return status code is null

    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return UserModel.fromJson(response.data);
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<UserInfo?> getUserInfoByUserId(int userId) async {
    final response = await _dio.get(
      '/userInfo/getUserInfoByUserId/$userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!; // return status code is null

    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return UserInfo.fromJson(response.data);
    } else if (statusCode < 200 || statusCode >= 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<RequestCarriesListResponse?> getAllRequestCarriesByUserId() async {
    final String getAllRequestCarriesByUserIdUrl =
        '/requestCarry/getRequestCarriesByUserId/$_userId';

    final response = await _dio.get(
      '$getAllRequestCarriesByUserIdUrl',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return RequestCarriesListResponse.fromJson(response.data);
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 300 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<ReviewResponseList?> getReviewResponseListByUserId(int userId) async {
    // var response;
    // try {
    final response = await _dio.get(
      '/review/getReviewsByUserId/$userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    if (_dio.options.connectTimeout >= 5000 || response == null) {
      print('object errorrrrrrr');
      // return 'internet';
    }
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');
    if (response.toString().contains('SocketException')) {
      throw SocketException('no internet');
    }
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return ReviewResponseList.fromJson(response.data);
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 300 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<CarryResponseList?> getAllCarriesByUserId() async {
    final getCarriesByUserIdUrl = '/carry/getCarriesByUserId/$_userId';
    final response = await _dio.get(
      '$getCarriesByUserIdUrl',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');

    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return CarryResponseList.fromJson(response.data);
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<CarryResponseList?> getCompletedCarriesByUserId() async {
    final getCarriesByUserIdUrl = '/carry/getCompletedCarriesByUserId/$_userId';
    final response = await _dio.get(
      '$getCarriesByUserIdUrl',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');

    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return CarryResponseList.fromJson(response.data);
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> deleteCarry(int carryId) async {
    final response = await _dio.delete(
      '/carry/deleteCarry/$carryId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');

    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> deleteRequestCarry(int requestCarryId) async {
    final response = await _dio.delete(
      '/requestCarry/deleteRequestCarryById/$requestCarryId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');

    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 300 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<List<dynamic>?> addNewCarry(Carry carry) async {
    List<String>? decodedList = carry.shippingTypes;

    FormData formData = FormData.fromMap({
      'departureAirportId': carry.departureAirportId,
      'arrivalAirportId': carry.arrivalAirportId,
      'departureDate': carry.departureDate,
      'returnDate': carry.returnDate,
      'kilos': carry.kilos,
      'deliveryTime': carry.deliveryTime,
      'deliveryLocation': carry.deliveryLocation,
    });

    for (var i = 0; i < decodedList!.length; i++) {
      formData.fields.add(MapEntry('shippingTypes', carry.shippingTypes![i]));
    }

    final response = await _dio.post(
      '/carry/addCarry/$_userId',
      data: formData,
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    // var responseData = Map<String, dynamic>.from(response.data);
    int statusCode = response.statusCode!;
    if (statusCode != null) {
      if (response.statusCode! == 200) {
        // If server returns an OK response, parse the JSON.
        return response.data;
      } else if (response.statusCode! < 200 ||
          response.statusCode! > 400 ||
          json == null) {
        // If that response was not OK, throw an error.
        throw DioError(
            error: response.statusMessage,
            requestOptions: response.requestOptions);
      }
    }
  }

  Future<CarryResponseList?> getAllMatchedCarries(
      {required int pickUpAirportId,
      required int dropOffAirportId,
      required String requestDate,
      required int kilos,
      required int userId}) async {
    final String getAllMatchedCarriesByUserIdUrl =
        '?pickUpAirportId=$pickUpAirportId&dropOffAirportId=$dropOffAirportId&kilos=$kilos&requestDate=$requestDate&userId=$userId';
    try {
      final response = await _dio.get(
        '/carry/getMatchedCarries/$getAllMatchedCarriesByUserIdUrl',
        options: Options(
          headers: {
            'requiresToken': true,
            'Authorization':
                'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
          },
        ),
      );
      final int statusCode = response.statusCode!;
      if (statusCode == 200) {
        return CarryResponseList.fromJson(response.data);
      } else if (statusCode < 200 || statusCode > 400 || json == null) {
        // If that response was not OK, throw an error.
        throw DioError(
            error: 'Failed to load request carries',
            requestOptions: response.requestOptions);
      }
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
//      _showLoginDialog(errorMessage);
    }
    return null;
  }

  Future<UserModel?> registerUser(UserModel user) async {
    final response = await _dio.post(
      '/user/registerUser',
      data: FormData.fromMap(user.toJson()),
      options: Options(
        headers: {
          'requiresToken': false,
        },
      ),
    );
    print('login success');
    int statusCode = response.statusCode!;
    if (statusCode != null) {
      if (response.statusCode! == 200) {
        // If server returns an OK response, parse the JSON.
        return UserModel.fromJson(response.data);
      } else if (response.statusCode! < 200 ||
          response.statusCode! > 400 ||
          json == null) {
        // If that response was not OK, throw an error.
        throw DioError(
            error: response.statusMessage,
            requestOptions: response.requestOptions);
      }
    }
  }

  Future<UserModel?> registerApiUser(
      {required String apiUID,
      required String name,
      required String email,
      String? phoneNumber,
      required String photoUrl}) async {
    final response = await _dio.post(
      '/user/registerApiUser',
      data: FormData.fromMap({
        'apiUID': apiUID,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'photoUrl': photoUrl,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    print('login success');
    int statusCode = response.statusCode!;
    if (statusCode != null) {
      if (response.statusCode! == 200) {
        // If server returns an OK response, parse the JSON.
        return UserModel.fromJson(response.data);
      } else if (response.statusCode! < 200 ||
          response.statusCode! > 400 ||
          json == null) {
        // If that response was not OK, throw an error.
        throw DioError(
            error: response.statusMessage,
            requestOptions: response.requestOptions);
      }
    }
  }

  Future<void> updateUser(
      {required String name,
      required String country,
      required String dateOfBirth,
      required String phoneNumber,
      required String countryDialCode,
      required String gender}) async {
    final response = await _dio.post(
      '/user/updateUser/$_userId',
      data: FormData.fromMap({
        'name': name,
        'country': country,
        'dateOfBirth': dateOfBirth,
        'phoneNumber': phoneNumber,
        'countryDialCode': countryDialCode,
        'gender': gender,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    print('login success');
    int statusCode = response.statusCode!;
    if (statusCode != null) {
      if (response.statusCode! == 200) {
        // If server returns an OK response, parse the JSON.
        return response.data;
      } else if (response.statusCode! < 200 ||
          response.statusCode! > 400 ||
          json == null) {
        // If that response was not OK, throw an error.
        throw DioError(
            error: response.statusMessage,
            requestOptions: response.requestOptions);
      }
    }
  }

  Future<RequestCarry?> addRequest(
      RequestCarry requestCarry, File? file) async {
    String? fileName;
    if (file != null) {
      fileName = file.path.split('/').last;
    }

    final response = await _dio.post(
      '/requestCarry/addRequestCarry/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
      data: FormData.fromMap({
        'image': file != null
            ? await MultipartFile.fromFile(
                file.path,
                filename: fileName,
              )
            : null,
        "requestDate": requestCarry.requestDate,
        "requestTime": requestCarry.requestTime,
        "pickUpLocation": requestCarry.pickUpLocation,
//        "preferredDelivery": preferredDelivery,
        "kilos": requestCarry.kilos,
        "packageWidth": requestCarry.packageWidth,
        "packageHeight": requestCarry.packageHeight,
        "requestDetailsText": requestCarry.requestDetailsText,
        "requestImageURL": requestCarry.requestImageURL,
        "shippingType": requestCarry.shippingType,
        "pickupAirportId": requestCarry.pickupAirportId,
        "dropOffAirportId": requestCarry.dropOffAirportId,
      }),
    );
    int statusCode = response.statusCode!;
    var responseData = Map<String, dynamic>.from(response.data);
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return RequestCarry.fromJson(responseData);
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    final response = await _dio.post('/user/changePassword',
        data: FormData.fromMap({
          'userId': _userId,
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
        options: Options(
          headers: {
            'requiresToken': true,
            'Authorization':
                'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
          },
        ));
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> forgotPassword(String email) async {
    _dio.options.connectTimeout = 40000;
    final response = await _dio.post(
      '/user/forgotPassword',
      options: Options(
        headers: {
          'requiresToken': false,
        },
      ),
      data: FormData.fromMap({
        'email': email,
      }),
    );
    _dio.options.connectTimeout = 10000;
    int statusCode = response.statusCode!;

    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.

      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> changeEmail(String currentPassword, String newEmail) async {
    final response = await _dio.post('/user/changeEmail/$_userId',
        data: FormData.fromMap({
          'userId': _userId,
          'currentPassword': currentPassword,
          'newEmail': newEmail,
        }),
        options: Options(
          headers: {
            'requiresToken': true,
            'Authorization':
                'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
          },
        ));
    int statusCode = response.statusCode!;

    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<String?> uploadProfileImage(XFile file) async {
    String fileName = file.path.split('/').last;

    FormData data = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      '/user/uploadUserImage/$_userId',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<String?> uploadRequestImage(File file, int requestCarryId) async {
    String fileName = file.path.split('/').last;

    FormData data = FormData.fromMap({
      "image": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
      'requestCarryId': requestCarryId,
      'userId': _userId,
    });

    final response = await _dio.post(
      '/requestCarry/addPackageImage',
      data: data,
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  void removeImage() async {
    final response = await _dio.delete(
      '/user/deleteUserImage/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    var responseData = response.data;
    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.
      return responseData;
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<File?> downloadImage(String fileName) async {
    final response = await _dio.get(
      '/user/downloadProfileImage/$fileName',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    var responseData = response.data;
    if (response.statusCode! == 200) {
      // If server returns an OK response, parse the JSON.

      return responseData;
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<UserModel?> getAllUsers() async {
    try {
      print('getAllUsers');
      final response = await _dio.get('users/user');
      return UserModel.fromJson(response.data);
    } catch (error, stacktrace) {
      _printError(error, stacktrace);
      return null;
    }
  }

  void _printError(error, StackTrace stacktrace) {
    debugPrint('error: $error & stacktrace: $stacktrace');
  }

  Future<void> sendPackageRequest(int requestCarryId, int carryId) async {
    final response = await _dio.post(
      '/packageRequest/sendPackageRequest',
      data: FormData.fromMap({
        'requestCarryId': requestCarryId,
        'carryId': carryId,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<PackageRequestsList?> getPackageRequestsByCarrierId() async {
    final response = await _dio.get(
      '/packageRequest/getPackageRequestsByCarrierId/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return PackageRequestsList.fromJson(response.data);
    } else if (statusCode < 200 || statusCode > 400) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

//   Future<bool> refusePackageRequest(int packageRequestId) async {
//     final response = await _dio.delete(
//       '/packageRequest/refusePackageRequest',
//       data: FormData.fromMap({
//         'packageRequestId': packageRequestId,
//         'carrierId': _userId,
//       }),
//       options: Options(
//         headers: {
//           'requiresToken': true,
//           'Authorization':
//               'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
//         },
//       ),
//     );
//     final int statusCode = response.statusCode!;
//     print('statusCode $statusCode');

//     if (response.statusCode! == 200) {
//       return response.data;
//       // If server returns an OK response, parse the JSON.
// //      print('response data ${response.data}');
//       // carryResponse = CarryResponse.fromJson(json.decode(response.body));
//     } else if (statusCode < 200 || statusCode > 400 || json == null) {
//       // If that response was not OK, throw an error.
//             throw DioError(error: response.statusMessage, requestOptions: response.requestOptions);;
//     }
//     return null;
//   }

  Future<void> confirmPackageRequestPickUp(
      int packageRequestReplyId, int requestCarryId, String qrCode) async {
    final response = await _dio.post(
      '/packageRequestReply/confirmPackageRequestPickUp',
      data: FormData.fromMap({
        'packageRequestReplyId': packageRequestReplyId,
        'requestCarryId': requestCarryId,
        'qrCode': qrCode,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> confirmPackageRequestDelivery(
      int packageRequestId, int requestCarryId, String qrCode) async {
    final response = await _dio.post(
      '/packageRequestReply/confirmPackageRequestDelivery',
      data: FormData.fromMap({
        'packageRequestId': packageRequestId,
        'requestCarryId': requestCarryId,
        'qrCode': qrCode,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> cancelPackageRequestReply(
      int packageRequestReplyId, int carrId, int requestCarryId) async {
    final response = await _dio.delete(
      '/packageRequestReply/cancelPackageRequestReply',
      data: FormData.fromMap({
        'packageRequestReplyId': packageRequestReplyId,
        'carryId': carrId,
        'requestCarryId': requestCarryId
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;

    if (response.statusCode! == 200) {
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> getPackageRequestReadById(int packageRequestId) async {
    final response = await _dio.post(
      '/packageRequest/getPackageRequestReadById/$packageRequestId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> getPackageRequestReplyReadById(int packageRequestId) async {
    final response = await _dio.post(
      '/packageRequestReply/getPackageRequestReplyReadById/$packageRequestId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> deletePackageReply(int packageRequestReplyId) async {
    final response = await _dio.delete(
      '/packageRequestReply/deletePackageRequestReply',
      data: FormData.fromMap({
        'packageRequestReplyId': packageRequestReplyId,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');

    if (response.statusCode! == 200) {
      return response.data;
      // If server returns an OK response, parse the JSON.
//      print('response data ${response.data}');
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> deletePackageRequest(int packageRequestId) async {
    final response = await _dio.delete(
      '/packageRequest/deletePackageRequest/$packageRequestId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    final int statusCode = response.statusCode!;
    print('statusCode $statusCode');

    if (response.statusCode! == 200) {
      return response.data;
      // If server returns an OK response, parse the JSON.
//      print('response data ${response.data}');
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }

  Future<void> sendPackageRequestResponse(
      {required int packageRequestId,
      required int requestCarryId,
      required int carryId,
      required int requestStatus}) async {
    final response = await _dio.post(
      '/packageRequestReply/sendPackageRequestResponse',
      data: FormData.fromMap({
        'packageRequestId': packageRequestId,
        'carrierId': _userId,
        'requestCarryId': requestCarryId,
        'carryId': carryId,
        'requestStatus': requestStatus,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<PackageRequestRepliesList?>
      getPackageRequestRepliesByRequesterId() async {
    final response = await _dio.get(
      '/packageRequestReply/getPackageRequestRepliesByRequesterId/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return PackageRequestRepliesList.fromJson(response.data);
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<ChatRoomsList?> getChatRoomsByUserId() async {
    final response = await _dio.get(
      '/chatRoom/getChatRoomsByUserId/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return ChatRoomsList.fromJson(response.data);
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> deleteChatRoomBySenderId(int chatRoomId) async {
    final response = await _dio.delete(
      '/chatRoom/deleteChatRoomBySenderId/$chatRoomId/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> deleteChatRoomByRecipientId(int chatRoomId) async {
    final response = await _dio.delete(
      '/chatRoom/deleteChatRoomByRecipientId/$chatRoomId/$_userId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<int?> getChatRoomIdBySenderAndRecipientId(int otherUserId) async {
    final response = await _dio.get(
      '/chatRoom/getChatRoomsBySenderAndRecipientId/$_userId/$otherUserId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );

    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Stream<ChatMessagesList> getMessagesByChatRoomId(int chatRoomId) async* {
    // while (true) {
    final response = await _dio.get(
      '/message/getMessagesByChatRoomId/$chatRoomId',
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    await Future.delayed(Duration(seconds: 1));
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      yield ChatMessagesList.fromJson(response.data);
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    // }
  }

  Future<int?> sendMessage(
      {required String messageBody,
      required int recipientId,
      required int chatRoomId}) async {
    final response = await _dio.post(
      '/message/addMessage',
      data: FormData.fromMap({
        'messageBody': messageBody,
        'senderId': _userId,
        'recipientId': recipientId,
        'chatRoomId': chatRoomId,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  void updateFirebaseTokenByUserId(int userId, String fcmToken) async {
    final response = await _dio.post(
      '/user/updateFirebaseTokenByUserId/$userId',
      data: FormData.fromMap({
        'fcmToken': fcmToken,
      }),
      options: Options(
        headers: {
          'requiresToken': true,
          'Authorization':
              'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}'
        },
      ),
    );
    int statusCode = response.statusCode!;
    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
  }

  Future<void> checkUserUniqueData(
      {required String phoneNumber, required String emailAddress}) async {
    final response = await _dio.post(
      '/user/checkUserUniqueData',
      data: FormData.fromMap({
        'phoneNumber': phoneNumber,
        'emailAddress': emailAddress,
      }),
      options: Options(
        headers: {
          'requiresToken': false,
        },
      ),
    );
    int statusCode = response.statusCode!;
    print(statusCode);
    if (statusCode != null) {
      if (response.statusCode! == 200) {
        // If server returns an OK response, parse the JSON.
        return response.data;
      } else if (response.statusCode! < 200 ||
          response.statusCode! > 400 ||
          json == null) {
        // If that response was not OK, throw an error.
        throw DioError(
            error: response.statusMessage,
            requestOptions: response.requestOptions);
      }
    }
  }

  Future<String?> sendRegistrationActivationCode(
      {required String email, required String userName}) async {
    _dio.options.connectTimeout = 60000;
    final response = await _dio.post(
      '/user/sendRegistrationActivationCode',
      data: FormData.fromMap(
        {'email': email, 'userName': userName},
      ),
      options: Options(
        headers: {
          'requiresToken': false,
        },
      ),
    );
    int statusCode = response.statusCode!;

    if (statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
    } else if (statusCode < 200 || statusCode > 400 || json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.statusMessage,
          requestOptions: response.requestOptions);
    }
    return null;
  }
}
