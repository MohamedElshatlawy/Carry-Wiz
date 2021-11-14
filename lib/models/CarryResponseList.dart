import 'package:Carrywiz/models/Carry.dart';

class CarryResponseList {
  late List<Carry> carryResponsesList;

  CarryResponseList({required this.carryResponsesList});

  factory CarryResponseList.fromJson(List<dynamic> json) {
    List<Carry> carryResponsesList2 =
        json.map((i) => Carry.fromJson(i)).toList();

    return CarryResponseList(
      carryResponsesList: carryResponsesList2,
    );
  }
}
