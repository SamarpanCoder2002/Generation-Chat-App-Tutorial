import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:generation/FrontEnd/AuthUI/sign_up.dart';

import 'log_in.dart';

Widget commonTextFormField({required String hintText, required String? Function(String?)? validator, required TextEditingController textEditingController}) {
  return Container(
    padding: EdgeInsets.only(left: 20.0, right: 20.0, bottom: 50.0),
    child: TextFormField(
      validator: validator,
      controller: textEditingController,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.lightBlue,
            width: 2.0,
          ),
        ),
      ),
    ),
  );
}

// Widget authButton(BuildContext context, String buttonName) {
//   return Padding(
//     padding: const EdgeInsets.only(left: 20.0, right: 20.0),
//     child: ElevatedButton(
//       style: ElevatedButton.styleFrom(
//           minimumSize: Size(MediaQuery.of(context).size.width - 60, 30.0),
//           elevation: 5.0,
//           primary: Color.fromRGBO(57, 60, 80, 1),
//           padding: EdgeInsets.only(
//             left: 20.0,
//             right: 20.0,
//             top: 7.0,
//             bottom: 7.0,
//           ),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.all(Radius.circular(20.0)),
//           )),
//       child: Text(
//         buttonName,
//         style: TextStyle(
//           fontSize: 25.0,
//           letterSpacing: 1.0,
//           fontWeight: FontWeight.w400,
//         ),
//       ),
//       onPressed: () async {},
//     ),
//   );
// }

// Widget socialMediaIntegrationButtons() {
//   return Container(
//     width: double.maxFinite,
//     padding: EdgeInsets.all(30.0),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         GestureDetector(
//           onTap: (){
//             print('Google Pressed');
//           },
//           child: Image.asset(
//             'assets/images/google.png',
//             width: 50.0,
//           ),
//         ),
//         SizedBox(
//           width: 80.0,
//         ),
//         GestureDetector(
//           onTap: (){
//             print('Facebook Pressed');
//           },
//           child: Image.asset(
//             'assets/images/fbook.png',
//             width: 50.0,
//           ),
//         ),
//       ],
//     ),
//   );
// }

Widget switchAnotherAuthScreen(
    BuildContext context, String buttonNameFirst, String buttonNameLast) {
  return ElevatedButton(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          buttonNameFirst,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.0,
            letterSpacing: 1.0,
          ),
        ),
        Text(
          buttonNameLast,
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 16.0,
            letterSpacing: 1.0,
          ),
        ),
      ],
    ),
    style: ElevatedButton.styleFrom(
      elevation: 0.0,
      primary: Color.fromRGBO(34, 48, 60, 1),
    ),
    onPressed: () {
      if (buttonNameLast == "Log-In")
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => LogInScreen()));
      else
        Navigator.push(context, MaterialPageRoute(builder: (_) => SignUpScreen()));
    },
  );
}
