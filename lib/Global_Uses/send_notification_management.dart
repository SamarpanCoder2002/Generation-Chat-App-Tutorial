import 'dart:convert';

import 'package:generation/Global_Uses/enum_generation.dart';
import 'package:http/http.dart';

class SendNotification {
  Future<void> messageNotificationClassifier(ChatMessageTypes messageTypes,
      {String textMsg = "",
      required String connectionToken,
      required String currAccountUserName}) async {
    switch (messageTypes) {
      case ChatMessageTypes.None:
        break;
      case ChatMessageTypes.Text:
        await sendNotification(
            token: connectionToken,
            title: "$currAccountUserName Send a Message",
            body: textMsg);
        break;
      case ChatMessageTypes.Image:
        await sendNotification(
            token: connectionToken,
            title: "$currAccountUserName Send a Image",
            body: "");
        break;
      case ChatMessageTypes.Video:
        await sendNotification(
            token: connectionToken,
            title: "$currAccountUserName Send a Video",
            body: "");
        break;
      case ChatMessageTypes.Document:
        await sendNotification(
            token: connectionToken,
            title: "$currAccountUserName Send a Document",
            body: "");
        break;
      case ChatMessageTypes.Audio:
        await sendNotification(
            token: connectionToken,
            title: "$currAccountUserName Send a Audio",
            body: "");
        break;
      case ChatMessageTypes.Location:
        await sendNotification(
            token: connectionToken,
            title: "$currAccountUserName Send a Location",
            body: "");
        break;
    }
  }

  Future<int> sendNotification(
      {required String token,
      required String title,
      required String body}) async {
    try {
      print("In Notification");

      final String _serverKey =
          "AAAAyXc-1K0:APA91bHfrn53OmcmgNKIT3H5Gt5Rah30msbtxbIP3RBDSZyeZwOPwPqAGRni5L6bAzM-kqD8x5B1Y7Gf85gPBePd9TDOHqaEi4iISaUcdixo3kKnNLaF_LSwma9uX6wO0Dl5KjNNH9q2";

      final Response response = await post(
        Uri.parse("https://fcm.googleapis.com/fcm/send"),
        headers: <String, String>{
          "Content-Type": "application/json",
          "Authorization": "key=$_serverKey",
        },
        body: jsonEncode(<String, dynamic>{
          "notification": <String, dynamic>{
            "body": body,
            "title": title,
          },
          "priority": "high",
          "data": <String, dynamic>{
            "click": "FLUTTER_NOTIFICATION_CLICK",
            "id": "1",
            "status": "done",
            "collapse_key": "type_a",
          },
          "to": token,
        }),
      );

      print("Response is: ${response.statusCode}   ${response.body}");

      return response.statusCode;
    } catch (e) {
      print("Error in Notification Send: ${e.toString()}");
      return 404;
    }
  }
}
