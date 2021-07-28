import 'package:flutter/material.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kLightPrimaryColour,
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
                  label: 'Username',
                  icon: Icons.person,
                  obscureInput: false,
                  keyboard: TextInputType.text,
                ),
                SizedBox(height: 20.0),
                FormInputText(
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
                  goToRoute: '/home',
                ),
                SizedBox(height: 40.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/forgot-password');
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
