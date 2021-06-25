import 'dart:convert';
import 'package:http/http.dart';

class Messaging {
  static final Client client = Client();

  static const String serverKey =
      'AAAAz5mWzmk:APA91bHnsqyi4Rwg9KBmoO6Fcuw9pXIopEM8qDqYoZa44iUJhcrAVem_9-UNhOV-cP0XxJJpAkqR1WO8rSwI0GNuK3ZKIZDIU7NPGQ9KVSuibmIMFrj4yndCsusCo5L2ZD1BWM-XqD1h';

  static Future<Response> sendToAll({
    required String title,
    required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<Response> sendToTopic(
          {required String title,
          required String body,
          required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    required String title,
    required String body,
    required String fcmToken,
  }) =>
      client.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: json.encode({
          'notification': {'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'title': 'Title',
            'body': 'Body'
          },
          'to': '$fcmToken',
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
      );
}
