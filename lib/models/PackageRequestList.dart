import 'package:Carrywiz/models/PackageRequest.dart';

class PackageRequestsList {
  late List<PackageRequest> packageRequestList;

  PackageRequestsList({required this.packageRequestList});

  factory PackageRequestsList.fromJson(List<dynamic> json) {
    List<PackageRequest> packageRequestList2 =
        json.map((i) => PackageRequest.fromJson(i)).toList();

    return PackageRequestsList(
      packageRequestList: packageRequestList2,
    );
  }
}
