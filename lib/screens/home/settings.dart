import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<User>(context);
    final reminderRef =
        Firestore.instance.collection('appUsers').document(user.uid).collection('reminders');

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: Get.width,
            padding: EdgeInsets.fromLTRB(20, 60, 20, 15),
            decoration: BoxDecoration(color: appGreen),
            child: RichText(
                text: TextSpan(
              text: 'Settings',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: appBgGrey),
            ))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Text(
            'Destructive operations:',
            style: sectionTitle,
          ),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(20, 0, 20, 15),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.red[400], width: 2.5),
              borderRadius: BorderRadius.all(Radius.circular(8))),
          width: Get.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: Text('Delete all scheduled notifications')),
                    RaisedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => CupertinoAlertDialog(
                                  title: Text('Delete all scheduled notification?'),
                                  content: Text(
                                      'Deleting all scheduled notifications is a non-reversible action.'),
                                  actions: [
                                    CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.pop(context)),
                                    CupertinoDialogAction(
                                        child: Text('Confirm'),
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Utils.deleteAllScheduledReminder(context);
                                          Navigator.pop(context);
                                        })
                                  ],
                                ));
                      },
                      child: Text(
                        'Delete',
                        style: errorTextStyle.copyWith(fontSize: 16),
                      ),
                    )
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text('Delete all items (Fresh & Expired)')),
                  RaisedButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => CupertinoAlertDialog(
                                  title: Text('Delete all reminders?'),
                                  content: Text(
                                      'Deleting all active reminders is a non-reversible action.'),
                                  actions: [
                                    CupertinoDialogAction(
                                        isDefaultAction: true,
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.pop(context)),
                                    CupertinoDialogAction(
                                      child: Text('Confirm'),
                                      onPressed: () async {
                                        deleteAllEntries(reminderRef);
                                        Navigator.pop(context);
                                      },
                                      isDestructiveAction: true,
                                    ),
                                  ],
                                ));
                      },
                      child: Text('Delete', style: errorTextStyle.copyWith(fontSize: 16)))
                ],
              ),
            ],
          ),
        ),
        Divider(thickness: 2),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: TextButton.icon(
              label: Text('Log Out', style: errorTextStyle.copyWith(fontSize: 16)),
              onPressed: () async {
                await _auth.signOut();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.red[400],
              )),
        )
      ],
    ));
  }

  deleteAllEntries(CollectionReference collection) async {
    await collection.getDocuments().then((snapshot) {
      if (snapshot.documents.length != 0) {
        for (DocumentSnapshot doc in snapshot.documents) {
          Utils.deleteReminder(doc, true).catchError((onError) => print(onError));
        }
        Utils.showToast('Active reminders deleted.');
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => CupertinoAlertDialog(
                  title: Text('You do not have any active reminders.'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('OK'),
                      onPressed: () => Navigator.pop(context),
                    )
                  ],
                ));
      }
    });
  }
}
