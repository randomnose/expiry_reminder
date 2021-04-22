import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/form/edit_reminder.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

    return SingleChildScrollView(
      child: Column(
        children: [
          _showAllItems(context, reminderRef.snapshots(), 'All'),
          _showAllItems(context, reminderRef.snapshots(), 'Fresh'),
          _showAllItems(context, reminderRef.snapshots(), 'Expired'),
          SizedBox(height: 20),
          Divider(
            height: 20,
            thickness: 10,
          ),
          Text('Completed items'),
          _showCompletedItems(context, reminderRef.snapshots())
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
                  if (category == 'All' ||
                      category == 'Fresh' &&
                          snapshot.data.documents[index].data['isCompleted'] ==
                              false) {
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
                  if (category == 'All' &&
                      snapshot.data.documents[index].data['isCompleted'] ==
                          false) {
                    return InkWell(
                      onTap: () => Get.to(() => EditReminder(
                            docToEdit: snapshot.data.documents[index],
                          )),
                      onLongPress: () {
                        showCupertinoModalPopup(
                            context: context,
                            builder: (BuildContext context) =>
                                CupertinoActionSheet(
                                  actions: [
                                    CupertinoActionSheetAction(
                                        isDefaultAction: true,
                                        onPressed: () => snapshot
                                                .data.documents[index].reference
                                                .updateData({
                                              'isCompleted': true
                                            }).whenComplete(() =>
                                                    Navigator.pop(context)),
                                        child: Text('Mark as finished')),
                                    CupertinoActionSheetAction(
                                        isDestructiveAction: true,
                                        onPressed: () => snapshot
                                            .data.documents[index].reference
                                            .delete()
                                            .whenComplete(
                                                () => Navigator.pop(context)),
                                        child: Text('Delete')),
                                  ],
                                  cancelButton: CupertinoActionSheetAction(
                                    child: Text('Cancel'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ));
                      },
                      child: ReminderTile(
                        reminderTitle:
                            snapshot.data.documents[index].data['reminderName'],
                        expiryDate: 'Expiring on: ' +
                            dateFormat.format(snapshot
                                .data.documents[index].data['expiryDate']
                                .toDate()),
                      ),
                    );
                  } else {
                    if (category == 'Fresh' &&
                        snapshot.data.documents[index].data['isExpired'] ==
                            'No' &&
                        snapshot.data.documents[index].data['isCompleted'] ==
                            false) {
                      return InkWell(
                        onTap: () => Get.to(() => EditReminder(
                              docToEdit: snapshot.data.documents[index],
                            )),
                        onLongPress: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) =>
                                  CupertinoActionSheet(
                                    actions: [
                                      CupertinoActionSheetAction(
                                          isDefaultAction: true,
                                          onPressed: () => snapshot.data
                                                  .documents[index].reference
                                                  .updateData({
                                                'isCompleted': true
                                              }).whenComplete(() =>
                                                      Navigator.pop(context)),
                                          child: Text('Mark as finished')),
                                      CupertinoActionSheetAction(
                                          isDestructiveAction: true,
                                          onPressed: () => snapshot
                                              .data.documents[index].reference
                                              .delete()
                                              .whenComplete(
                                                  () => Navigator.pop(context)),
                                          child: Text('Delete'))
                                    ],
                                    cancelButton: CupertinoActionSheetAction(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                  ));
                        },
                        child: ReminderTile(
                          reminderTitle: snapshot
                              .data.documents[index].data['reminderName'],
                          expiryDate: 'Expiring on: ' +
                              dateFormat.format(snapshot
                                  .data.documents[index].data['expiryDate']
                                  .toDate()),
                        ),
                      );
                    } else {
                      if (category != 'All' &&
                          category != 'Fresh' &&
                          snapshot.data.documents[index].data['isExpired'] ==
                              'Yes' &&
                          snapshot.data.documents[index].data['isCompleted'] ==
                              false) {
                        return InkWell(
                          onTap: () => Get.to(() => EditReminder(
                                docToEdit: snapshot.data.documents[index],
                              )),
                          onLongPress: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) =>
                                    CupertinoActionSheet(
                                      actions: [
                                        CupertinoActionSheetAction(
                                            isDefaultAction: true,
                                            onPressed: () => snapshot.data
                                                    .documents[index].reference
                                                    .updateData({
                                                  'isCompleted': true
                                                }).whenComplete(() =>
                                                        Navigator.pop(context)),
                                            child: Text('Mark as finished')),
                                        CupertinoActionSheetAction(
                                            isDestructiveAction: true,
                                            onPressed: () => snapshot
                                                .data.documents[index].reference
                                                .delete()
                                                .whenComplete(() =>
                                                    Navigator.pop(context)),
                                            child: Text('Delete'))
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel'),
                                      ),
                                    ));
                          },
                          child: ReminderTile(
                            reminderTitle: snapshot
                                .data.documents[index].data['reminderName'],
                            expiryDate: 'Expired on: ' +
                                dateFormat.format(snapshot
                                    .data.documents[index].data['expiryDate']
                                    .toDate()),
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

  _showCompletedItems(
      BuildContext context, Stream<QuerySnapshot> streamSnapshot) {
    return StreamBuilder(
        stream: streamSnapshot,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return ListView.builder(
              itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (snapshot.data.documents[index].data['isCompleted'] ==
                    true) {
                  return InkWell(
                    onLongPress: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) =>
                              CupertinoActionSheet(
                                actions: [
                                  CupertinoActionSheetAction(
                                      isDefaultAction: true,
                                      onPressed: () => snapshot
                                              .data.documents[index].reference
                                              .updateData({
                                            'isCompleted': false
                                          }).whenComplete(
                                                  () => Navigator.pop(context)),
                                      child: Text('Mark as incomplete')),
                                  CupertinoActionSheetAction(
                                      isDestructiveAction: true,
                                      onPressed: () => snapshot
                                          .data.documents[index].reference
                                          .delete()
                                          .whenComplete(
                                              () => Navigator.pop(context)),
                                      child: Text('Delete'))
                                ],
                                cancelButton: CupertinoActionSheetAction(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                              ));
                    },
                    child: ReminderTile(
                      reminderTitle:
                          snapshot.data.documents[index].data['reminderName'],
                      expiryDate: 'Expiring at: ' +
                          dateFormat.format(snapshot
                              .data.documents[index].data['expiryDate']
                              .toDate()),
                    ),
                  );
                }
                return Container();
              });
        });
  }
  // TODO: send email notification
  // get product name, and expiry date using the following method:
  // forEach reminder, if reminderDate <= DateTime.now(),
  // then append the product name and expiry date into a dynamic list.
  // email that dynamic list to user's email.
}
