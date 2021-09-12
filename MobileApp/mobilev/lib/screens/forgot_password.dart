// Dart & Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Package imports
import 'package:email_validator/email_validator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// Module imports
import 'package:mobilev/services/network_service.dart';
import 'package:mobilev/config/constants.dart';
import 'package:mobilev/widgets/form_input_text.dart';
import 'package:mobilev/widgets/form_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
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
            padding: EdgeInsets.fromLTRB(40.0, 0.0, 40.0, 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image(
                  image: AssetImage('assets/images/reset_password.png'),
                  width: 240.0,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Enter your email address below and we\'ll send you a reset link.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.0,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 40.0),
                Form(
                  key: formKey,
                  child: FormInputText(
                    controller: emailController,
                    label: 'Email',
                    icon: Icons.email,
                    obscureInput: false,
                    keyboard: TextInputType.emailAddress,
                    validator: (value) {
                      if (!EmailValidator.validate(value!)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 20.0),
                FormButton(
                  text: isLoading ? '' : 'Request new password',
                  buttonColour: kPrimaryColour,
                  textColour: Colors.white,
                  icon: isLoading
                      ? SpinKitPouringHourGlass(
                          color: Colors.white,
                          size: 40.0,
                        )
                      : null,
                  onPressed: () async {
                    // Validate form
                    if (formKey.currentState!.validate()) {
                      // If email valid, try to connect to API
                      setState(() {
                        isLoading = true;
                      });
                      String email = emailController.text;
                      bool emailSent =
                          await NetworkService.resetPassword(email);
                      if (emailSent) {
                        Navigator.pop(context, true);
                      }
                      // If an error occurs, give relevant information
                      else {
                        // Check if connected to a network
                        String message = (await (Connectivity()
                                    .checkConnectivity())) !=
                                ConnectivityResult.none
                            ? 'An unexpected error occurred. Please try again.'
                            : 'Network unavailable';
                        final snackBar = SnackBar(
                          backgroundColor: kSecondaryTextColour,
                          content: Text(message),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                ),
                SizedBox(height: 40.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Remembered your password? Go back!',
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
