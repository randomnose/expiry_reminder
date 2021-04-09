import 'package:expiry_reminder/models/reminder.dart';
import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/home/reminder_list.dart';
import 'package:expiry_reminder/screens/home/settings_form.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:expiry_reminder/services/database.dart';
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
    final user = Provider.of<User>(context);
    // final userName = DatabaseService(user.uid).

    void _showSettingsPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
              child: SettingsForm(),
            );
          });
    }

    return StreamProvider<List<Reminder>>.value(
      value: DatabaseService().testCollection,
      child: Scaffold(
        backgroundColor: Colors.brown[50],
        appBar: AppBar(
          title: Text('Expiry Reminder'),
          centerTitle: true,
          backgroundColor: Colors.brown[400],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(Icons.logout),
              label: Text('Log out'),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.settings),
              label: Text('Settings'),
              onPressed: () {
                _showSettingsPanel();
              },
            )
          ],
        ),
        body: StreamBuilder(
            stream: DatabaseService(uid: user.uid).userData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                UserData userData = snapshot.data;

                return Stack(
                  children: [
                    Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('assets/plant.jpg'),
                                fit: BoxFit.cover)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Current user is -> ${userData.name}",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            ReminderList(),
                          ],
                        )),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20.0, right: 20),
                        child: FloatingActionButton(
                          onPressed: () {},
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Container(height: 10);
              }
            }),
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
      ),
    );
  }
}
