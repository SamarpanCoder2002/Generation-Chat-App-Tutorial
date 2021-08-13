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

  Future<bool> userRecordPresentOrNot({required String email}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc('${this._collectionName}/$email')
              .get();
      return documentSnapshot.exists;
    } catch (e) {
      print('Error in user Record Present or not: ${e.toString()}');
      return false;
    }
  }

  Future<Map<String, dynamic>> getTokenFromCloudStore(
      {required String userMail}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc('${this._collectionName}/$userMail')
              .get();

      print('DocumentSnapShot is: ${documentSnapshot.data()}');

      final Map<String, dynamic> importantData = Map<String, dynamic>();

      importantData["token"] = documentSnapshot.data()!["token"];
      importantData["date"] = documentSnapshot.data()!["creation_date"];
      importantData["time"] = documentSnapshot.data()!["creation_time"];

      return importantData;
    } catch (e) {
      print('Error in get Token from Cloud Store: ${e.toString()}');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getAllUsersListExceptMyAccount(
      {required String currentUserEmail}) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection(this._collectionName)
              .get();

      List<Map<String, dynamic>> _usersDataCollection = [];

      querySnapshot.docs.forEach(
          (QueryDocumentSnapshot<Map<String, dynamic>> queryDocumentSnapshot) {
        if (currentUserEmail != queryDocumentSnapshot.id)
          _usersDataCollection.add({
            queryDocumentSnapshot.id:
                '${queryDocumentSnapshot.get("user_name")}[user-name-about-divider]${queryDocumentSnapshot.get("about")}',
          });
      });

      print(_usersDataCollection);

      return _usersDataCollection;
    } catch (e) {
      print('Error in get All Users List: ${e.toString()}');
      return [];
    }
  }

  Future<Map<String, dynamic>?> _getCurrentAccountAllData(
      {required String email}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc('${this._collectionName}/$email')
              .get();

      return documentSnapshot.data();
    } catch (e) {
      print('Error in getCurrentAccountAll Data: ${e.toString()}');
      return {};
    }
  }

  Future<List<dynamic>> currentUserConnectionRequestList(
      {required String email}) async {
    try {
      Map<String, dynamic>? _currentUserData =
          await _getCurrentAccountAllData(email: email);

      final List<dynamic> _connectionRequestCollection =
          _currentUserData!["connection_request"];

      print('Collection: $_connectionRequestCollection');

      return _connectionRequestCollection;
    } catch (e) {
      print('Error in Current USer Collection List: ${e.toString()}');
      return [];
    }
  }

  Future<void> changeConnectionStatus(
      {required String oppositeUserMail,
      required String currentUserMail,
      required String connectionUpdatedStatus,
      required List<dynamic> currentUserUpdatedConnectionRequest}) async {
    try {
      /// Opposite Connection database Update
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc('${this._collectionName}/$oppositeUserMail')
              .get();

      Map<String, dynamic>? map = documentSnapshot.data();

      print('Map: $map');

      List<dynamic> _oppositeConnections = map!["connection_request"];

      int index = -1;

      _oppositeConnections.forEach((element) {
        if (element.keys.first.toString() == currentUserMail)
          index = _oppositeConnections.indexOf(element);
      });

      if(index > -1)
        _oppositeConnections.removeAt(index);

      print('Opposite Connections: $_oppositeConnections');

      _oppositeConnections.add({
        currentUserMail: connectionUpdatedStatus,
      });

      print('Opposite Connections: $_oppositeConnections');

      map["connection_request"] = _oppositeConnections;

      await FirebaseFirestore.instance
          .doc('${this._collectionName}/$oppositeUserMail')
          .update(map);

      /// Current User Connection Database Update
      final Map<String, dynamic>? currentUserMap =
          await _getCurrentAccountAllData(email: currentUserMail);

      currentUserMap!["connection_request"] =
          currentUserUpdatedConnectionRequest;

      await FirebaseFirestore.instance
          .doc('${this._collectionName}/$currentUserMail')
          .update(currentUserMap);
    } catch (e) {
      print('Error in Change Connection Status: ${e.toString()}');
    }
  }
}
