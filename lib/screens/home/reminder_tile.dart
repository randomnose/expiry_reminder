import 'package:flutter/material.dart';

// TODO: add properties for reminder tile
// so that it can be passed into the add reminder form.
class ReminderTile extends StatefulWidget {
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
            'dummy reminder title for product here',
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text('Here will be the expiry date'),
        ),
      ),
    );
  }
}
