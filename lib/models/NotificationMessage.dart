import 'package:flutter/material.dart';

@immutable
class NotificationMessage {
  late String title;
  late String body;

  NotificationMessage({
    required this.title,
    required this.body,
  });
}
