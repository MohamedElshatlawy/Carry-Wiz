// import 'package:Carrywiz/injector/injector.dart';
// import 'package:Carrywiz/services/ApiAuthProvider.dart';
// import 'package:dio/dio.dart';
// import 'package:dio/adapter.dart';
// import 'dart:io';

// import 'DioConnectivityRequestRetrier.dart';
// import 'SharedPreferencesManager.dart';
// import '../models/Token.dart';

// class DioLoggingInterceptors extends InterceptorsWrapper {
//   final Dio _dio;
//   final SharedPreferencesManager _sharedPreferencesManager =
//       locator<SharedPreferencesManager>();

//   final DioConnectivityRequestRetrier requestRetrier;

//   DioLoggingInterceptors(this._dio, this.requestRetrier);

//   @override
//   Future<dynamic> onRequest(
//       RequestOptions options, RequestInterceptorHandler handler) async {
//     (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
//         (client) {
//       client.badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//       return client;
//     };
//     print("--> ${options.method.toUpperCase()}");
//     print("Headers:");
//     options.headers.forEach((k, v) => print('$k: $v'));
//     print("queryParameters:");
//     options.queryParameters.forEach((k, v) => print('$k: $v'));

//     if (options.headers.containsKey('requiresToken')) {
//       options.headers.remove('requiresToken');
//       print(
//           'accessToken: ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}');
//       String accessToken = _sharedPreferencesManager
//           .getString(SharedPreferencesManager.keyAccessToken);
//       options.headers.addAll({'Authorization': 'Bearer $accessToken'});
//     }
//     return options;
//   }

//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     // print(
//     //     "<-- ${response.statusCode} ${(response.request != null ? (response.request.baseUrl + response.request.path) : 'URL')}");
//     print("Headers:");
//     response.headers.forEach((k, v) => print('$k: $v'));
//     print("Response: ${response.data}");
//     print("<-- END HTTP");
//     return handler.next(response);
//   }

//   bool _shouldRetry(DioError err) {
//     return err.type == DioErrorType.other &&
//         err.error != null &&
//         err.error is SocketException;
//   }

//   @override
//   Future<dynamic> onError(
//       DioError dioError, ErrorInterceptorHandler handler) async {
//     // ""
//     // "${(dioError.response?.request != null ? (dioError.response.request.baseUrl + dioError.response.request.path) : 'URL')}");
//     print(
//         'ERROR[${dioError.response?.statusCode}] => PATH: ${dioError.requestOptions.path}');
//     print(
//         "${dioError.response != null ? dioError.response!.data : 'Unknown Error'}");
//     print("<-- End error");
//     final DioError dioErrorMessage = dioError;
// //     if (_shouldRetry(dioError)) {
// //       try {
// //         print('socket exception error');
// //        return requestRetrier.scheduleRequestRetry(dioError.request);
// //       } catch (e) {
// //         return e;
// //       }
// //     }

//     if (_shouldRetry(dioErrorMessage)) {
//       return dioError;
//     }
//     int responseCode = 0;
//     if (dioError.response!.statusCode == null) {
//       return dioError;
//     }
//     responseCode = dioError.response!.statusCode!;

//     String oldAccessToken = _sharedPreferencesManager
//         .getString(SharedPreferencesManager.keyAccessToken);
//     // print('oldAccessToken $oldAccessToken');

//     if (responseCode == 401) {
//       ApiAuthProvider apiAuthProvider = ApiAuthProvider();
//       RequestOptions? options = dioError.response!.requestOptions;

//       Token? token = await apiAuthProvider.authenticate();

//       await _sharedPreferencesManager.putString(
//           SharedPreferencesManager.keyAccessToken, token!.accessToken);

//       options.headers.addAll({'requiresToken': true});
//       options.headers['Authorization'] = "Bearer " + token.accessToken;
//       return _dio.request(options.path,
//           options: Options(method: options.method));
//     } else {
//       print('inside responseCode error');
//       super.onError(dioError, handler);
//     }
//   }
// }
