// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/services/notification_service.dart';

class WeeklyRemindersScreen extends StatefulWidget {
  @override
  _WeeklyRemindersScreenState createState() => _WeeklyRemindersScreenState();
}

class _WeeklyRemindersScreenState extends State<WeeklyRemindersScreen> {
  bool isEnabled = false;
  List<bool> isSelected = [true, false, false, false, false, false, false];
  int daySet = 1;
  TextEditingController textEditingController = TextEditingController();
  TimeOfDay? timeSet;
  Map<String, int> days = {
    'Mon': 1,
    'Tue': 2,
    'Wed': 3,
    'Thu': 4,
    'Fri': 5,
    'Sat': 6,
    'Sun': 7,
  };

  @override
  Widget build(BuildContext context) {
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
                          if (value) {
                            textEditingController.text = timeSet != null
                                ? timeSet!.format(context)
                                : TimeOfDay.now().format(context);
                          }
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
                              initialTime: TimeOfDay.now(),
                            );
                            if (newTime != null) {
                              setState(() {
                                timeSet = newTime;
                                textEditingController.text =
                                    newTime.format(context);
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
                      if (isEnabled) {
                        await flutterLocalNotificationsPlugin.cancelAll();
                        await flutterLocalNotificationsPlugin.zonedSchedule(
                          1,
                          'Weekly reminder',
                          'Please remember to make a recording',
                          nextInstanceOfDateTime(
                            day: daySet,
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
