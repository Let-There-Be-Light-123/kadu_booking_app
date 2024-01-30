import 'dart:async';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:kadu_booking_app/utility/notifications_data.dart';

class MessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _messageController = StreamController<RemoteMessage>.broadcast();

  Stream<RemoteMessage> get messageStream => _messageController.stream;

  void initialize() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Shelter Solutions 360',
          defaultColor: const Color(0xFF9D50DD),
          importance: NotificationImportance.High,
          channelShowBadge: true,
          channelDescription: 'Notification',
        ),
      ],
    );
    await _firebaseMessaging.requestPermission();

    String? fcmToken = await _firebaseMessaging.getToken();
    debugPrint('FCM Token: $fcmToken');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Handling a foreground message: ${message}');
      _messageController.add(message);
      NotificationData().updateMessageData(message);
      _showForegroundNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Handling a message opened app: ${message}');
      _messageController.add(message);
      NotificationData().updateMessageData(message);
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (message != null) {
      debugPrint('Handling a background message: ${message.messageId}');
      NotificationData().updateMessageData(message); // Update global data
    } else {
      debugPrint('Received null background message');
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0, // Provide a unique notification ID
        channelKey: 'basic_channel', // Provide a unique channel key
        title: message.notification!.title ?? '',
        body: message.notification!.body ?? '',
        bigPicture: message.notification!.android?.imageUrl,
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }

  void dispose() {
    _messageController.close();
  }
}
