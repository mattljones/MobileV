// Dart & Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/profile_card.dart';
import 'package:mobilev/services/notification_service.dart';

import 'package:flutter_native_timezone/flutter_native_timezone.dart';

class ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ListView(
            shrinkWrap: true,
            children: [
              ProfileCard(
                  icon: Icons.share,
                  title: 'Share agreement',
                  status: 'Accepted',
                  route: '/change-password'),
              ProfileCard(
                  icon: Icons.calendar_today_outlined,
                  title: 'Weekly reminders',
                  status: 'Sundays',
                  route: '/change-password'),
              ProfileCard(
                  icon: Icons.lock,
                  title: 'Change password',
                  status: '',
                  route: '/change-password'),
              GestureDetector(
                onTap: () async {
                  await flutterLocalNotificationsPlugin.cancelAll();
                  await flutterLocalNotificationsPlugin.zonedSchedule(
                    1,
                    'Weekly reminder',
                    'Please remember to make a recording.',
                    nextInstanceOfDateTime(day: 1, hour: 19),
                    platformChannelSpecifics,
                    matchDateTimeComponents:
                        DateTimeComponents.dayOfWeekAndTime,
                    androidAllowWhileIdle: true,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                  );
                },
                child: Text('press me'),
              )
            ],
          ),
          FormButton(
            text: 'Sign out',
            buttonColour: kAccentColour,
            textColour: Colors.black,
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}
