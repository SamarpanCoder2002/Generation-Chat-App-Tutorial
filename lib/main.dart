import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';

import 'FrontEnd/AuthUI/sign_up.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MaterialApp(
        title: 'Generation',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        home: SignUpScreen(),
  ),
  );
}