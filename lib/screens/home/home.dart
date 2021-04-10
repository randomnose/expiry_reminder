import 'package:expiry_reminder/models/reminder.dart';
import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/home/reminder_list.dart';
import 'package:expiry_reminder/screens/home/settings_form.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:expiry_reminder/services/database.dart';
import 'package:provider/provider.dart';
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
    final user = Provider.of<User>(context);
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
        elevation: 0.0,
        actions: <Widget>[
          FlatButton.icon(
            icon: Icon(Icons.logout),
            label: Text(''),
            onPressed: () async {
              await _auth.signOut();
            },
          ),
          // FlatButton.icon(
          //   icon: Icon(Icons.settings),
          //   label: Text('Settings'),
          //   onPressed: () {
          //     _showSettingsPanel();
          //   },
          // )
        ],
      ),
      body: Container(
          width: Get.width,
          height: Get.height,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/plant.jpg'), fit: BoxFit.cover)),
          child: Text(
            "hi",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )),
      // body: Container(
      //     decoration: BoxDecoration(
      //         image: DecorationImage(
      //             image: AssetImage('assets/plant.jpg'), fit: BoxFit.cover)),
      //     child: Column(
      //       children: [
      //         // Text("Current user is -> ${userData.name}", style: eRNormalText,),
      //         ReminderList(),
      //       ],
      //     )),
    );
  }
}
