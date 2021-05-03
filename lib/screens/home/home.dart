import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/form/edit_reminder.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
        .collection('reminders')
        .orderBy('expiryDate');

    final completedReminders = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('completedReminders')
        .orderBy('expiryDate');

    return SingleChildScrollView(
      child: Column(
        children: [
          _showAllItems(context, reminderRef.snapshots(), 'Fresh'),
          _showAllItems(context, reminderRef.snapshots(), 'Expired'),
          Divider(height: 20, thickness: 10),
          _showCompletedItems(context, completedReminders.snapshots()),
          // SizedBox(height: 40)
        ],
      ),
    );
  }

  _showAllItems(BuildContext context, Stream<QuerySnapshot> streamSnapshot, String category) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Colors.grey[200],
        child: ExpandablePanel(
          header: ListTile(
            leading: category == 'Fresh'
                ? CircleAvatar(backgroundColor: appGreen)
                : CircleAvatar(backgroundColor: appRed),
            title: category == 'Fresh'
                ? Text('Fresh Items',
                    style: TextStyle(color: appGreen, fontWeight: FontWeight.bold, fontSize: 20))
                : Text('Expired Items',
                    style: TextStyle(color: appRed, fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          expanded: StreamBuilder(
            stream: streamSnapshot,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
                itemBuilder: (context, index) {
                  if (snapshot.data.documents.length != 0) {
                    if (category == 'Fresh') {
                      try {
                        print('>>>>>> CHECKING FOR EXPIRED ITEMS IN BACKGROUND <<<<<');
                        if (showDateDifference(
                                    snapshot.data.documents[index].data['expiryDate'].toDate()) <=
                                0 ||
                            snapshot.data.documents[index].data['expiryDate'].toDate ==
                                DateTime.now()) {
                          snapshot.data.documents[index].reference.updateData({'isExpired': 'Yes'});
                        }
                      } catch (e) {
                        print(e.toString());
                        print(snapshot.data.documents[index].data['expiryDate'].toDate());
                      }
                    }
                  }
                  if (category == 'Fresh' &&
                      snapshot.data.documents[index].data['isExpired'] == 'No') {
                    return ReminderTile(
                      documentRef: snapshot.data.documents[index],
                      popUpPrimaryMessage: 'Mark as complete',
                    );
                  } else {
                    if (category != 'All' &&
                        category != 'Fresh' &&
                        snapshot.data.documents[index].data['isExpired'] == 'Yes') {
                      return ReminderTile(
                        documentRef: snapshot.data.documents[index],
                        popUpPrimaryMessage: 'Mark as complete',
                      );
                    } else {
                      return Container();
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

  _showCompletedItems(BuildContext context, Stream<QuerySnapshot> streamSnapshot) {
    final user = Provider.of<User>(context);
    final reminderRef =
        Firestore.instance.collection('appUsers').document(user.uid).collection('reminders');

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.only(left: 10, bottom: 10.0),
          child: Row(
            children: [
              CircleAvatar(backgroundColor: Colors.grey),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text('Completed Items',
                    style: TextStyle(
                        color: appListTileGrey, fontWeight: FontWeight.bold, fontSize: 20)),
              ),
            ],
          ),
        ),
        Container(
          height: Get.height * 0.5,
          child: StreamBuilder(
            key: UniqueKey(),
            stream: streamSnapshot,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null)
                return SpinKitFadingCube(color: appBottomNavGreen, size: 70);
              return snapshot.data.documents.length != 0
                  ? new ListView.builder(
                      key: UniqueKey(),
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
                      controller: PageController(viewportFraction: 0.7),
                      // onPageChanged: (int newIndex) =>
                      //     setState(() => _index = newIndex),
                      itemBuilder: (context, index) {
                        return InkWell(
                          key: UniqueKey(),
                          splashColor: appGreen,
                          onTap: () =>
                              Get.to(() => EditReminder(docToEdit: snapshot.data.documents[index])),
                          onLongPress: () {
                            showCupertinoModalPopup(
                                context: context,
                                builder: (BuildContext context) => CupertinoActionSheet(
                                      actions: [
                                        CupertinoActionSheetAction(
                                            isDefaultAction: true,
                                            onPressed: () {
                                              if (showDateDifference(snapshot
                                                      .data.documents[index].data['reminderDate']
                                                      .toDate()) >
                                                  0) {
                                                scheduleReminder(
                                                    snapshot
                                                        .data.documents[index].data['reminderDate']
                                                        .toDate(),
                                                    snapshot
                                                        .data.documents[index].data['reminderName'],
                                                    getUniqueRandomNumber());
                                              }
                                              reminderRef
                                                  .add({
                                                    'notificationID': snapshot.data.documents[index]
                                                        .data['notificationID'],
                                                    'productImage': snapshot
                                                        .data.documents[index].data['productImage'],
                                                    'productBarcode': snapshot.data.documents[index]
                                                        .data['productBarcode'],
                                                    'reminderName': snapshot
                                                        .data.documents[index].data['reminderName'],
                                                    'reminderDate': snapshot
                                                        .data.documents[index].data['reminderDate'],
                                                    'reminderDesc': snapshot
                                                        .data.documents[index].data['reminderDesc'],
                                                    'isExpired': snapshot
                                                        .data.documents[index].data['isExpired'],
                                                    'expiryDate': snapshot
                                                        .data.documents[index].data['expiryDate'],
                                                  })
                                                  .whenComplete(() => deleteReminder(
                                                      snapshot.data.documents[index], false))
                                                  .whenComplete(() => Navigator.pop(context));
                                            },
                                            child: Text('Restore')),
                                        CupertinoActionSheetAction(
                                            isDestructiveAction: true,
                                            onPressed: () =>
                                                deleteReminder(snapshot.data.documents[index], true)
                                                    .whenComplete(() => Navigator.pop(context)),
                                            child: Text('Delete')),
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text('Cancel'),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                    ));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            height: 270,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 200,
                                  decoration: BoxDecoration(
                                      image:
                                          snapshot.data.documents[index].data['productImage'] == null
                                              ? DecorationImage(
                                                  image: AssetImage('assets/image_placeholder.png'),
                                                  fit: BoxFit.cover)
                                              : DecorationImage(
                                                  image: NetworkImage(snapshot
                                                      .data.documents[index].data['productImage']),
                                                  fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.grey)),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                                  child: Text(
                                    snapshot.data.documents[index].data['reminderName'],
                                    style: errorTextStyle.copyWith(color: appBottomNavGreen),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                  child: Text(
                                    showDateDifference(snapshot
                                                .data.documents[index].data['expiryDate']
                                                .toDate()) <=
                                            0
                                        ? 'Expired on: ' +
                                            dateFormat.format(snapshot
                                                .data.documents[index].data['expiryDate']
                                                .toDate())
                                        : 'Expiring on: ' +
                                            dateFormat.format(snapshot
                                                .data.documents[index].data['expiryDate']
                                                .toDate()),
                                    style: showDateDifference(snapshot
                                                .data.documents[index].data['expiryDate']
                                                .toDate()) <=
                                            0
                                        ? errorTextStyle.copyWith(fontSize: 14)
                                        : TextStyle(),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      })
                  : Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Text('There is no completed reminders.',
                            style: errorTextStyle.copyWith(color: appBottomNavGreen)),
                      ),
                    );
            },
          ),
        ),
      ]),
    );
  }
}
