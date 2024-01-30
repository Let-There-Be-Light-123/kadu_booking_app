import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kadu_booking_app/theme/color.dart';
import 'package:kadu_booking_app/utility/notifications_data.dart';

class SettingsOverlay extends StatefulWidget {
  final String settingsTitle;

  const SettingsOverlay({Key? key, required this.settingsTitle})
      : super(key: key);

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: AppColors.backgroundColorDefault,
        child: Column(
          children: <Widget>[
            AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  size: 25,
                  color: AppColors.primaryColorOrange,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Text(
                widget.settingsTitle,
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  color: AppColors.textColorPrimary,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.clear_all,
                    size: 25,
                    color: AppColors.primaryColorOrange,
                  ),
                  onPressed: () {
                    _clearNotificationsWithAnimation();
                  },
                ),
              ],
            ),
            // Display notifications using NotificationData
            NotificationsList(),
          ],
        ),
      ),
    );
  }

  void _clearNotificationsWithAnimation() {
    NotificationData().clearMessageData();
    setState(() {
      // Trigger animation for clearing notifications
    });
  }
}

class NotificationsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final notifications = NotificationData().hasNotifications()
        ? NotificationData().notificationHistory
        : [];

    return Expanded(
      child: AnimatedList(
        initialItemCount: notifications.length,
        shrinkWrap: true,
        itemBuilder: (context, index, animation) {
          if (index >= 0 && index < notifications.length) {
            final notification = notifications[index].notification;
            return SlideTransition(
              position: animation.drive(
                Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ),
              ),
              child: ListTile(
                title: Text(notification?.title ?? 'No Title'),
                subtitle: Text(notification?.body ?? 'No Body'),
                // Add more customization to the tile as needed
              ),
            );
          } else {
            return const SizedBox(); // Placeholder for out-of-bounds index
          }
        },
      ),
    );
  }
}
