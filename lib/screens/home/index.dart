import 'package:expiry_reminder/screens/home/home.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';

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
  final tabs = [Home(), Center(child: Text('Settings'))];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CupertinoNavigationBar(
        backgroundColor: appGreen,
        middle: Text(
          'Expiry Reminder',
          style: TextStyle(fontSize: 20),
        ),
        trailing: TextButton(
          child: Text('Log out', style: TextStyle(color: Colors.white)),
          onPressed: () async {
            await _auth.signOut();
          },
        ),
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: appBgGrey,
        selectedItemColor: CupertinoColors.black,
        unselectedItemColor: appGreen,
        selectedFontSize: 17,
        unselectedFontSize: 14,
        items: [
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.doc), label: 'Reminders'),
          BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings), label: 'Settings')
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
