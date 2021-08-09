// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/toggle_buttons.dart';
import 'package:mobilev/services/notification_service.dart';
import 'package:mobilev/models/user_data.dart';

class WeeklyRemindersScreen extends StatefulWidget {
  final bool isEnabled;
  final int? daySet;
  final TimeOfDay? timeSet;

  WeeklyRemindersScreen({
    required this.isEnabled,
    this.daySet,
    this.timeSet,
  });

  @override
  _WeeklyRemindersScreenState createState() => _WeeklyRemindersScreenState(
        isEnabled: isEnabled,
        daySet: daySet,
        timeSet: timeSet,
      );
}

class _WeeklyRemindersScreenState extends State<WeeklyRemindersScreen> {
  bool isEnabled;
  int? daySet;
  TimeOfDay? timeSet;
  UserData? remindersPreference;
  List<bool> isSelected = [false, false, false, false, false, false, false];
  TextEditingController? textEditingController;

  _WeeklyRemindersScreenState({
    required this.isEnabled,
    this.daySet,
    this.timeSet,
  });

  @override
  void initState() {
    super.initState();
    // Setting day and time to default values if not initialised
    daySet ??= DateTime.now().weekday;
    timeSet ??= TimeOfDay.now();
    isSelected[daySet! - 1] = true;
    // Creating a default UserData instance (updated in real time) incl. zero padding
    remindersPreference = UserData(
      domain: 'remindersPreference',
      field1: daySet.toString(),
      field2: zeroPadTime(timeSet!),
    );
  }

  String zeroPadTime(TimeOfDay timeSet) {
    return (timeSet.hour < 10 ? '0' : '') +
        timeSet.hour.toString() +
        ':' +
        (timeSet.minute < 10 ? '0' : '') +
        timeSet.minute.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Instantiating TextEditingController within the correct context
    textEditingController =
        TextEditingController(text: timeSet!.format(context));

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
                        fields: List.generate(
                            7, (i) => days.values.toList()[i].substring(0, 3)),
                        fontSize: 16.0,
                        isSelected: isSelected,
                        onPressed: (int index) {
                          setState(() {
                            // Update radio buttons
                            for (int buttonIndex = 0;
                                buttonIndex < isSelected.length;
                                buttonIndex++) {
                              if (buttonIndex == index) {
                                isSelected[buttonIndex] = true;
                                daySet =
                                    int.parse(days.keys.toList()[buttonIndex]);
                              } else {
                                isSelected[buttonIndex] = false;
                              }
                            }
                            // Update UserData tracking value
                            remindersPreference = UserData(
                                domain: 'remindersPreference',
                                field1: daySet.toString(),
                                field2: remindersPreference!.field2);
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
                              initialTime: timeSet!,
                            );
                            if (newTime != null) {
                              setState(() {
                                // Update time set and displayed value
                                timeSet = newTime;
                                textEditingController!.text =
                                    newTime.format(context);
                                // Update UserData tracking value (incl. zero padding)
                                remindersPreference = UserData(
                                  domain: 'remindersPreference',
                                  field1: remindersPreference!.field1,
                                  field2: zeroPadTime(timeSet!),
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
                      // Using the plugin initialised in main.dart
                      await cancelAllNotifications();
                      if (isEnabled) {
                        await scheduleNotification(daySet!, timeSet!);
                        await UserData.updateUserData(remindersPreference!);
                      } else {
                        // Set day/time to null
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
