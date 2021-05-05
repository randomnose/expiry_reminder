import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as localNoti;
import 'package:expiry_reminder/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        backgroundColor: appGreen,
        fontSize: 18,
        gravity: ToastGravity.CENTER,
        toastLength: Toast.LENGTH_LONG);
  }

  // ----------------------------------------------------------------------------
  // this function is meant to find difference in expiry date, not reminder time
  static int showDateDifference(DateTime date) {
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
  }

  // ----------------------------------------------------------------------------
  // Function to delete reminder along with the image
  static deleteReminder(DocumentSnapshot docToDelete, bool ifCompletelyDelete) async {
    if (ifCompletelyDelete == true) {
      deleteSpecificScheduledReminder(docToDelete.data['notificationID']);

      // if the productImage is not null, then we delete the image.
      if (docToDelete.data['productImage'] != null) {
        StorageReference imgStorageRef =
            await FirebaseStorage.instance.getReferenceFromUrl(docToDelete.data['productImage']);

        print(imgStorageRef.path);

        await imgStorageRef
            .delete()
            .catchError((onError) => print('An error has occured when deleting image.\n $onError'));

        print(
            'Image corresponding to >>>>>${docToDelete.data['reminderName']}<<<<< has been successfuly deleted.');
      }
    }
    // delete the document reference along with the image.
    await docToDelete.reference
        .delete()
        .catchError((onError) => print('An error has occured when deleting reminder.\n $onError'));
  }

  // ----------------------------------------------------------------------------
  // Send Notification
  static void scheduleReminder(DateTime reminderTime, String productName, int notiID) async {
    tz.initializeTimeZones();
    final String currentTimezone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimezone));

    var scheduledNotificationDateTime = tz.TZDateTime.from(reminderTime, tz.local);

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

  static void deleteSpecificScheduledReminder(int id) async {
    await flutterLocalNotificationPlugin
        .cancel(id)
        .whenComplete(() => print('>>>>> This reminder has been deleted. <<<<<'));
  }

  static void deleteAllScheduledReminder(BuildContext context) async {
    await flutterLocalNotificationPlugin
        .cancelAll()
        .whenComplete(() => print('All reminders have been deleted.'))
        .whenComplete(() => showToast('Scheduled reminders deleted.'));
  }

  static int getUniqueRandomNumber() {
    dynamic randomNumberList = List<int>.generate(1000, (index) => index + 1)..shuffle();

    return randomNumberList.removeLast();
  }

  static String barcodeUrl(String barcodeNumber) {
    return "https://api.upcdatabase.org/product/$barcodeNumber?apikey=4653186551EF1AA505DE0EC0CEB509C0";
  }
}
