import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/Backend/firebase/Auth/email_and_pwd_auth.dart';
import 'package:generation/Backend/firebase/Auth/fb_auth.dart';
import 'package:generation/Backend/firebase/Auth/google_auth.dart';
import 'package:generation/FrontEnd/AuthUI/log_in.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final EmailAndPasswordAuth _emailAndPasswordAuth = EmailAndPasswordAuth();
  final GoogleAuthentication _googleAuthentication = GoogleAuthentication();
  final FacebookAuthentication _facebookAuthentication =
      FacebookAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: Text('Log Out'),
          onPressed: () async {
            final bool googleResponse =
                await this._googleAuthentication.logOut();

            if (!googleResponse) {
              final bool fbResponse =
                  await this._facebookAuthentication.logOut();


              if (!fbResponse) await this._emailAndPasswordAuth.logOut();
            }

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LogInScreen()),
                (route) => false);
          },
        ),
      ),
    );
  }
}
