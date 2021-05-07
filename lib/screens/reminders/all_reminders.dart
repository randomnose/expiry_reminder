import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// TODO: change to streambuilder
class AllReminders extends StatefulWidget {
  @override
  _AllRemindersState createState() => _AllRemindersState();
}

class _AllRemindersState extends State<AllReminders> {
  List _activeReminders = [];
  List _expiredReminders = [];
  Future activeReminders;
  Future expiredReminders;

  @override
  void dispose() {
    _activeReminders = [];
    _expiredReminders = [];
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    activeReminders = getActiveRemindersSnapshot();
    expiredReminders = getExpiredRemindersSnapshot();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: appBlack),
            shadowColor: appBlack,
            backgroundColor: appGreen,
            title: Text('Reminders',
                style: TextStyle(fontWeight: FontWeight.bold, color: appBlack, fontSize: 24)),
            bottom: TabBar(
              indicatorColor: appBgGrey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(child: Text('Active reminders', style: TextStyle(fontSize: 16))),
                Tab(child: Text('Expired reminders', style: TextStyle(fontSize: 16)))
              ],
            ),
          ),
          body: TabBarView(
            children: [
              _activeReminders.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Icon(CupertinoIcons.ellipses_bubble,
                                size: 50, color: appListTileGrey),
                          ),
                          Text('Oops there is no results',
                              style: errorTextStyle.copyWith(color: appListTileGrey)),
                        ],
                      ),
                    )
                  : FutureBuilder(
                      future: getActiveRemindersSnapshot(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.none &&
                            snapshot.hasData == null) {
                          return SpinKitFadingCube(color: appGreen, size: 70);
                        }
                        return Padding(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                          child: ListView.builder(
                            itemCount: _activeReminders.length,
                            itemBuilder: (context, index) {
                              return ReminderTile(
                                documentRef: _activeReminders[index],
                                popUpPrimaryMessage: 'Mark as complete',
                              );
                            },
                          ),
                        );
                      },
                    ),
              _expiredReminders.length == 0
                  ? Padding(
                      padding: EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Icon(CupertinoIcons.ellipses_bubble,
                                size: 50, color: appListTileGrey),
                          ),
                          Text('Oops there is no results',
                              style: errorTextStyle.copyWith(color: appListTileGrey)),
                        ],
                      ),
                    )
                  : FutureBuilder(
                      future: getExpiredRemindersSnapshot(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.none &&
                            snapshot.hasData == null) {
                          return SpinKitFadingCube(color: appGreen, size: 70);
                        }
                        return Padding(
                          padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                          child: ListView.builder(
                            itemCount: _expiredReminders.length,
                            itemBuilder: (context, index) {
                              return ReminderTile(
                                documentRef: _expiredReminders[index],
                                popUpPrimaryMessage: 'Mark as complete',
                              );
                            },
                          ),
                        );
                      },
                    ),
            ],
          )),
    );
  }

  getActiveRemindersSnapshot() async {
    final user = Provider.of<User>(context);
    var reminderRef = await Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders')
        .where('isExpired', isEqualTo: 'No')
        .orderBy('expiryDate')
        .getDocuments();

    if (this.mounted) {
      setState(() {
        _activeReminders = reminderRef.documents;
      });
    }
    return reminderRef.documents;
  }

  getExpiredRemindersSnapshot() async {
    final user = Provider.of<User>(context);
    var reminderRef = await Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders')
        .where('isExpired', isEqualTo: 'Yes')
        .orderBy('expiryDate')
        .getDocuments();

    if (this.mounted) {
      setState(() {
        _expiredReminders = reminderRef.documents;
      });
    }
    return reminderRef.documents;
  }
}
