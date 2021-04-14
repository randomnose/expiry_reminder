import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/form/edit_reminder.dart';
import 'package:expiry_reminder/screens/form/add_reminder.dart';
import 'package:expiry_reminder/screens/home/reminder_tile.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

/// ========================================================
/// This is the landing page of the mobile application
/// ========================================================
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    // final user = Provider.of<User>(context);
    // final userName = DatabaseService(user.uid).

    // void _showSettingsPanel() {
    //   showModalBottomSheet(
    //       context: context,
    //       builder: (context) {
    //         return Container(
    //           padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
    //           child: SettingsForm(),
    //         );
    //       });
    // }
    final user = Provider.of<User>(context);
    final reminderRef = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders');

    return Scaffold(
      appBar: AppBar(
        title: Text('Expiry Reminder'),
        centerTitle: true,
        backgroundColor: Colors.green[600],
        actions: [
          FlatButton.icon(
            icon: Icon(Icons.logout),
            label: Text('Logout'),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder(
          stream: reminderRef.snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => Get.to(() => EditReminder(docToEdit: snapshot.data.documents[index],)),
                  child: ReminderTile(
                    reminderTitle:
                        snapshot.data.documents[index].data['reminderName'],
                    expiryDate: snapshot
                        .data.documents[index].data['reminderDate']
                        .toDate(),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddNewReminder()),
        child: Icon(Icons.add),
      ),
    );
  }
}
