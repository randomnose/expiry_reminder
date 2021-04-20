import 'package:flutter/material.dart';

class ReminderTile extends StatefulWidget {
  final String reminderTitle;
  final String expiryDate;

  const ReminderTile({Key key, this.reminderTitle, this.expiryDate}) : super(key: key);

  @override
  _ReminderTileState createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(15, 0, 15, 10),
      child: Card(
        child: ListTile(
          leading: CircleAvatar(radius: 25, backgroundColor: Colors.brown[300]),
          title: Text(
            widget.reminderTitle,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(widget.expiryDate),
        ),
      ),
    );
  }
}
