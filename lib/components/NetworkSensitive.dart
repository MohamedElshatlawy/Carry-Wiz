import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkSensitive extends StatelessWidget {
  final Widget child;
  final double opacity;

  NetworkSensitive({
    required this.child,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    // Get our connection status from the provider
    var connectionStatus;
    InternetConnectionChecker()
        .connectionStatus
        .then((value) => connectionStatus = value);
    if (connectionStatus == InternetConnectionStatus.connected) {
      return child;
    }

    return Opacity(
      opacity: 1,
      child: child,
    );
  }
}
