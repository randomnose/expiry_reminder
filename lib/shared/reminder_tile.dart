import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/form/edit_reminder.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

class ReminderTile extends StatefulWidget {
  final DocumentSnapshot documentRef;
  final String popUpPrimaryMessage;
  const ReminderTile({Key key, this.documentRef, this.popUpPrimaryMessage})
      : super(key: key);

  @override
  _ReminderTileState createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  final dateFormat = new DateFormat.yMd();
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final completedReminders = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('completedReminders');

    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Card(
        child: ListTile(
            onTap: () => Get.to(() => EditReminder(docToEdit: widget.documentRef)),
            onLongPress: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (BuildContext context) => CupertinoActionSheet(
                        actions: [
                          CupertinoActionSheetAction(
                              isDefaultAction: true,
                              onPressed: () {
                                deleteSpecificScheduledReminder(
                                    widget.documentRef.data['notificationID']);
                                completedReminders
                                    .add({
                                      'notificationID': widget.documentRef.data['notificationID'],
                                      'productImage': widget.documentRef.data['productImage'],
                                      'productBarcode': widget.documentRef.data['productBarcode'],
                                      'reminderName': widget.documentRef.data['reminderName'],
                                      'reminderDate': widget.documentRef.data['reminderDate'],
                                      'reminderDesc': widget.documentRef.data['reminderDesc'],
                                      'isExpired': widget.documentRef.data['isExpired'],
                                      'expiryDate': widget.documentRef.data['expiryDate'],
                                    })
                                    .whenComplete(() => deleteReminder(widget.documentRef, false))
                                    .whenComplete(() => Navigator.pop(context));
                              },
                              child: Text(widget.popUpPrimaryMessage)),
                          CupertinoActionSheetAction(
                              isDestructiveAction: true,
                              onPressed: () => deleteReminder(widget.documentRef, true)
                                  .whenComplete(() => Navigator.pop(context)),
                              child: Text('Delete')),
                        ],
                        cancelButton: CupertinoActionSheetAction(
                          child: Text('Cancel'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ));
            },
            leading: CircleAvatar(
              backgroundColor: Colors.grey[400],
              radius: 25,
              backgroundImage: widget.documentRef.data['productImage'] == ''
                  ? AssetImage(
                      'assets/image_placeholder.jpg',
                    )
                  : NetworkImage(
                      widget.documentRef.data['productImage'],
                    ),
            ),
            title: Text(widget.documentRef.data['reminderName'],
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: showDateDifference(widget.documentRef.data['expiryDate'].toDate()) <= 0
                ? Text(
                    'Expired on: ' +
                        dateFormat.format(widget.documentRef.data['expiryDate'].toDate()),
                    style: errorTextStyle.copyWith(fontSize: 14),
                  )
                : Text('Expiring on: ' +
                    dateFormat.format(widget.documentRef.data['expiryDate'].toDate()))),
      ),
    );
  }
}
