import 'package:expiry_reminder/screens/form/add_reminder.dart';
import 'package:expiry_reminder/screens/home/home.dart';
import 'package:expiry_reminder/screens/home/settings.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:get/get.dart';

/// ========================================================
/// This is the landing page of the mobile application
/// ========================================================
class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
  final AuthService _auth = AuthService();

  int _currentIndex = 0;
  final tabs = [Home(), Settings()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: CupertinoNavigationBar(
          backgroundColor: appGreen,
          middle: _currentIndex == 0
              ? Text(
                  'Expiry Reminder',
                  style: TextStyle(fontSize: 20),
                )
              : Text('Profile', style: TextStyle(fontSize: 20)),
          trailing: _currentIndex == 0
              ? TextButton(
                  child: Text('Logout', style: TextStyle(color: Colors.white)),
                  onPressed: () async {
                    await _auth.signOut();
                  },
                )
              : null),
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Get.to(() => AddNewReminder()),
              child: Center(child: Icon(CupertinoIcons.add)),
              backgroundColor: appButtonBrown,
              elevation: 5,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5,
        color: appBottomNavGreen,
        shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: _currentIndex,
          backgroundColor: appBottomNavGreen,
          selectedItemColor: CupertinoColors.black,
          unselectedItemColor: appBgGrey,
          selectedFontSize: 17,
          unselectedFontSize: 14,
          selectedIconTheme: IconThemeData(size: 30),
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_list), label: 'Reminders'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.profile_circled), label: 'Profile')
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
