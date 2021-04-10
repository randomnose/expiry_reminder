// import 'package:expiry_reminder/models/user.dart';
// import 'package:expiry_reminder/services/database.dart';
// import 'package:expiry_reminder/shared/loading.dart';
// import 'package:flutter/material.dart';
// import 'package:expiry_reminder/shared/constants.dart';
// import 'package:provider/provider.dart';

// class SettingsForm extends StatefulWidget {
//   @override
//   _SettingsFormState createState() => _SettingsFormState();
// }

// class _SettingsFormState extends State<SettingsForm> {
//   final _formKey = GlobalKey<FormState>();
//   final List<String> sugars = ['0', '1', '2', '3', '4'];

//   // form values
//   String _currentName;
//   String _currentSugars;
//   int _currentStrength;

//   @override
//   Widget build(BuildContext context) {
//     final user = Provider.of<User>(context);

//     return StreamBuilder<UserData>(
//         stream: DatabaseService(uid: user.uid).userData,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             UserData userData = snapshot.data;

//             return Form(
//               key: _formKey,
//               child: Column(
//                 children: [
//                   Text(
//                     'Update your settings',
//                     style: eRNormalText.copyWith(fontSize: 18),
//                   ),
//                   SizedBox(height: 20),
//                   TextFormField(
//                     initialValue: userData.name,
//                     decoration: textInputDecoration.copyWith(hintText: 'Name'),
//                     validator: (formVal) =>
//                         formVal.isEmpty ? 'Enter your name' : null,
//                     onChanged: (val) {
//                       setState(() => _currentName = val);
//                     },
//                   ),
//                   SizedBox(height: 20),
//                   // dropdown
//                   DropdownButtonFormField(
//                     decoration: textInputDecoration,
//                     value: _currentSugars ?? userData.sugars,
//                     items: sugars.map((sugar) {
//                       return DropdownMenuItem(
//                         value: sugar,
//                         child: Text('$sugar sugars'),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         _currentSugars = value;
//                       });
//                     },
//                   ),
//                   SizedBox(height: 20),
//                   // slider
//                   Slider(
//                     min: 100,
//                     max: 900,
//                     divisions: 8,
//                     onChanged: (sliderVal) {
//                       setState(() {
//                         _currentStrength = sliderVal.round();
//                       });
//                     },
//                     value: (_currentStrength ?? userData.strength).toDouble(),
//                     activeColor:
//                         Colors.brown[_currentStrength ?? userData.strength],
//                     inactiveColor:
//                         Colors.brown[_currentStrength ?? userData.strength],
//                   ),

//                   SizedBox(height: 20),
//                   // button
//                   RaisedButton(
//                     color: Colors.pink[400],
//                     child: Text(
//                       'Confirm update',
//                       style: TextStyle(color: Colors.white),
//                     ),
//                     onPressed: () async {
//                       if (_formKey.currentState.validate()) {
//                         await DatabaseService(uid: user.uid).updateUserData(
//                             _currentSugars ?? userData.sugars,
//                             _currentName ?? userData.name,
//                             _currentStrength ?? userData.strength);
//                         Navigator.of(context).pop();
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             );
//           } else {
//             return Loading();
//           }
//         });
//   }
// }
