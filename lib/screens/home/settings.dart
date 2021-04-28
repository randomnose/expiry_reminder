import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// TODO: Settings page should be able to remove all reminders
class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<User>(context);
    final reminderRef = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders');

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text('Delete confirmation'),
                        content: Text(
                            'Deleting all scheduled notifications is a non-reversible action.'),
                        actions: [
                          CupertinoDialogAction(
                              child: Text('Confirm'),
                              isDestructiveAction: true,
                              onPressed: () {
                                deleteAllScheduledReminder();
                                Navigator.pop(context);
                              }),
                          CupertinoDialogAction(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context))
                        ],
                      ));
            },
            child: Text('Delete all scheduled notifications')),
        TextButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => CupertinoAlertDialog(
                        title: Text('Delete confirmation'),
                        content: Text(
                            'Deleting all active reminders is a non-reversible action.'),
                        actions: [
                          CupertinoDialogAction(
                            child: Text('Confirm'),
                            onPressed: () async {
                              deleteAllEntries(reminderRef);
                              Navigator.pop(context);
                            },
                            isDestructiveAction: true,
                          ),
                          CupertinoDialogAction(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.pop(context))
                        ],
                      ));
            },
            child: Text('Delete all active reminders')),
        TextButton(
          child: Text('Logout', style: TextStyle(color: appButtonBrown)),
          onPressed: () async {
            await _auth.signOut();
          },
        )
      ],
    ));
  }

  deleteAllEntries(CollectionReference collection) async {
    await collection.getDocuments().then((snapshot) {
      if (snapshot.documents.length != 0) {
        for (DocumentSnapshot doc in snapshot.documents) {
          doc.reference.delete().whenComplete(() {
            print('All active reminders have been deleted.');
            showDialog(
                context: context,
                builder: (BuildContext context) => CupertinoAlertDialog(
                      title: Text('All active reminders have been deleted.'),
                      actions: [
                        CupertinoDialogAction(
                          child: Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ));
          }).catchError((onError) => print(onError));
        }
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
