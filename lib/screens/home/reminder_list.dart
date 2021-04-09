import 'package:expiry_reminder/models/reminder.dart';
import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/home/reminder_tile.dart';
import 'package:expiry_reminder/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReminderList extends StatefulWidget {
  @override
  _ReminderListState createState() => _ReminderListState();
}

class _ReminderListState extends State<ReminderList> {
  @override
  Widget build(BuildContext context) {
    // final reminders = Provider.of<List<Reminder>>(context) ?? [];

    // reminders.forEach((reminder) {
    //   print(reminder.name);
    //   print(reminder.strength);
    //   print(reminder.sugars);
    // });

    // return ListView.builder(
    //   itemCount: reminders.length,
    //   itemBuilder: (context, index) {
    //     return ReminderTile(reminder: reminders[index]);
    //   },
    // );
    
    // ============================================
    // print reminder of a single person only
    final user = Provider.of<User>(context);
    return StreamBuilder<UserData>(
      stream: DatabaseService(uid: user.uid).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          UserData userData = snapshot.data;
          return ReminderTile(
            reminder: DatabaseService().convertToReminder(userData),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
