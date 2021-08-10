import 'package:generation/Backend/sqlite_management/local_database_management.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CloudStoreDataManagement {
  final _collectionName = 'generation_users';

  Future<bool> checkThisUserAlreadyPresentOrNot(
      {required String userName}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> findResults =
          await FirebaseFirestore.instance
              .collection(_collectionName)
              .where('user_name', isEqualTo: userName)
              .get();

      print('Debug 1: ${findResults.docs.isEmpty}');

      return findResults.docs.isEmpty ? true : false;
    } catch (e) {
      print(
          'Error in Checkj This User Already Present or not: ${e.toString()}');
      return false;
    }
  }

  Future<bool> registerNewUser(
      {required String userName,
      required String userAbout,
      required String userEmail}) async {
    try {
      final String? _getToken = await FirebaseMessaging.instance.getToken();

      final String currDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

      final String currTime = "${DateFormat('hh:mm a').format(DateTime.now())}";

      await FirebaseFirestore.instance.doc('$_collectionName/$userEmail').set({
        "about": userAbout,
        "activity": [],
        "connection_request": [],
        "connections": [],
        "creation_date": currDate,
        "creation_time": currTime,
        "phone_number": "",
        "profile_pic": "",
        "token": _getToken.toString(),
        "total_connections": "",
        "user_name": userName,
      });

      return true;
    } catch (e) {
      print('Error in Register new user: ${e.toString()}');
      return false;
    }
  }

  Future<bool> userRecordPresentOrNot({required String email}) async{
    try{
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance.doc('${this._collectionName}/$email').get();
      return documentSnapshot.exists;
    }catch(e){
      print('Error in user Record Present or not: ${e.toString()}');
      return false;
    }
  }

  Future<Map<String,dynamic>> getTokenFromCloudStore({required String userMail}) async{
    try{
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await FirebaseFirestore.instance.doc('${this._collectionName}/$userMail').get();

      print('DocumentSnapShot is: ${documentSnapshot.data()}');

      final Map<String,dynamic> importantData = Map<String,dynamic>();

      importantData["token"] = documentSnapshot.data()!["token"];
      importantData["date"] = documentSnapshot.data()!["creation_date"];
      importantData["time"] = documentSnapshot.data()!["creation_time"];

      return importantData;


    }catch(e){
      print('Error in get Token from Cloud Store: ${e.toString()}');
      return {};
    }
  }
}
