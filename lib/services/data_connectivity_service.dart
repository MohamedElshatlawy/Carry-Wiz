import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'dart:async';

class DataConnectivityService {
  StreamController<InternetConnectionStatus> connectivityStreamController =
      StreamController<InternetConnectionStatus>();

  DataConnectivityService() {
    InternetConnectionChecker().onStatusChange.listen((dataConnectionStatus) {
      connectivityStreamController.add(dataConnectionStatus);
    });
  }

  void dispose() {
    connectivityStreamController.close();
  }

  static const int DEFAULT_PORT = 53;

  static const Duration DEFAULT_TIMEOUT = Duration(seconds: 10);
}
