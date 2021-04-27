import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/wrapper.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var initialisationSettingsAndroid =
      AndroidInitializationSettings('logo_no_name');
  var initialisationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String title, String body, String payload) async {});
  var initialisationSettings = InitializationSettings(
      android: initialisationSettingsAndroid, iOS: initialisationSettingsIOS);
  await flutterLocalNotificationPlugin.initialize(initialisationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: GetMaterialApp(
        // key: Get.key,
        debugShowCheckedModeBanner: false,
        home: Wrapper(),
        theme: ThemeData(primaryColor: Colors.black),
      ),
    );
  }
}
