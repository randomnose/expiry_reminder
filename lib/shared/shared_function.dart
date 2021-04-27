import 'dart:math';

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
deleteReminder(DocumentSnapshot docToDelete, bool ifDeleteImage) async {
  if (ifDeleteImage == true) {
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
// TODO: send email notification
// get product name, and expiry date using the following method:
// forEach reminder, if reminderDate <= DateTime.now(),
// then append the product name and expiry date into a dynamic list.
// email that dynamic list to user's email.
var mailgun = MailgunMailer(
  apiKey: "56f7e0602e42e7e38e1b6079028afda1-4b1aa784-71f811ea",
  domain: "sandboxddbffdb626f447c5bc11b59fcf3405fe.mailgun.org",
);

// Future sendReminder(String reminderTitle, int due) async {
//   var response = await mailgun.send(
//     from:
//         "Expiry Reminder <mailgun@sandboxddbffdb626f447c5bc11b59fcf3405fe.mailgun.org>",
//     to: ["er17071143@gmail.com"],
//     subject: due == 0
//         ? "Hey, your $reminderTitle is expiring today!"
//         : "Hey, your $reminderTitle is expiring in $due day(s)!",
//     text:
//         "We're glad that you're using our app. Allow us to use this opportunity to let you know that your food: \n $reminderTitle is expiring soon! Don't forget to eat it before it expires. Have a nice day!",
//   );
//   print(response.status);
//   print(response.message);
// }
Future sendReminder() async {
  var response = await mailgun.send(
    from:
        "Expiry Reminder <mailgun@sandboxddbffdb626f447c5bc11b59fcf3405fe.mailgun.org>",
    to: ["er17071143@gmail.com"],
    subject: "Hey your food is expiring! Don't forget to eat them!",
    text:
        "We're glad that you're using our app. Allow us to use this opportunity to let you know that your food is expiring soon! Don't forget to eat it before it expires. Have a nice day!",
  );
  print(response.status);
  print(response.message);
}

// ----------------------------------------------------------------------------
// Send Notification
void scheduleReminder(DateTime reminderTime, String productName) async {
  final _randomiser = new Random();
  final int randomNumber = _randomiser.nextInt(100);
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
        randomNumber,
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
