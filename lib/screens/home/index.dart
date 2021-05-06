import 'package:expiry_reminder/screens/form/add_reminder.dart';
import 'package:expiry_reminder/screens/home/home.dart';
import 'package:expiry_reminder/screens/home/settings.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ========================================================
/// This is the landing page of the mobile application
/// ========================================================
class IndexPage extends StatefulWidget {
  @override
  IndexPageState createState() => IndexPageState();
}

class IndexPageState extends State<IndexPage> {
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
            : Text('Settings', style: TextStyle(fontSize: 20)),
      ),
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Get.to(() => AddNewReminder()),
              child: Center(child: Icon(Icons.menu)),
              backgroundColor: appButtonBrown,
              elevation: 5,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 6,
        color: appBottomNavGreen,
        shape: CircularNotchedRectangle(),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          elevation: 0,
          currentIndex: _currentIndex,
          backgroundColor: appBottomNavGreen,
          selectedItemColor: appBgGrey,
          unselectedItemColor: CupertinoColors.black,
          selectedFontSize: 17,
          unselectedFontSize: 14,
          selectedIconTheme: IconThemeData(size: 30),
          items: [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.square_list), label: 'Reminders'),
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.settings_solid), label: 'Settings')
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
