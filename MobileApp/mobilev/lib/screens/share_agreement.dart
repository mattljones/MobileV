// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/widgets/form_button.dart';

class ShareAgreementScreen extends StatefulWidget {
  final UserData sharePreference;
  final bool shareRecording;
  final bool shareWordCloud;

  ShareAgreementScreen({
    required this.sharePreference,
    required this.shareRecording,
    required this.shareWordCloud,
  });

  @override
  _ShareAgreementScreenState createState() => _ShareAgreementScreenState(
        this.sharePreference,
        this.shareRecording,
        this.shareWordCloud,
      );
}

class _ShareAgreementScreenState extends State<ShareAgreementScreen> {
  UserData sharePreference;
  bool shareRecording;
  bool shareWordCloud;

  _ShareAgreementScreenState(
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              testTranscript,
              style: TextStyle(
                fontSize: 17.0,
                height: 1.4,
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
                  'Share recordings',
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
                      Navigator.pop(
                          context, true); // Refresh profile page on pop
                    },
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
