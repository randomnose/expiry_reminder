import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/home/settings/about_page.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:expandable/expandable.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();
    final user = Provider.of<AppUser>(context);
    final reminderRef =
        FirebaseFirestore.instance.collection('appUsers').doc(user.uid).collection('reminders');

    return SingleChildScrollView(
        child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
            width: Get.width,
            margin: EdgeInsets.only(bottom: 30),
            padding: EdgeInsets.fromLTRB(20, 60, 20, 15),
            decoration: BoxDecoration(color: appGreen, boxShadow: [
              BoxShadow(color: appGreen.withOpacity(0.4), offset: Offset(0, 10), blurRadius: 30)
            ]),
            child: RichText(
                text: TextSpan(
              text: 'Settings',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: appBgGrey),
            ))),
        Container(
            width: Get.width,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: InkWell(
                splashColor: appGreen,
                borderRadius: BorderRadius.circular(15),
                onTap: () => Get.to(() => AboutPage()),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child:
                      Text('About', style: errorTextStyle.copyWith(fontSize: 16, color: appBlack)),
                ),
              ),
            )),
        Container(
          width: Get.width,
          padding: EdgeInsets.fromLTRB(17, 0, 17, 20),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            child: ExpandablePanel(
              theme: ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  expandIcon: Icons.add,
                  collapseIcon: Icons.remove,
                  useInkWell: true),
              header: InkWell(
                splashColor: appGreen,
                borderRadius: BorderRadius.circular(15),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(17, 23, 20, 23),
                  child: Text('Destructive operations',
                      style: errorTextStyle.copyWith(color: appBlack, fontSize: 16)),
                ),
              ),
              collapsed: Container(),
              expanded: Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8),
                child: Column(
                  children: [
                    TextButton(
                      style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(appRed.withOpacity(0.3)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
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
                      child: Text('Delete all scheduled notifications',
                          style: errorTextStyle.copyWith(fontSize: 16)),
                      // margin: EdgeInsets.fromLTRB(10, 10, 10, 10),
                    ),
                    TextButton(
                      style: ButtonStyle(
                          overlayColor: MaterialStateProperty.all(appRed.withOpacity(0.3)),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)))),
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
                      child: Text('Delete all items (Active & Expired)',
                          style: errorTextStyle.copyWith(fontSize: 16)),
                      // margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
            width: Get.width,
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              margin: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: InkWell(
                splashColor: appRed,
                borderRadius: BorderRadius.circular(15),
                onTap: () async {
                  await _auth.signOut();
                },
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Log out ', style: errorTextStyle.copyWith(fontSize: 15)),
                ),
              ),
            )),
      ],
    ));
  }

  deleteAllEntries(CollectionReference collection) async {
    await collection.get().then((snapshot) {
      if (snapshot.docs.length != 0) {
        for (DocumentSnapshot doc in snapshot.docs) {
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
