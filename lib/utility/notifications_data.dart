import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationData {
  static final NotificationData _singleton = NotificationData._internal();

  factory NotificationData() {
    return _singleton;
  }

  NotificationData._internal();

  final ValueNotifier<int> _notificationCountNotifier = ValueNotifier<int>(0);

  List<RemoteMessage> _notificationHistory = [];

  ValueNotifier<int> get notificationCountNotifier =>
      _notificationCountNotifier;

  List<RemoteMessage> get notificationHistory => _notificationHistory;

  void updateMessageData(RemoteMessage message) {
    _notificationHistory.add(message);

    debugPrint('Updated message data:');
    debugPrint('Getting message title: ${message.notification?.title}');
    debugPrint('Getting message body: ${message.notification?.body}');
    debugPrint(
        'Checking if there is a message: ${_notificationHistory.isNotEmpty}');

    _notificationCountNotifier.value = _notificationHistory.length;
  }

  void clearMessageData() {
    _notificationHistory.clear();
    debugPrint('Cleared message data');
    _notificationCountNotifier.value = 0;
  }

  int getNotificationCount() {
    return _notificationCountNotifier.value;
  }

  RemoteMessage? getNotificationAtIndex(int index) {
    if (index >= 0 && index < _notificationHistory.length) {
      return _notificationHistory[index];
    }
    return null;
  }

  String? getMessageTitleAtIndex(int index) {
    final notification = getNotificationAtIndex(index);
    return notification?.notification?.title;
  }

  String? getMessageBodyAtIndex(int index) {
    final notification = getNotificationAtIndex(index);
    return notification?.notification?.body;
  }

  bool hasNotifications() {
    return _notificationHistory.isNotEmpty;
  }

  void clearNotificationAtIndex(int index) {
    if (index >= 0 && index < _notificationHistory.length) {
      _notificationHistory.removeAt(index);
      _notificationCountNotifier.value = _notificationHistory.length;
    }
  }

  void clearAllNotifications() {
    _notificationHistory.clear();
    _notificationCountNotifier.value = 0;
  }
}
