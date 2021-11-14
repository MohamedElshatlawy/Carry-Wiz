import 'package:Carrywiz/models/RequestCarry.dart';

class RequestCarriesListResponse {
  final List<RequestCarry> requestCarriesList;

  RequestCarriesListResponse({required this.requestCarriesList});

  factory RequestCarriesListResponse.fromJson(List<dynamic> json) {
    List<RequestCarry> requestCarriesList2 =
        json.map((i) => RequestCarry.fromJson(i)).toList();

    return RequestCarriesListResponse(
      requestCarriesList: requestCarriesList2,
    );
  }
}
