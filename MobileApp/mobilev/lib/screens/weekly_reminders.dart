// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/services/notification_service.dart';
import 'package:mobilev/models/user_data.dart';

class WeeklyRemindersScreen extends StatefulWidget {
  final bool isEnabled;
  final UserData remindersPreference;
  final int? daySet;
  final TimeOfDay? timeSet;

  WeeklyRemindersScreen({
    required this.isEnabled,
    required this.remindersPreference,
    this.daySet,
    this.timeSet,
  });

  @override
  _WeeklyRemindersScreenState createState() => _WeeklyRemindersScreenState(
        isEnabled: isEnabled,
        remindersPreference: remindersPreference,
        daySet: daySet,
        timeSet: timeSet,
      );
}

class _WeeklyRemindersScreenState extends State<WeeklyRemindersScreen> {
  bool isEnabled;
  UserData remindersPreference;
  int? daySet;
  TimeOfDay? timeSet;
  List<bool> isSelected = [false, false, false, false, false, false, false];
  TextEditingController? textEditingController;
  Map<String, int> days = {
    'Mon': 1,
    'Tue': 2,
    'Wed': 3,
    'Thu': 4,
    'Fri': 5,
    'Sat': 6,
    'Sun': 7,
  };

  _WeeklyRemindersScreenState({
    required this.isEnabled,
    required this.remindersPreference,
    this.daySet,
    this.timeSet,
  });

  @override
  void initState() {
    super.initState();
    daySet = daySet == null ? DateTime.now().weekday : daySet;
    timeSet = timeSet == null ? TimeOfDay.now() : timeSet;
    isSelected[daySet! - 1] = true;
  }

  @override
  Widget build(BuildContext context) {
    textEditingController =
        TextEditingController(text: timeSet!.format(context));
    remindersPreference = UserData(
        domain: 'remindersPreference',
        field1: daySet.toString(),
        field2: (timeSet!.hour < 10 ? '0' : '') +
            timeSet!.hour.toString() +
            ':' +
            (timeSet!.minute < 10 ? '0' : '') +
            timeSet!.minute.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text('Weekly reminders'),
      ),
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enable notifications',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Switch(
                      value: isEnabled,
                      activeColor: kDarkAccentColour,
                      inactiveThumbColor: kCardColour,
                      inactiveTrackColor: kSecondaryTextColour,
                      onChanged: (value) {
                        setState(() {
                          isEnabled = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                if (isEnabled)
                  Row(
                    children: [
                      MyToggleButtons(
                        fields: days.keys.toList(),
                        fontSize: 16.0,
                        isSelected: isSelected,
                        onPressed: (int index) {
                          setState(() {
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                                daySet = days.values.toList()[buttonIndex];
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                            remindersPreference = UserData(
                                domain: 'remindersPreference',
                                field1: daySet.toString(),
                                field2: remindersPreference.field2);
                          });
                        },
                      )
                    ],
                  ),
                SizedBox(height: 30.0),
                if (isEnabled)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 130.0,
                        child: TextFormField(
                          controller: textEditingController,
                          onTap: () async {
                            final TimeOfDay? newTime = await showTimePicker(
                              context: context,
                              initialTime: timeSet ?? TimeOfDay.now(),
                            );
                            if (newTime != null) {
                              setState(() {
                                timeSet = newTime;
                                textEditingController!.text =
                                    newTime.format(context);
                                remindersPreference = UserData(
                                  domain: 'remindersPreference',
                                  field1: remindersPreference.field1,
                                  field2: (timeSet!.hour < 10 ? '0' : '') +
                                      timeSet!.hour.toString() +
                                      ':' +
                                      (timeSet!.minute < 10 ? '0' : '') +
                                      timeSet!.minute.toString(),
                                );
                              });
                            }
                          },
                          readOnly: true,
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'PTMono',
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: FormButton(
                    text: 'Save',
                    buttonColour: kPrimaryColour,
                    textColour: Colors.white,
                    onPressed: () async {
                      await flutterLocalNotificationsPlugin.cancelAll();
                      if (isEnabled) {
                        await flutterLocalNotificationsPlugin.zonedSchedule(
                          1,
                          'Weekly reminder',
                          'Please remember to make a recording',
                          nextInstanceOfDateTime(
                            day: daySet!,
                            hour: timeSet!.hour,
                            minute: timeSet!.minute,
                          ),
                          platformChannelSpecifics,
                          matchDateTimeComponents:
                              DateTimeComponents.dayOfWeekAndTime,
                          androidAllowWhileIdle: true,
                          uiLocalNotificationDateInterpretation:
                              UILocalNotificationDateInterpretation
                                  .absoluteTime,
                        );
                        await UserData.updateUserData(remindersPreference);
                      } else {
                        await UserData.updateUserData(
                          UserData(domain: 'remindersPreference'),
                        );
                      }
                      Navigator.pop(context, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
