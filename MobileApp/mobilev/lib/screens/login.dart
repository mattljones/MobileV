// Dart & Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// Package imports
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Module imports
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/models/user_data.dart';
import 'package:mobilev/screens/share_agreement.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundPrimaryColour,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 15.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image(
                    image: AssetImage('assets/images/MobileV_logo.png'),
                    width: 225.0,
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
                    validator: (value) {
                      if (value == '') {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  FormInputText(
                    controller: passwordController,
                    label: 'Password',
                    icon: Icons.lock,
                    obscureInput: true,
                    keyboard: TextInputType.text,
                    validator: (value) {
                      if (value == '') {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0),
                  FormButton(
                    text: isLoading ? '' : 'Sign in',
                    buttonColour: kPrimaryColour,
                    textColour: Colors.white,
                    icon: isLoading
                        ? SpinKitPouringHourGlass(
                            color: Colors.white,
                            size: 40.0,
                          )
                        : null,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        FocusScope.of(context).unfocus();
                        // Fetch username from database
                        String? storedUsername =
                            (await UserData.selectUserData('username')).field1;
                        // If username inputted matches that in the database, check in back-end
                        if (usernameController.text == storedUsername) {
                          setState(() => isLoading = true);
                          var isAuthenticated = await NetworkService.login(
                              usernameController.text, passwordController.text);
                          if (isAuthenticated == 'wrong_credentials') {
                            final snackBar = SnackBar(
                              backgroundColor: kSecondaryTextColour,
                              content: Text(
                                  'Incorrect credentials. Please try again.'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            setState(() => isLoading = false);
                          } else if (isAuthenticated == false) {
                            final snackBar = SnackBar(
                              backgroundColor: kSecondaryTextColour,
                              content:
                                  Text('An error occurred. Please try again.'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            setState(() => isLoading = false);
                          } else {
                            Navigator.pushReplacementNamed(context, '/my-home');
                          }
                        }
                        // Else if a username is stored but not a match, show an error
                        else if (storedUsername != null &&
                            usernameController.text != storedUsername) {
                          final snackBar = SnackBar(
                            backgroundColor: kSecondaryTextColour,
                            content:
                                Text('This app is registered to another user.'),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        // Else if no username is stored, store, check in back-end then show sharing agreement
                        else if (storedUsername == null) {
                          setState(() => isLoading = true);
                          var isAuthenticated = await NetworkService.login(
                              usernameController.text, passwordController.text);
                          if (isAuthenticated == 'wrong_credentials') {
                            final snackBar = SnackBar(
                              backgroundColor: kSecondaryTextColour,
                              content: Text(
                                  'Incorrect credentials. Please try again.'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            setState(() => isLoading = false);
                          } else if (isAuthenticated == false) {
                            final snackBar = SnackBar(
                              backgroundColor: kSecondaryTextColour,
                              content:
                                  Text('An error occurred. Please try again.'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                            setState(() => isLoading = false);
                          } else {
                            // Store in database
                            UserData.updateUserData(
                              UserData(
                                  domain: 'username',
                                  field1: usernameController.text,
                                  field2: null),
                            );
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
                        }
                      }
                    },
                  ),
                  SizedBox(height: 25.0),
                  GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      Navigator.pushNamed(context, '/forgot-password').then(
                        (value) {
                          // Notify user that email link has been sent
                          if (value != null && value == true) {
                            final snackBar = SnackBar(
                              backgroundColor: kSecondaryTextColour,
                              content: Text('Email reset link sent'),
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(snackBar);
                          }
                        },
                      );
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
      ),
    );
  }
}
