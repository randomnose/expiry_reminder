import 'package:expiry_reminder/screens/form/add_reminder.dart';
import 'package:expiry_reminder/screens/home/home.dart';
import 'package:expiry_reminder/screens/home/settings/settings.dart';
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
      backgroundColor: Colors.grey[100],
      body: tabs[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => Get.to(() => AddNewReminder()),
              child: Center(child: Icon(Icons.add)),
              backgroundColor: appButtonBrown,
              elevation: 5,
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,
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
          unselectedItemColor: appGreen,
          selectedFontSize: 17,
          unselectedFontSize: 14,
          selectedIconTheme: IconThemeData(size: 30),
          items: [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.square_list), label: 'Reminders'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings_solid), label: 'Settings')
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
