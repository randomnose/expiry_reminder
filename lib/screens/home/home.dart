import 'package:expiry_reminder/screens/form/reminder_form.dart';
import 'package:expiry_reminder/screens/home/reminder_tile.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:get/get.dart';

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
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: 1,
        itemBuilder: (context, index) {
          return ReminderTile();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddNewReminder()),
        child: Icon(Icons.add),
      ),
    );
  }
}
