import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/reminder_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

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
    if (mounted) {
      setState(() {
        _resultsList = showResults;
      });
    }
  }

  getReminderSnapshot() async {
    final user = Provider.of<User>(context);
    var reminderRef = await Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders')
        .orderBy('expiryDate')
        .getDocuments();

    if (mounted) {
      setState(() {
        _allReminders = reminderRef.documents;
      });
    }
    searchResultsList();
    return reminderRef.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Stack(children: [
                Container(
                    padding: EdgeInsets.fromLTRB(20, 50, 20, 5),
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
                                    color: appBottomNavGreen.withOpacity(0.3))
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
                        ),
                        TextButton.icon(
                            style: ButtonStyle(
                                overlayColor: MaterialStateColor.resolveWith(
                                    (states) => appButtonBrown.withOpacity(0.5)),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15)))),
                            onPressed: barcodeScanner,
                            icon: Icon(
                              CupertinoIcons.qrcode_viewfinder,
                              color: appBgGrey,
                            ),
                            label: Text(
                              'Search by scanning barcode',
                              style: whiteTextStyle,
                            ))
                      ],
                    )),
                Positioned(
                  top: 43,
                  right: 10,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ),
              ]),
              Padding(
                padding: EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Search results',
                        style:
                            TextStyle(fontSize: 22, color: appBlack, fontWeight: FontWeight.bold),
                      ),
                      Text('${_resultsList.length} results',
                          style: whiteTextStyle.copyWith(
                              color: appBottomNavGreen, fontWeight: FontWeight.bold))
                    ]),
              ),
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
                  : Expanded(
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
        ));
  }

  Future barcodeScanner() async {
    var scannedCode =
        await FlutterBarcodeScanner.scanBarcode('#ca2b2b', 'Cancel', false, ScanMode.BARCODE);

    if (scannedCode == '-1') {
      print('User cancelled using the barcode reader.');
    } else {
      setState(() {
        _searchController.text = scannedCode;
      });
    }
  }
}
