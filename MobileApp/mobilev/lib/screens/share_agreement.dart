// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_button.dart';

class ShareAgreementScreen extends StatefulWidget {
  @override
  _ShareAgreementScreenState createState() => _ShareAgreementScreenState();
}

class _ShareAgreementScreenState extends State<ShareAgreementScreen> {
  bool shareRecording = true;
  bool shareWordCloud = true;

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
                    onPressed: () {
                      Navigator.pop(context, true);
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
