// Dart & Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/screens/share_agreement.dart';
import 'package:mobilev/screens/weekly_reminders.dart';
import 'package:mobilev/screens/change_password.dart';
import 'package:mobilev/widgets/form_button.dart';
import 'package:mobilev/widgets/profile_card.dart';
import 'package:mobilev/models/user_data.dart';

class ProfileBody extends StatefulWidget {
  @override
  _ProfileBodyState createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool sharePreferenceLoading = true;
  UserData? sharePreference;
  String shareString = '';
  bool remindersPreferenceLoading = true;
  UserData? remindersPreference;
  String remindersString = '';

  @override
  void initState() {
    super.initState();
    getSharePreference();
    getRemindersPreference();
  }

  void getSharePreference() {
    UserData.selectUserData('sharePreference').then((data) {
      setState(() {
        sharePreference = data;
        shareString = sharePreference!.toShareString();
        sharePreferenceLoading = false;
      });
    });
  }

  void getRemindersPreference() {
    UserData.selectUserData('remindersPreference').then((data) {
      setState(() {
        remindersPreference = data;
        remindersString = remindersPreference!.toRemindersString();
        remindersPreferenceLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(35.0),
      child:
          // Show hourglass whilst asynchronous data is loading
          (sharePreferenceLoading || remindersPreferenceLoading)
              ? SpinKitPouringHourglass(
                  color: kSecondaryTextColour,
                )
              // Show content once all asynchronous data loaded
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowGlow();
                        return true;
                      },
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            'Welcome, Matt!',
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'PTSans',
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 15.0),
                          Text(
                            'Your SRO is Joseph Connor',
                            style: TextStyle(
                              color: kSecondaryTextColour,
                              fontFamily: 'PTSans',
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 30.0),
                          ProfileCard(
                            icon: Icons.share,
                            title: 'Share agreement',
                            status: shareString,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return ShareAgreementScreen(
                                    firstLogin: false,
                                    sharePreference: sharePreference!,
                                    shareRecording:
                                        sharePreference!.field1 == '1',
                                    shareWordCloud:
                                        sharePreference!.field2 == '1',
                                  );
                                }),
                              ).then((value) {
                                // Refresh data if save was pressed
                                if (value != null) {
                                  getSharePreference();
                                }
                              });
                            },
                          ),
                          ProfileCard(
                            icon: Icons.calendar_today_outlined,
                            title: 'Reminders',
                            status: remindersString,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  var day = remindersPreference!.field1;
                                  var time = remindersPreference!.field2;
                                  return day != null && time != null
                                      ? WeeklyRemindersScreen(
                                          isEnabled: true,
                                          daySet: int.parse(day),
                                          timeSet: TimeOfDay(
                                            hour:
                                                int.parse(time.substring(0, 2)),
                                            minute:
                                                int.parse(time.substring(3)),
                                          ),
                                        )
                                      : WeeklyRemindersScreen(
                                          isEnabled: false,
                                        );
                                }),
                              ).then((value) {
                                // Refresh data if save was pressed
                                if (value != null && value) {
                                  getRemindersPreference();
                                }
                              });
                            },
                          ),
                          ProfileCard(
                            icon: Icons.lock,
                            title: 'Change password',
                            status: '',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return ChangePasswordScreen();
                                }),
                              ).then((value) {
                                if (value != null && value) {
                                  final snackBar = SnackBar(
                                    backgroundColor: kSecondaryTextColour,
                                    content: Text('Password changed'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 30.0),
                      child: FormButton(
                        text: 'Sign out',
                        buttonColour: kAccentColour,
                        textColour: Colors.black,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
