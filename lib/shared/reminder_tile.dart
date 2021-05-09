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
  const ReminderTile({Key key, this.documentRef, this.popUpPrimaryMessage}) : super(key: key);

  @override
  _ReminderTileState createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  final dateFormat = new DateFormat.yMMMd('en_US');

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);

    final completedReminders = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('completedReminders');

    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Card(
        shadowColor: appGreen,
        elevation: 5,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: appGreen,
          onTap: () => Get.to(() => EditReminder(docToEdit: widget.documentRef)),
          onLongPress: () {
            showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Utils.deleteSpecificScheduledReminder(
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
                                  .whenComplete(
                                      () => Utils.deleteReminder(widget.documentRef, false))
                                  .whenComplete(() => Navigator.pop(context))
                                  .whenComplete(() => Utils.showToast('Marked as complete.'));
                            },
                            child: Text(widget.popUpPrimaryMessage)),
                        CupertinoActionSheetAction(
                            isDestructiveAction: true,
                            onPressed: () => Utils.deleteReminder(widget.documentRef, true)
                                .whenComplete(() => Navigator.pop(context))
                                .whenComplete(() => Utils.showToast('Reminder deleted.')),
                            child: Text('Delete')),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ));
          },
          child: Container(
            height: 110,
            child: Row(
              children: [
                widget.documentRef.data['productImage'] == null
                    ? Image.asset(
                        'assets/image_placeholder.png',
                        fit: BoxFit.cover,
                        height: 110,
                        width: 100,
                        color: appButtonBrown,
                      )
                    : Image.network(
                        widget.documentRef.data['productImage'],
                        fit: BoxFit.cover,
                        height: 110,
                        width: 100,
                      ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(15, 20, 10, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            widget.documentRef.data['reminderName'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: errorTextStyle.copyWith(fontSize: 19, color: appBlack),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Text(
                            widget.documentRef.data['reminderDesc'] == ''
                                ? 'No description'
                                : widget.documentRef.data['reminderDesc'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        Utils.showDateDifference(widget.documentRef.data['expiryDate'].toDate()) <=
                                0
                            ? Text(
                                'Expired on: ' +
                                    dateFormat
                                        .format(widget.documentRef.data['expiryDate'].toDate()),
                                style: errorTextStyle.copyWith(fontSize: 15))
                            : Text(
                                'Expiring on: ' +
                                    dateFormat
                                        .format(widget.documentRef.data['expiryDate'].toDate()),
                                style: errorTextStyle.copyWith(fontSize: 15, color: Colors.black),
                              )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
