import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dateFormat = new DateFormat.yMd();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final reminderRef = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders');

    final completedReminders = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('completedReminders');

    return SingleChildScrollView(
      child: Column(
        children: [
          _showAllItems(context, reminderRef.snapshots(), 'All'),
          _showAllItems(context, reminderRef.snapshots(), 'Fresh'),
          _showAllItems(context, reminderRef.snapshots(), 'Expired'),
          SizedBox(height: 20),
          Divider(height: 20, thickness: 10),
          _showCompletedItems(context, completedReminders.snapshots()),
          TextButton(
              child: Text('reset all reminders'),
              onPressed: deleteAllScheduledReminder)
        ],
      ),
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
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: appListTileGrey))
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
            // subtitle: Text(length.toString()),
          ),
          expanded: StreamBuilder(
            stream: streamSnapshot,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount:
                    snapshot.hasData ? snapshot.data.documents.length : 0,
                itemBuilder: (context, index) {
                  if (snapshot.data.documents.length != 0) {
                    if (category == 'All' || category == 'Fresh') {
                      try {
                        print(
                            '>>>>>> CHECKING FOR EXPIRED ITEMS IN BACKGROUND <<<<<');
                        if (showDateDifference(snapshot
                                    .data.documents[index].data['expiryDate']
                                    .toDate()) <=
                                0 ||
                            snapshot.data.documents[index].data['expiryDate']
                                    .toDate ==
                                DateTime.now()) {
                          snapshot.data.documents[index].reference
                              .updateData({'isExpired': 'Yes'});
                        }
                      } catch (e) {
                        print(e.toString());
                        print(snapshot.data.documents[index].data['expiryDate']
                            .toDate());
                      }
                    }
                  }
                  if (category == 'All') {
                    return ReminderTile(
                      documentRef: snapshot.data.documents[index],
                      popUpPrimaryMessage: 'Mark as complete',
                      isCompleted: false,
                    );
                  } else {
                    if (category == 'Fresh' &&
                        snapshot.data.documents[index].data['isExpired'] ==
                            'No') {
                      return ReminderTile(
                        documentRef: snapshot.data.documents[index],
                        popUpPrimaryMessage: 'Mark as complete',
                        isCompleted: false,
                      );
                    } else {
                      if (category != 'All' &&
                          category != 'Fresh' &&
                          snapshot.data.documents[index].data['isExpired'] ==
                              'Yes') {
                        return ReminderTile(
                          documentRef: snapshot.data.documents[index],
                          popUpPrimaryMessage: 'Mark as complete',
                          isCompleted: false,
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

  _showCompletedItems(
      BuildContext context, Stream<QuerySnapshot> streamSnapshot) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        color: Colors.grey[200],
        child: ExpandablePanel(
          header: ListTile(
            leading: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 7.0),
                  child: Icon(CupertinoIcons.checkmark_seal, size: 28),
                ),
              ],
            ),
            title: Text(
              'Completed Items',
              style: TextStyle(
                  color: appListTileGrey.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ),
          expanded: StreamBuilder(
              stream: streamSnapshot,
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                return ListView.builder(
                    itemCount:
                        snapshot.hasData ? snapshot.data.documents.length : 0,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ReminderTile(
                        documentRef: snapshot.data.documents[index],
                        popUpPrimaryMessage: 'Restore',
                        isCompleted: true,
                      );
                    });
              }),
        ),
      ),
    );
  }
}
