import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/home/search.dart';
import 'package:expiry_reminder/screens/reminders/all_reminders.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final dateFormat = new DateFormat.yMd();
  final PageController _pageController = PageController(initialPage: 0, viewportFraction: 0.9);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    final reminderRef = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders')
        .where('isExpired', isEqualTo: 'No')
        .orderBy('expiryDate');

    final completedReminders = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('completedReminders')
        .orderBy('expiryDate');

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              width: Get.width,
              margin: EdgeInsets.only(bottom: 20),
              padding: EdgeInsets.fromLTRB(20, 50, 20, 25),
              decoration: BoxDecoration(
                  color: appGreen,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25)),
                  boxShadow: [
                    BoxShadow(
                        offset: Offset(0, 10), blurRadius: 30, color: appGreen.withOpacity(0.5))
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                      text: TextSpan(
                          text: 'Expiry\n',
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold, color: appBgGrey),
                          children: [
                        TextSpan(
                            text: 'Reminder',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: appBlack, fontSize: 24))
                      ])),
                  IconButton(
                      icon: Icon(Icons.search_rounded, size: 35),
                      onPressed: () => Get.to(() => SearchPage()))
                ],
              )),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expiring soon',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: appBlack)),
                ButtonTheme(
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    splashColor: appGreen.withOpacity(0.5),
                    child: RaisedButton(
                      color: appGreen,
                      onPressed: () => Get.to(() => AllReminders()),
                      child: Text(
                        'View all',
                        style: TextStyle(color: appBgGrey),
                      ),
                    ))
              ],
            ),
          ),
          _showExpiringSoonItems(context, reminderRef.snapshots()),
          _showCompletedItems(context, completedReminders.snapshots())
        ],
      ),
    );
  }

  _showExpiringSoonItems(BuildContext context, Stream<QuerySnapshot> streamSnapshot) {
    return StreamBuilder(
      stream: streamSnapshot,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        return Container(
            height: 125,
            child: snapshot.hasData && snapshot.data.documents.length != 0
                ? PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
                    itemBuilder: (context, index) {
                      if (snapshot.data.documents.length != 0) {
                        try {
                          print('>>>>>> CHECKING FOR EXPIRED ITEMS IN BACKGROUND <<<<<');
                          if (Utils.showDateDifference(
                                      snapshot.data.documents[index].data['expiryDate'].toDate()) <=
                                  0 ||
                              snapshot.data.documents[index].data['expiryDate'].toDate() ==
                                  DateTime.now()) {
                            snapshot.data.documents[index].reference
                                .updateData({'isExpired': 'Yes'});
                          }
                        } catch (e) {
                          print(e.toString());
                          print(snapshot.data.documents[index].data['expiryDate'].toDate());
                        }
                      }
                      return ReminderTile(
                        documentRef: snapshot.data.documents[index],
                        popUpPrimaryMessage: 'Mark as complete',
                      ).marginOnly(right: 10);
                    },
                  )
                : Align(
                    alignment: AlignmentDirectional.center,
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('Create a reminder to be reminded of your food\'s expiry date!',
                          style: errorTextStyle.copyWith(color: appBlack)),
                    ),
                  ));
      },
    );
  }

  _showCompletedItems(BuildContext context, Stream<QuerySnapshot> streamSnapshot) {
    final user = Provider.of<User>(context);
    final reminderRef =
        Firestore.instance.collection('appUsers').document(user.uid).collection('reminders');

    return Container(
      width: Get.width,
      padding: EdgeInsets.only(top: 15),
      margin: EdgeInsets.fromLTRB(20, 30, 20, 50),
      decoration: cardDecoration,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 15),
          child: Text('Completed items',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: appBlack)),
        ),
        Container(
          constraints: BoxConstraints(minHeight: Get.height * 0.35 - 40),
          child: StreamBuilder(
            key: UniqueKey(),
            stream: streamSnapshot,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data == null)
                return SpinKitFadingCube(color: appBottomNavGreen, size: 70);
              return snapshot.data.documents.length != 0
                  ? new ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.all(0),
                      key: UniqueKey(),
                      itemCount: snapshot.hasData ? snapshot.data.documents.length : 0,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(20))),
                            child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                splashColor: appGreen,
                                onLongPress: () {
                                  showCupertinoModalPopup(
                                      context: context,
                                      builder: (BuildContext context) => CupertinoActionSheet(
                                            actions: [
                                              CupertinoActionSheetAction(
                                                  isDefaultAction: true,
                                                  onPressed: () {
                                                    if (Utils.showDateDifference(snapshot.data
                                                            .documents[index].data['reminderDate']
                                                            .toDate()) >
                                                        0) {
                                                      Utils.scheduleReminder(
                                                          snapshot.data.documents[index]
                                                              .data['reminderDate']
                                                              .toDate(),
                                                          snapshot.data.documents[index]
                                                              .data['reminderName'],
                                                          Utils.getUniqueRandomNumber());
                                                    }
                                                    reminderRef
                                                        .add({
                                                          'notificationID': snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['notificationID'],
                                                          'productImage': snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['productImage'],
                                                          'productBarcode': snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['productBarcode'],
                                                          'reminderName': snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['reminderName'],
                                                          'reminderDate': snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['reminderDate'],
                                                          'reminderDesc': snapshot
                                                              .data
                                                              .documents[index]
                                                              .data['reminderDesc'],
                                                          'isExpired': snapshot.data
                                                              .documents[index].data['isExpired'],
                                                          'expiryDate': snapshot.data
                                                              .documents[index].data['expiryDate'],
                                                        })
                                                        .whenComplete(() => Utils.deleteReminder(
                                                            snapshot.data.documents[index], false))
                                                        .whenComplete(() => Navigator.pop(context))
                                                        .whenComplete(() =>
                                                            Utils.showToast('Reminder restored.'));
                                                  },
                                                  child: Text('Restore')),
                                              CupertinoActionSheetAction(
                                                  isDestructiveAction: true,
                                                  onPressed: () => Utils.deleteReminder(
                                                          snapshot.data.documents[index], true)
                                                      .whenComplete(() => Navigator.pop(context))
                                                      .whenComplete(() =>
                                                          Utils.showToast('Reminder deleted.')),
                                                  child: Text('Delete')),
                                            ],
                                            cancelButton: CupertinoActionSheetAction(
                                              child: Text('Cancel'),
                                              onPressed: () => Navigator.pop(context),
                                            ),
                                          ));
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(20.0),
                                  child: Text(
                                    snapshot.data.documents[index].data['reminderName'],
                                    style: TextStyle(fontSize: 18, color: appBlack),
                                  ),
                                )),
                          ),
                        );
                      })
                  : Align(
                      alignment: AlignmentDirectional.topCenter,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
                        child: Text('Start filling up this section by consuming your food!',
                            style: errorTextStyle.copyWith(color: appBlack)),
                      ),
                    );
            },
          ),
        ),
      ]),
    );
  }
}
