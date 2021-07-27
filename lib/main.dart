import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'FrontEnd/AuthUI/sign_up.dart';

void main(){
  runApp(
    MaterialApp(
        title: 'Generation',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        home: SignUpScreen(),
  ),
  );
}