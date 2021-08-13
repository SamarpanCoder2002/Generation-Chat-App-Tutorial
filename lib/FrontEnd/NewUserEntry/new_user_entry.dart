import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generation/Backend/firebase/OnlineDatabaseManagement/cloud_data_management.dart';
import 'package:generation/Backend/sqlite_management/local_database_management.dart';
import 'package:generation/FrontEnd/AuthUI/common_auth_methods.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:generation/FrontEnd/MainScreens/main_screen.dart';

import 'package:loading_overlay/loading_overlay.dart';

class TakePrimaryUserData extends StatefulWidget {
  const TakePrimaryUserData({Key? key}) : super(key: key);

  @override
  _TakePrimaryUserDataState createState() => _TakePrimaryUserDataState();
}

class _TakePrimaryUserDataState extends State<TakePrimaryUserData> {
  bool _isLoading = false;

  final GlobalKey<FormState> _takeUserPrimaryInformationKey =
      GlobalKey<FormState>();

  final TextEditingController _userName = TextEditingController();
  final TextEditingController _userAbout = TextEditingController();

  final CloudStoreDataManagement _cloudStoreDataManagement =
      CloudStoreDataManagement();
  final LocalDatabase _localDatabase = LocalDatabase();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: const Color.fromRGBO(34, 48, 60, 1),
      body: LoadingOverlay(
        isLoading: this._isLoading,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Form(
            key: this._takeUserPrimaryInformationKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                _upperHeading(),
                commonTextFormField(
                    bottomPadding: 30.0,
                    hintText: 'User Name',
                    validator: (inputUserName) {
                      /// Regular Expression
                      final RegExp _messageRegex = RegExp(r'[a-zA-Z0-9]');

                      if (inputUserName!.length < 6)
                        return "User Name At Least 6 Characters";
                      else if (inputUserName.contains(' ') ||
                          inputUserName.contains('@'))
                        return "Space and '@' Not Allowed...User '_' instead of space";
                      else if (inputUserName.contains('__'))
                        return "'__' Not Allowed...User '_' instead of '__'";
                      else if (!_messageRegex.hasMatch(inputUserName))
                        return "Sorry,Only Emoji Not Supported";
                      return null;
                    },
                    textEditingController: this._userName),
                commonTextFormField(
                    hintText: 'User About',
                    validator: (inputVal) {
                      if (inputVal!.length < 6)
                        return 'User About must have 6 characters';
                      return null;
                    },
                    textEditingController: this._userAbout),
                _saveUserPrimaryInformation(),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _upperHeading() {
    return Padding(
      padding: EdgeInsets.only(top: 30.0, bottom: 50.0),
      child: Center(
        child: Text(
          'Set Up Your Account',
          style: TextStyle(color: Colors.white, fontSize: 25.0),
        ),
      ),
    );
  }

  Widget _saveUserPrimaryInformation() {
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
          'Save',
          style: TextStyle(
            fontSize: 25.0,
            letterSpacing: 1.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        onPressed: () async {
          if (this._takeUserPrimaryInformationKey.currentState!.validate()) {
            print('Validated');

            SystemChannels.textInput.invokeMethod('TextInput.hide');

            if (mounted) {
              setState(() {
                this._isLoading = true;
              });
            }

            final bool canRegisterNewUser = await _cloudStoreDataManagement
                .checkThisUserAlreadyPresentOrNot(
                    userName: this._userName.text);

            String msg = '';

            if (!canRegisterNewUser)
              msg = 'User Name Already Present';
            else {
              final bool _userEntryResponse =
                  await _cloudStoreDataManagement.registerNewUser(
                      userName: this._userName.text,
                      userAbout: this._userAbout.text,
                      userEmail:
                          FirebaseAuth.instance.currentUser!.email.toString());
              if (_userEntryResponse) {
                msg = 'User data Entry Successfully';

                /// Calling Local Databases Methods To Intitialize Local Database with required MEthods
                await this._localDatabase.createTableToStoreImportantData();

                final Map<String,dynamic> _importantFetchedData = await _cloudStoreDataManagement.getTokenFromCloudStore(userMail: FirebaseAuth.instance.currentUser!.email.toString());

                await this._localDatabase.insertOrUpdateDataForThisAccount(
                    userName: this._userName.text,
                    userMail: FirebaseAuth.instance.currentUser!.email.toString(),
                    userToken: _importantFetchedData["token"],
                    userAbout: this._userAbout.text,
                    userAccCreationDate: _importantFetchedData["date"],
                    userAccCreationTime: _importantFetchedData["time"]);

                await _localDatabase
                    .createTableForUserActivity(tableName: this._userName.text);

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreen()),
                    (route) => false);
              } else
                msg = 'User Data Not Entry Successfully';
            }

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
