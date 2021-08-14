// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/widgets/form_button.dart';

class ShareAgreementScreen extends StatefulWidget {
  final bool firstLogin;
  final UserData sharePreference;
  final bool shareRecording;
  final bool shareWordCloud;

  ShareAgreementScreen({
    required this.firstLogin,
    required this.sharePreference,
    required this.shareRecording,
    required this.shareWordCloud,
  });

  @override
  _ShareAgreementScreenState createState() => _ShareAgreementScreenState(
        this.firstLogin,
        this.sharePreference,
        this.shareRecording,
        this.shareWordCloud,
      );
}

class _ShareAgreementScreenState extends State<ShareAgreementScreen> {
  final bool firstLogin;
  UserData sharePreference;
  bool shareRecording;
  bool shareWordCloud;

  _ShareAgreementScreenState(
    this.firstLogin,
    this.sharePreference,
    this.shareRecording,
    this.shareWordCloud,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Share agreement'),
      ),
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
          return true;
        },
        child: Scrollbar(
          isAlwaysShown: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 17.0,
                      height: 1.4,
                      fontFamily: 'Roboto',
                      color: kPrimaryTextColour,
                    ),
                    children: [
                      TextSpan(
                        text:
                            'The MobileV app can be used entirely offline. However, it also offers users the ability to receive analysis on their recordings in exchange for sharing relevant information with their SRO.\n\n',
                      ),
                      TextSpan(
                        text: 'Numeric',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            ' recordings are those where a user completes a counting test. For these, users can receive an estimate of their recording\'s words-per-minute (WPM), in exchange for sharing the audio with their SRO.\n\n',
                      ),
                      TextSpan(
                        text: 'Text',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(
                        text:
                            ' recordings are those where a user speaks freely. For these, users can receive WPM, a transcript and a word cloud, in exchange for sharing the audio, resulting word cloud, or both, with their SRO.\n\nAll shared information is securely encrypted on the MobileV servers, and only accessible for the user\'s SRO.\n\nUsers can request their SRO to delete any shared information. All (historic) shared information will automatically be deleted if a user\'s account is deleted in the future.',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                Text(
                  'I agree to:',
                  style: TextStyle(
                    fontFamily: 'PTSans',
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share audio',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Switch(
                      value: shareRecording,
                      activeColor: kDarkAccentColour,
                      inactiveThumbColor: kCardColour,
                      inactiveTrackColor: kSecondaryTextColour,
                      onChanged: (value) {
                        setState(() {
                          sharePreference = UserData(
                            domain: 'sharePreference',
                            field1: value ? '1' : '0',
                            field2: sharePreference.field2,
                          );
                          shareRecording = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Share word clouds',
                      style: TextStyle(
                        fontSize: 17.0,
                      ),
                    ),
                    SizedBox(width: 20.0),
                    Switch(
                      value: shareWordCloud,
                      activeColor: kDarkAccentColour,
                      inactiveThumbColor: kCardColour,
                      inactiveTrackColor: kSecondaryTextColour,
                      onChanged: (value) {
                        setState(() {
                          sharePreference = UserData(
                              domain: 'sharePreference',
                              field1: sharePreference.field1,
                              field2: value ? '1' : '0');
                          shareWordCloud = value;
                        });
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30.0),
                Row(
                  children: [
                    Expanded(
                      child: FormButton(
                        text: 'Save',
                        buttonColour: kPrimaryColour,
                        textColour: Colors.white,
                        onPressed: () async {
                          await UserData.updateUserData(sharePreference);
                          if (firstLogin) {
                            Navigator.pushReplacementNamed(context, '/my-home');
                          } else {
                            // Used for accepting share agreement on add/view recording pages
                            if (sharePreference.field1 != '0' ||
                                sharePreference.field2 != '0') {
                              Navigator.pop(context, true);
                            } else {
                              // Refresh profile page body
                              Navigator.pop(context, false);
                            }
                          }
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
