import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mailgun/mailgun.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as localNoti;
import 'package:expiry_reminder/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';

// ----------------------------------------------------------------------------
// this function is meant to find difference in expiry date, not reminder time
int showDateDifference(DateTime date) {
  return DateTime(date.year, date.month, date.day)
      .difference(DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day))
      .inDays;
}

// ----------------------------------------------------------------------------
// Function to delete reminder along with the image
deleteReminder(DocumentSnapshot docToDelete, bool ifCompletelyDelete) async {
  if (ifCompletelyDelete == true) {
    deleteSpecificScheduledReminder(docToDelete.data['notificationID']);

    // if the productImage is not '', then we delete the image.
    if (docToDelete.data['productImage'] != '') {
      StorageReference imgStorageRef = await FirebaseStorage.instance
          .getReferenceFromUrl(docToDelete.data['productImage']);

      print(imgStorageRef.path);

      await imgStorageRef.delete().catchError((onError) =>
          print('An error has occured when deleting image.\n $onError'));

      print(
          'Image corresponding to >>>>>${docToDelete.data['reminderName']}<<<<< has been successfuly deleted.');
    }
  }
  // delete the document reference along with the image.
  await docToDelete.reference.delete().catchError((onError) =>
      print('An error has occured when deleting reminder.\n $onError'));
}

// ----------------------------------------------------------------------------
// Send Notification
void scheduleReminder(
    DateTime reminderTime, String productName, int notiID) async {
  tz.initializeTimeZones();
  final String currentTimezone = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(currentTimezone));

  var scheduledNotificationDateTime =
      tz.TZDateTime.from(reminderTime, tz.local);

  var androidPlatformChannelSpecifics = localNoti.AndroidNotificationDetails(
    'alarm_notif',
    'alarm_notif',
    'Channel for Alarm notification',
    icon: 'logo_no_name',
    largeIcon: localNoti.DrawableResourceAndroidBitmap('logo_no_name'),
    playSound: true,
    priority: localNoti.Priority.high,
    importance: localNoti.Importance.max,
    timeoutAfter: 5000,
  );

  var iOSPlatformChannelSpecifics = localNoti.IOSNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  var platformChannelSpecifics = localNoti.NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationPlugin
      .zonedSchedule(
        notiID,
        'Expiry Reminder',
        'Your $productName is expiring soon!',
        scheduledNotificationDateTime,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
            localNoti.UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      )
      .whenComplete(() => print('Reminder created for $productName'));
}

void deleteSpecificScheduledReminder(int id) async {
  await flutterLocalNotificationPlugin
      .cancel(id)
      .whenComplete(() => print('>>>>> This reminder has been deleted. <<<<<'));
}

void deleteAllScheduledReminder() async {
  await flutterLocalNotificationPlugin
      .cancelAll()
      .whenComplete(() => print('All reminders have been deleted.'));
}

int getUniqueRandomNumber() {
  dynamic randomNumberList = List<int>.generate(1000, (index) => index + 1)
    ..shuffle();

  return randomNumberList.removeLast();
}
