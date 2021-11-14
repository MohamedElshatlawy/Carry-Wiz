
import 'package:Carrywiz/models/Review.dart';

class ReviewResponseList {
  late List<Review> reviewResponseList;

  ReviewResponseList({required this.reviewResponseList});

  factory ReviewResponseList.fromJson(List<dynamic> json) {
    List<Review> reviewResponseList2 =
        json.map((i) => Review.fromJson(i)).toList();

    return ReviewResponseList(
      reviewResponseList: reviewResponseList2,
    );
  }
}
