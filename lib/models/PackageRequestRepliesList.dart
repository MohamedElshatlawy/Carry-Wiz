import 'package:Carrywiz/models/PackageRequestReply.dart';

class PackageRequestRepliesList {
  late  List<PackageRequestReply> packageRequestReplyList;

  PackageRequestRepliesList({required this.packageRequestReplyList});

  factory PackageRequestRepliesList.fromJson(List<dynamic> json) {
    List<PackageRequestReply> packageRequestReplyList2 =
        json.map((i) => PackageRequestReply.fromJson(i)).toList();

    return PackageRequestRepliesList(
      packageRequestReplyList: packageRequestReplyList2,
    );
  }
}
