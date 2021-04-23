import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Profile page'),
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
    ]);
  }
}
