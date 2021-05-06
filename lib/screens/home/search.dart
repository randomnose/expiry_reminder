import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

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
        }
        if (description.contains(_searchController.text.trim().toLowerCase())) {
          showResults.add(reminder);
        }
        if (barcode.contains(_searchController.text.trim().toLowerCase())) {
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
        appBar: CupertinoNavigationBar(
            actionsForegroundColor: Colors.black,
            backgroundColor: appGreen,
            middle: Text('Search')),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Container(
            height: Get.height,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(20),
                  child: TextField(
                    onTap: () {},
                    controller: _searchController,
                    decoration: textInputDecoration.copyWith(
                        prefixIcon: Icon(Icons.search), hintText: 'Search'),
                  ),
                ),
                _resultsList.length == 0
                    ? Center(
                        heightFactor: 4,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 10.0),
                              child:
                                  Icon(CupertinoIcons.wand_rays, size: 50, color: appListTileGrey),
                            ),
                            Text('Oops there is no results',
                                style: errorTextStyle.copyWith(color: appListTileGrey)),
                          ],
                        ),
                      )
                    :
                    // list view for search result
                    Expanded(
                        child: ListView.builder(
                          itemCount: _resultsList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return ReminderTile(
                                documentRef: _resultsList[index],
                                popUpPrimaryMessage: 'Mark as complete');
                          },
                        ),
                      )
              ],
            ),
          ),
        ));
  }
}
