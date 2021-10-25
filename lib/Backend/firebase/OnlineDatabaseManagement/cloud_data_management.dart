import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:generation/Backend/sqlite_management/local_database_management.dart';
import 'package:generation/Global_Uses/constants.dart';
import 'package:generation/Global_Uses/enum_generation.dart';
import 'package:generation/Global_Uses/send_notification_management.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_auth/firebase_auth.dart';

class CloudStoreDataManagement {
  final _collectionName = 'generation_users';

  final SendNotification _sendNotification = SendNotification();
  final LocalDatabase _localDatabase = LocalDatabase();

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
        "connections": {},
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

  Future<void> changeConnectionStatus({
    required String oppositeUserMail,
    required String currentUserMail,
    required String connectionUpdatedStatus,
    required List<dynamic> currentUserUpdatedConnectionRequest,
    bool storeDataAlsoInConnections = false,
  }) async {
    try {
      print('Come here');

      /// Opposite Connection database Update
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc('${this._collectionName}/$oppositeUserMail')
              .get();

      Map<String, dynamic>? map = documentSnapshot.data();

      print('Map: $map');

      List<dynamic> _oppositeConnectionsRequestsList =
          map!["connection_request"];

      int index = -1;

      _oppositeConnectionsRequestsList.forEach((element) {
        if (element.keys.first.toString() == currentUserMail)
          index = _oppositeConnectionsRequestsList.indexOf(element);
      });

      if (index > -1) _oppositeConnectionsRequestsList.removeAt(index);

      print('Opposite Connections: $_oppositeConnectionsRequestsList');

      _oppositeConnectionsRequestsList.add({
        currentUserMail: connectionUpdatedStatus,
      });

      print('Opposite Connections: $_oppositeConnectionsRequestsList');

      map["connection_request"] = _oppositeConnectionsRequestsList;

      if (storeDataAlsoInConnections)
        map[FirestoreFieldConstants().connections].addAll({
          currentUserMail: [],
        });

      await FirebaseFirestore.instance
          .doc('${this._collectionName}/$oppositeUserMail')
          .update(map);

      /// Current User Connection Database Update
      final Map<String, dynamic>? currentUserMap =
          await _getCurrentAccountAllData(email: currentUserMail);

      currentUserMap!["connection_request"] =
          currentUserUpdatedConnectionRequest;

      if (storeDataAlsoInConnections)
        currentUserMap[FirestoreFieldConstants().connections].addAll({
          oppositeUserMail: [],
        });

      await FirebaseFirestore.instance
          .doc('${this._collectionName}/$currentUserMail')
          .update(currentUserMap);
    } catch (e) {
      print('Error in Change Connection Status: ${e.toString()}');
    }
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>?>
      fetchRealTimeDataFromFirestore() async {
    try {
      return FirebaseFirestore.instance
          .collection(this._collectionName)
          .snapshots();
    } catch (e) {
      print('Error in Fetch Real Time Data : ${e.toString()}');
      return null;
    }
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>?>
      fetchRealTimeMessages() async {
    try {
      return FirebaseFirestore.instance
          .doc(
              '${this._collectionName}/${FirebaseAuth.instance.currentUser!.email.toString()}')
          .snapshots();
    } catch (e) {
      print('Error in Fetch Real Time Data : ${e.toString()}');
      return null;
    }
  }

  Future<void> sendMessageToConnection(
      {required String connectionUserName,
      required Map<String, Map<String, String>> sendMessageData,
      required ChatMessageTypes chatMessageTypes}) async {
    try {
      final LocalDatabase _localDatabase = LocalDatabase();

      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final String? _getConnectedUserEmail =
          await _localDatabase.getParticularFieldDataFromImportantTable(
              userName: connectionUserName,
              getField: GetFieldForImportantDataLocalDatabase.UserEmail);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc("${this._collectionName}/$_getConnectedUserEmail")
              .get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();

      List<dynamic>? getOldMessages =
          connectedUserData![FirestoreFieldConstants().connections]
              [currentUserEmail.toString()];
      if (getOldMessages == null) getOldMessages = [];

      getOldMessages.add(sendMessageData);

      connectedUserData[FirestoreFieldConstants().connections]
          [currentUserEmail.toString()] = getOldMessages;

      print(
          "Data checking: ${connectedUserData[FirestoreFieldConstants().connections]}");

      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$_getConnectedUserEmail")
          .update({
        FirestoreFieldConstants().connections:
            connectedUserData[FirestoreFieldConstants().connections],
      }).whenComplete(() async {
        print('Data Send Completed');

        final String? connectionToken =
            await _localDatabase.getParticularFieldDataFromImportantTable(
                userName: connectionUserName,
                getField: GetFieldForImportantDataLocalDatabase.Token);

        final String? currentAccountUserName =
            await _localDatabase.getUserNameForCurrentUser(
                FirebaseAuth.instance.currentUser!.email.toString());

        await _sendNotification.messageNotificationClassifier(chatMessageTypes,
            connectionToken: connectionToken ?? "",
            currAccountUserName: currentAccountUserName ?? "");
      });
    } catch (e) {
      print('error in Send Data: ${e.toString()}');
    }
  }

  Future<void> removeOldMessages({required String connectionEmail}) async {
    try {
      final String? currentUserEmail = FirebaseAuth.instance.currentUser!.email;

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .doc("${this._collectionName}/$currentUserEmail")
              .get();

      final Map<String, dynamic>? connectedUserData = documentSnapshot.data();

      connectedUserData![FirestoreFieldConstants().connections]
          [connectionEmail.toString()] = [];

      print(
          "After Remove: ${connectedUserData[FirestoreFieldConstants().connections]}");

      await FirebaseFirestore.instance
          .doc("${this._collectionName}/$currentUserEmail")
          .update({
        FirestoreFieldConstants().connections:
            connectedUserData[FirestoreFieldConstants().connections],
      }).whenComplete(() {
        print('Data Deletion Completed');
      });
    } catch (e) {
      print('error in Send Data: ${e.toString()}');
    }
  }

  Future<String?> uploadMediaToStorage(File filePath,
      {required String reference}) async {
    try {
      String? downLoadUrl;

      final String fileName =
          '${FirebaseAuth.instance.currentUser!.uid}${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}${DateTime.now().millisecond}';

      final Reference firebaseStorageRef =
          FirebaseStorage.instance.ref(reference).child(fileName);

      print('Firebase Storage Reference: $firebaseStorageRef');

      final UploadTask uploadTask = firebaseStorageRef.putFile(filePath);

      await uploadTask.whenComplete(() async {
        print("Media Uploaded");
        downLoadUrl = await firebaseStorageRef.getDownloadURL();
        print("Download Url: $downLoadUrl}");
      });

      return downLoadUrl!;
    } catch (e) {
      print("Error: Firebase Storage Exception is: ${e.toString()}");
      return null;
    }
  }
}
