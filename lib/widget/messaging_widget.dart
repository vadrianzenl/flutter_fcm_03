import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fcm_03/api/messaging.dart';
import 'package:flutter_fcm_03/model/message.dart';
import 'package:flutter_fcm_03/page/first_page.dart';
import 'package:flutter_fcm_03/page/second_page.dart';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final List<Message> messages = [];
  final TextEditingController titleController =
      TextEditingController(text: 'Test Form Title');
  final TextEditingController bodyController =
      TextEditingController(text: 'Test Form Body');

  @override
  void initState() {
    super.initState();
    firebaseMessagingHandler();
  }

  Future<void> firebaseMessagingHandler() async {
    FirebaseMessaging.instance.getToken().then((token) {
      print(token);
    });
    final List<String> topics = ['all', 'CURSO_ADS', 'CURSO_DCS', 'CURSO_DSD'];
    for (var topic in topics) {
      FirebaseMessaging.instance.unsubscribeFromTopic(topic);
    }
    var topic = 'CURSO_DSD';
    await FirebaseMessaging.instance.subscribeToTopic('all');
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    FirebaseMessaging.instance.onTokenRefresh.listen(sendTokenToServer);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("onMessage event");
      RemoteNotification? notification = message.notification;
      setState(() {
        messages.add(Message(
          title: notification!.title!,
          body: notification.body!,
        ));
      });
      handleRouting(notification!.title!);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp event');
      print(message.data);
      final notification = message.data;
      print('length: ' + notification.length.toString());
      if (notification.length > 0) {
        print('message.data');
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
        handleRouting(notification['title']);
      } else {
        print('message.notification');
        RemoteNotification? notification = message.notification;
        setState(() {
          messages.add(Message(
            title: notification!.title!,
            body: notification.body!,
          ));
        });
        handleRouting(notification!.title!);
      }
    });
    FirebaseMessaging.instance.requestPermission();
  }

  void handleRouting(String title) {
    print('title: ' + title);
    switch (title) {
      case 'first':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => FirstPage()));
        break;
      case 'second':
        Navigator.of(context).push(
            MaterialPageRoute(builder: (BuildContext context) => SecondPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        children: [
          TextFormField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextFormField(
            controller: bodyController,
            decoration: InputDecoration(labelText: 'Body'),
          ),
          ElevatedButton(
            onPressed: sendNotification,
            child: Text('Send notification to all'),
          ),
        ]..addAll(messages.map(buildMessage).toList()),
      );

  Widget buildMessage(Message message) => ListTile(
        title: Text(message.title),
        subtitle: Text(message.body),
      );

  Future sendNotification() async {
    final response = await Messaging.sendToAll(
      title: titleController.text,
      body: bodyController.text,
    );
    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmToken) {
    print('Token: $fcmToken');
  }
}
