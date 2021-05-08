import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  List _allReminders = [];
  List _resultsList = [];
  Future resultsLoaded;

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _allReminders = [];
    _resultsList = [];
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    resultsLoaded = getReminderSnapshot();
  }

  _onSearchChanged() {
    searchResultsList();
    print(_searchController.text);
  }

  searchResultsList() {
    var showResults = [];

    if (_searchController.text != "") {
      for (var reminder in _allReminders) {
        var name = reminder['reminderName'].toLowerCase();
        var description = reminder['reminderDesc'];
        var barcode = reminder['productBarcode'];
        if (name.contains(_searchController.text.trim().toLowerCase())) {
          showResults.add(reminder);
        } else if (description.contains(_searchController.text.trim().toLowerCase())) {
          showResults.add(reminder);
        } else if (barcode.contains(_searchController.text.trim().toLowerCase())) {
          showResults.add(reminder);
        }
      }
    } else {
      showResults = [];
    }
    setState(() {
      _resultsList = showResults;
    });
  }

  getReminderSnapshot() async {
    final user = Provider.of<User>(context);
    var reminderRef = await Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders')
        .orderBy('expiryDate')
        .getDocuments();

    setState(() {
      _allReminders = reminderRef.documents;
    });
    searchResultsList();
    return reminderRef.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 25),
                    decoration: BoxDecoration(
                        color: appGreen,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25), bottomRight: Radius.circular(25))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: RichText(
                              text: TextSpan(
                                  text: 'Search\n',
                                  style: TextStyle(
                                      fontSize: 30, fontWeight: FontWeight.bold, color: appBgGrey),
                                  children: [
                                TextSpan(text: 'for ', style: TextStyle(fontSize: 24)),
                                TextSpan(
                                    text: 'reminders',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, color: appBlack, fontSize: 24))
                              ])),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 60,
                          decoration: BoxDecoration(
                              color: appBgGrey,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 10),
                                    blurRadius: 50,
                                    color: appButtonBrown.withOpacity(0.4))
                              ]),
                          child: TextField(
                            textAlignVertical: TextAlignVertical.center,
                            textAlign: TextAlign.start,
                            controller: _searchController,
                            cursorColor: appButtonBrown,
                            style: TextStyle(
                                fontSize: 18,
                                color: appBottomNavGreen,
                                fontWeight: FontWeight.w400),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search, color: appGreen, size: 30),
                              suffixIcon: _searchController.text != ''
                                  ? IconButton(
                                      icon: Icon(CupertinoIcons.xmark_circle),
                                      onPressed: () => _searchController.clear())
                                  : null,
                              hintText: 'Search',
                              hintStyle: TextStyle(color: appGreen),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        )
                      ],
                    )),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                    child: Text(
                      'Search results',
                      style: TextStyle(fontSize: 24, color: appBlack, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Text('${_resultsList.length} results',
                          style: whiteTextStyle.copyWith(
                              color: appBottomNavGreen, fontWeight: FontWeight.bold)))
                ]),
                _resultsList.length == 0
                    ? Padding(
                        padding: EdgeInsets.only(top: 60.0),
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
                    :
                    // list view for search result
                    // Expanded(
                    //     child: ListView.builder(
                    //       shrinkWrap: true,
                    //       padding: EdgeInsets.symmetric(horizontal: 20),
                    //       itemCount: _resultsList.length,
                    //       itemBuilder: (BuildContext context, int index) {
                    //         print(
                    //             'The current item in result is -> ${_resultsList[index].data['reminderName']}');
                    //         return ReminderTile(
                    //             documentRef: _resultsList[index],
                    //             popUpPrimaryMessage: 'Mark as complete');
                    //       },
                    //     ),
                    //   )
                    Expanded(
                        child: FutureBuilder(
                          future: getReminderSnapshot(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.none &&
                                snapshot.hasData == null) {
                              return SpinKitFadingCube(color: appGreen, size: 70);
                            }
                            return Padding(
                              padding: EdgeInsets.fromLTRB(20, 15, 20, 20),
                              child: ListView.builder(
                                shrinkWrap: true,
                                padding: EdgeInsets.all(0),
                                itemCount: _resultsList.length,
                                itemBuilder: (context, index) {
                                  return ReminderTile(
                                    documentRef: _resultsList[index],
                                    popUpPrimaryMessage: 'Mark as complete',
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      )
              ],
            ),
            Positioned(
              top: 43,
              right: 10,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
              ),
            ),
          ]),
        ));
  }
}
