import 'dart:convert';
import 'package:Carrywiz/injector/injector.dart';
import 'package:Carrywiz/services/HttpNetwork.dart';
import 'package:Carrywiz/utilities/SharedPreferencesManager.dart';
import 'package:dio/dio.dart';

class ReviewController {
  final SharedPreferencesManager _sharedPreferencesManager =
      locator<SharedPreferencesManager>();
  final Dio _dio = Dio();
  late int? _userId;
  ReviewController() {
    _userId =
        _sharedPreferencesManager.getInt(SharedPreferencesManager.keyUserId);
  }
  HttpNetWork httpNetWork = HttpNetWork();

  Future<void> addReview(
      {required String reviewTitle,
      required String reviewMessage,
      required double rating,
      required int toUserId}) async {
    Map<String, dynamic> headers = {
      'requiresToken': true,
      'Authorization':
          'Bearer ${_sharedPreferencesManager.getString(SharedPreferencesManager.keyAccessToken)}',
    };

    FormData formData = FormData.fromMap({
      'reviewTitle': reviewTitle,
      'reviewMessage': reviewMessage,
      'rating': rating,
      'toUserId': toUserId,
      'fromUserId': _userId,
    });

    final response = await httpNetWork.postData(
        url: '/review/addReview', headers: headers, formData: formData);
    return response;
  }

  Future<void> downloadReport(
      {required String urlPath,
      required String savePath,
      ProgressCallback? onProgress}) async {
    Response response = await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onProgress,
    );
    // print(response.statusCode);
    // File file = File(savePath);
    // var raf = file.openSync(mode: FileMode.write);
    // // response.data is List<int> type
    // raf.writeFromSync(response.data);
    // print('object');
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return response.data;
      // carryResponse = CarryResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode! < 200 ||
        response.statusCode! > 400 ||
        json == null) {
      // If that response was not OK, throw an error.
      throw DioError(
          error: response.data, requestOptions: response.requestOptions);
    }
  }
}
