// Dart & Flutter imports
import 'package:flutter/material.dart';

// Module imports
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/screens/share_agreement.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class LoginScreen extends StatelessWidget {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundPrimaryColour,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  image: AssetImage('assets/images/MobileV_logo.png'),
                  width: 240.0,
                ),
                SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'PTSans',
                      fontSize: 34.0,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: 'Mobile',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: 'V'),
                    ],
                  ),
                ),
                SizedBox(height: 30.0),
                FormInputText(
                  controller: usernameController,
                  label: 'Username',
                  icon: Icons.person,
                  obscureInput: false,
                  keyboard: TextInputType.text,
                ),
                SizedBox(height: 20.0),
                FormInputText(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  obscureInput: true,
                  keyboard: TextInputType.text,
                ),
                SizedBox(height: 20.0),
                FormButton(
                  text: 'Sign in',
                  buttonColour: kPrimaryColour,
                  textColour: Colors.white,
                  onPressed: () async {
                    // Fetch username from database
                    String? storedUsername =
                        (await UserData.selectUserData('username')).field1;
                    // If username inputted matches that in the database, check in back-end
                    if (usernameController.text == storedUsername) {
                      Navigator.pushReplacementNamed(context, '/my-home');
                    }
                    // Else if a username is stored but not a match, show an error
                    // Else if no username is stored, store, check in back-end then show sharing agreement
                    else if (storedUsername == null) {
                      // Store in database
                      UserData.updateUserData(
                        UserData(
                            domain: 'username',
                            field1: usernameController.text,
                            field2: null),
                      );
                      // Check in back-end
                      // Show sharing agreement
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ShareAgreementScreen(
                              firstLogin: true,
                              sharePreference: UserData(
                                domain: 'sharePreference',
                                field1: '0',
                                field2: '0',
                              ),
                              shareRecording: false,
                              shareWordCloud: false,
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: 40.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text(
                    'Forgot your password?',
                    style: TextStyle(
                      color: kSecondaryTextColour,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
