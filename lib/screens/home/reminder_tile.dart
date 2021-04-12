import 'package:flutter/material.dart';

// TODO: add properties for reminder tile
// so that it can be passed into the add reminder form.
class ReminderTile extends StatefulWidget {
  final String reminderTitle;
  final DateTime expiryDate;

  const ReminderTile({Key key, this.reminderTitle, this.expiryDate}) : super(key: key);

  @override
  _ReminderTileState createState() => _ReminderTileState();
}

class _ReminderTileState extends State<ReminderTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Card(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 0),
        child: ListTile(
          leading: CircleAvatar(radius: 25, backgroundColor: Colors.brown[300]),
          title: Text(
            widget.reminderTitle,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(widget.expiryDate.toString()),
        ),
      ),
    );
  }
}
