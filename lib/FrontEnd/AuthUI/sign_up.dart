import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'common_auth_methods.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _signUpKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: Container(
          child: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(
                height: 50.0,
              ),
              Center(
                child: Text(
                  'Sign-Up',
                  style: TextStyle(fontSize: 28.0, color: Colors.white),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 1.65,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.only(top: 40.0, bottom: 10.0),
                child: Form(
                  key: this._signUpKey,
                  child: ListView(
                    children: [
                      commonTextFormField(hintText: 'Email'),
                      commonTextFormField(hintText: 'Password'),
                      commonTextFormField(hintText: 'Conform Password'),
                      authButton(context, 'Sign-Up'),
                    ],
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Or Continue With',
                  style: TextStyle(color: Colors.white, fontSize: 20.0),
                ),
              ),
              socialMediaIntegrationButtons(),
              switchAnotherAuthScreen(context, "Already have an account? ","Log-In"),
            ],
          ),
        ),
      ),
    );
  }


}
