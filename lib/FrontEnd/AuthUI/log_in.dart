import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generation/Backend/firebase/Auth/sign_up_auth.dart';
import 'package:generation/FrontEnd/home_page.dart';
import 'package:generation/Global_Uses/enum_generation.dart';
import 'package:generation/Global_Uses/reg_exp.dart';
import 'package:loading_overlay/loading_overlay.dart';

import 'common_auth_methods.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({Key? key}) : super(key: key);

  @override
  _LogInScreenState createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final GlobalKey<FormState> _logInKey = GlobalKey<FormState>();

  final TextEditingController _email = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  final EmailAndPasswordAuth _emailAndPasswordAuth = EmailAndPasswordAuth();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
        body: LoadingOverlay(
          isLoading: this._isLoading,
          child: Container(
            child: ListView(
              shrinkWrap: true,
              children: [
                SizedBox(
                  height: 50.0,
                ),
                Center(
                  child: Text(
                    'Log-In',
                    style: TextStyle(fontSize: 28.0, color: Colors.white),
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.only(top: 60.0, bottom: 10.0),
                  child: Form(
                    key: this._logInKey,
                    child: ListView(
                      children: [
                        commonTextFormField(
                            hintText: 'Email',
                            validator: (String? inputVal) {
                              if (!emailRegex.hasMatch(inputVal.toString()))
                                return 'Email format is not matching';
                              return null;
                            },
                            textEditingController: this._email),
                        commonTextFormField(
                            hintText: 'Password',
                            validator: (String? inputVal) {
                              if (inputVal!.length < 6)
                                return 'Password must be at least 6 characters';
                              return null;
                            },
                            textEditingController: this._pwd),
                        logInAuthButton(context, 'Log-In'),
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
                switchAnotherAuthScreen(
                    context, "Don't Have an Account? ", 'Sign-Up'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget logInAuthButton(BuildContext context, String buttonName) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            minimumSize: Size(MediaQuery.of(context).size.width - 60, 30.0),
            elevation: 5.0,
            primary: Color.fromRGBO(57, 60, 80, 1),
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 7.0,
              bottom: 7.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            )),
        child: Text(
          buttonName,
          style: TextStyle(
            fontSize: 25.0,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        onPressed: () async {
          if (this._logInKey.currentState!.validate()) {
            print('Validated');
            SystemChannels.textInput.invokeMethod('TextInput.hide');

            if (mounted) {
              setState(() {
                this._isLoading = true;
              });
            }

            final EmailSignInResults emailSignInResults =
                await _emailAndPasswordAuth.signInWithEmailAndPassword(
                    email: this._email.text, pwd: this._pwd.text);

            String msg = '';
            if (emailSignInResults == EmailSignInResults.SignInCompleted)
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => HomePage()),
                  (route) => false);
            else if (emailSignInResults ==
                EmailSignInResults.EmailNotVerified) {
              msg =
                  'Email not Verified.\nPlease Verify your email and then Log In';
            } else if (emailSignInResults ==
                EmailSignInResults.EmailOrPasswordInvalid)
              msg = 'Email And Password Invalid';
            else
              msg = 'Sign In Not Completed';

            if (msg != '')
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(msg)));

            if (mounted) {
              setState(() {
                this._isLoading = false;
              });
            }
          } else {
            print('Not Validated');
          }
        },
      ),
    );
  }
}
