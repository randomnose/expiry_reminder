import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/form/edit_reminder.dart';
import 'package:expiry_reminder/screens/form/add_reminder.dart';
import 'package:expiry_reminder/screens/home/reminder_tile.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
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
    final user = Provider.of<User>(context);
    final reminderRef = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders');

    return Scaffold(
      backgroundColor: appBgGrey,
      // appBar: CupertinoNavigationBar(
      //   backgroundColor: appGreen,
      //   middle: Text(
      //     'Expiry Reminder',
      //     style: TextStyle(fontSize: 20),
      //   ),
      //   trailing: TextButton(
      //     child: Text('Log out', style: TextStyle(color: Colors.white)),
      //     onPressed: () async {
      //       await _auth.signOut();
      //     },
      //   ),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _showAllItems(context, reminderRef.snapshots(), 'All'),
            _showAllItems(context, reminderRef.snapshots(), 'Fresh'),
            _showAllItems(context, reminderRef.snapshots(), 'Expired'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddNewReminder()),
        child: Center(child: Icon(CupertinoIcons.add)),
        backgroundColor: appButtonBrown,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   currentIndex: _currentIndex,
      //   backgroundColor: appBgGrey,
      //   selectedItemColor: CupertinoColors.black,
      //   unselectedItemColor: appGreen,
      //   selectedFontSize: 17,
      //   unselectedFontSize: 14,
      //   items: [
      //     BottomNavigationBarItem(
      //         icon: Icon(CupertinoIcons.doc), label: 'Reminders'),
      //     BottomNavigationBarItem(
      //         icon: Icon(CupertinoIcons.settings), label: 'Settings')
      //   ],
      //   onTap: (index) {
      //     setState(() {
      //       _currentIndex = index;
      //     });
      //   },
      // ),
    );
  }

  _showAllItems(BuildContext context, Stream<QuerySnapshot> streamSnapshot,
      String category) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Colors.grey[200],
        child: ExpandablePanel(
          header: ListTile(
            leading: category == 'All'
                ? CircleAvatar(backgroundColor: appListTileGrey)
                : category == 'Fresh'
                    ? CircleAvatar(backgroundColor: appGreen)
                    : CircleAvatar(backgroundColor: appRed),
            title: category == 'All'
                ? Text('All Items',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))
                : category == 'Fresh'
                    ? Text('Fresh Items',
                        style: TextStyle(
                            color: appGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 20))
                    : Text('Expired Items',
                        style: TextStyle(
                            color: appRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 20)),
            subtitle: Text('Insert something here.'),
          ),
          expanded: StreamBuilder(
            stream: streamSnapshot,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount:
                    snapshot.hasData ? snapshot.data.documents.length : 0,
                itemBuilder: (context, index) {
                  if (category == 'All') {
                    return InkWell(
                      onTap: () => Get.to(() => EditReminder(
                            docToEdit: snapshot.data.documents[index],
                          )),
                      child: ReminderTile(
                        reminderTitle:
                            snapshot.data.documents[index].data['reminderName'],
                        expiryDate: snapshot
                            .data.documents[index].data['reminderDate']
                            .toDate(),
                      ),
                    );
                  } else {
                    if (category == 'Fresh' &&
                        snapshot.data.documents[index].data['expiryStatus'] ==
                            'No') {
                      return InkWell(
                        onTap: () => Get.to(() => EditReminder(
                              docToEdit: snapshot.data.documents[index],
                            )),
                        child: ReminderTile(
                          reminderTitle: snapshot
                              .data.documents[index].data['reminderName'],
                          expiryDate: snapshot
                              .data.documents[index].data['reminderDate']
                              .toDate(),
                        ),
                      );
                    } else {
                      if (category != 'All' &&
                          category != 'Fresh' &&
                          snapshot.data.documents[index].data['expiryStatus'] ==
                              'Yes') {
                        return InkWell(
                          onTap: () => Get.to(() => EditReminder(
                                docToEdit: snapshot.data.documents[index],
                              )),
                          child: ReminderTile(
                            reminderTitle: snapshot
                                .data.documents[index].data['reminderName'],
                            expiryDate: snapshot
                                .data.documents[index].data['reminderDate']
                                .toDate(),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
