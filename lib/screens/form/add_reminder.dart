import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/image_widget.dart';
import 'package:expiry_reminder/shared/loading.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

// TODO: allow user to add quantity for their entry of reminders.
class AddNewReminder extends StatefulWidget {
  @override
  _AddNewReminder createState() => _AddNewReminder();
}

class _AddNewReminder extends State<AddNewReminder> {
  File _image;
  final imagePicker = ImagePicker();
  bool loading = false;

  GlobalKey<FormState> _formKey;
  DateTime reminderTime = DateTime.now().toLocal();
  DateTime expiryDate = DateTime.now().toLocal();

  final dateFormat = new DateFormat.yMMMMEEEEd();
  final remindDateFormat = new DateFormat.jms();
  String error = '';
  bool hasPickedDate = false;
  bool hasPickedExpiry = false;
  bool hasTakenImage = false;

  TextEditingController _nameController;
  TextEditingController _descriptionController;
  TextEditingController _barcodeController;

  @override
  void initState() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _barcodeController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _barcodeController.dispose();
    _formKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isKeebActive = MediaQuery.of(context).viewInsets.bottom != 0.0;
    final user = Provider.of<User>(context);

    CollectionReference reminderCollection =
        Firestore.instance.collection('appUsers').document(user.uid).collection('reminders');

    return loading
        ? Loading()
        : Scaffold(
            appBar: CupertinoNavigationBar(
              actionsForegroundColor: Colors.black,
              backgroundColor: appGreen,
              middle: Text(
                'Add a Reminder',
                style: TextStyle(fontSize: 20),
              ),
            ),
            body: GestureDetector(
              onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  width: Get.width,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: hasTakenImage
                              ? () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      clipBehavior: Clip.antiAlias,
                                      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                                      content: Image.file(_image),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20)),
                                      actions: [
                                        FlatButton(
                                            height: 60,
                                            splashColor: appGreen,
                                            onPressed: () {
                                              setState(() {
                                                _image = null;
                                                hasTakenImage = false;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Text('Remove',
                                                style: TextStyle(color: appButtonBrown)),
                                            minWidth: Get.width)
                                      ],
                                    );
                                  })
                              : () {},
                          child: Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: appListTileGrey),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: _image == null
                                      ? AssetImage('assets/image_placeholder.jpg')
                                      : FileImage(_image),
                                )),
                            width: Get.width,
                            padding: EdgeInsets.only(bottom: 5),
                            height: 170,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                onPressed: () async {
                                  var tempImg = await ImageWidget.getImage();
                                  setState(() {
                                    _image = tempImg;
                                    hasTakenImage = true;
                                  });
                                },
                                icon: Icon(CupertinoIcons.photo_camera, color: appButtonBrown),
                                label: Text(
                                  'Take a photo of the product',
                                  style: TextStyle(color: appButtonBrown),
                                )),
                          ),
                        ),
                        TextFormField(
                          minLines: 1,
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                          controller: _nameController,
                          validator: (formVal) {
                            if (formVal == null || formVal.isEmpty) {
                              return 'Product name is needed';
                            } else {
                              return null;
                            }
                          },
                          decoration: textInputDecoration.copyWith(
                              hintText: 'Enter product name here.',
                              labelText: 'Product Name (Required)',
                              suffixIcon: IconButton(
                                icon: Icon(CupertinoIcons.clear),
                                onPressed: () => _nameController.clear(),
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 5.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                label: Text('Use the barcode scanner instead',
                                    style: TextStyle(color: appButtonBrown)),
                                icon: Icon(CupertinoIcons.qrcode_viewfinder, color: appButtonBrown),
                                onPressed: () => barcodeScan()),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            controller: _barcodeController,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Enter product barcode here.',
                                labelText: 'Product Barcode (Optional)',
                                suffixIcon: IconButton(
                                  icon: Icon(CupertinoIcons.clear),
                                  onPressed: () => _barcodeController.clear(),
                                )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            minLines: 1,
                            maxLines: 5,
                            controller: _descriptionController,
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Enter product descripton here.',
                                labelText: 'Product Description (Optional)',
                                suffixIcon: IconButton(
                                  icon: Icon(CupertinoIcons.clear),
                                  onPressed: () => _descriptionController.clear(),
                                )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Reminding you on: (Required)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Text(hasPickedDate
                                    ? dateFormat.format(reminderTime) +
                                        ', ' +
                                        remindDateFormat.format(reminderTime)
                                    : 'Please pick a reminder date.'),
                              ),
                              InkWell(
                                child: Icon(
                                  CupertinoIcons.calendar,
                                  color: appButtonBrown,
                                ),
                                onTap: () {
                                  _pickReminderTime(context);
                                  hasPickedDate = true;
                                },
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Expiry Date: (Required)',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                          child: Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Text(hasPickedExpiry
                                    ? dateFormat.format(expiryDate)
                                    : 'Expiry Date (Please pick)'),
                              ),
                              InkWell(
                                child: Icon(
                                  CupertinoIcons.calendar,
                                  color: appButtonBrown,
                                ),
                                onTap: () {
                                  _pickExpiryDate(context);
                                  hasPickedExpiry = true;
                                },
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 60.0, left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Expiry Status : ${(Utils.showDateDifference(expiryDate) <= 0 && hasPickedExpiry == true) ? 'Expired' : 'Fresh'}',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
            floatingActionButton: Visibility(
              visible: isKeebActive ? false : true,
              child: FloatingActionButton.extended(
                  splashColor: appButtonBrown.withAlpha(70),
                  backgroundColor: appButtonBrown,
                  label: Text('Create reminder', style: TextStyle(color: appBgGrey, fontSize: 16)),
                  onPressed: () async {
                    if (_formKey.currentState.validate() &&
                        hasPickedDate == true &&
                        hasPickedExpiry == true) {
                      setState(() => loading = true);
                      final int notiID = Utils.getUniqueRandomNumber();
                      Utils.scheduleReminder(reminderTime, _nameController.text, notiID);
                      final String imageUrl = _image != null
                          ? await ImageWidget.uploadImageToFirebase(_image, false)
                          : null;
                      reminderCollection
                          .add({
                            'notificationID': notiID,
                            'productImage': imageUrl,
                            'productBarcode': _barcodeController.text,
                            'reminderName': _nameController.text,
                            'reminderDate': reminderTime.toLocal(),
                            'reminderDesc': _descriptionController.text,
                            'isExpired':
                                (Utils.showDateDifference(expiryDate) <= 0 && hasPickedExpiry == true)
                                    ? 'Yes'
                                    : 'No',
                            'expiryDate': expiryDate.toLocal(),
                          })
                          .whenComplete(() => Navigator.pop(context))
                          .whenComplete(() => Utils.showToast('Reminder created.'));
                    } else {
                      setState(() => loading = false);
                      showDialog(
                          context: context,
                          builder: (BuildContext context) => CupertinoAlertDialog(
                                title: Text('Oops!'),
                                content: Text(
                                    'You may have missed out one or more fields required to create a reminder.'),
                                actions: [
                                  CupertinoDialogAction(
                                      child: Text('OK'), onPressed: () => Navigator.pop(context)),
                                ],
                              ));
                    }
                  }),
            ),
          );
  }

  Future barcodeScan() async {
    try {
      var barcodeValue =
          await FlutterBarcodeScanner.scanBarcode('#ca2b2b', 'Cancel', false, ScanMode.BARCODE);

      if (barcodeValue == '-1') {
        print('User cancelled using the barcode reader');
      } else {
        setState(() => _barcodeController.text = barcodeValue);
        print("==============================================================");
        print("Latest barcode controller text is ->" + _barcodeController.text);
        _getProductInfoFromAPI();
      }
      return barcodeValue;
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future _getProductInfoFromAPI() async {
    try {
      print('The barcode getting from _getProductInfoAPI is -> ' + _barcodeController.text);

      var result = await http.get(
          "https://api.upcdatabase.org/product/${_barcodeController.text}?apikey=4653186551EF1AA505DE0EC0CEB509C0");
      Map<String, dynamic> productData = new Map<String, dynamic>.from(json.decode(result.body));

      print(productData);
      productData['success'] == true
          ? _updateProductInfo(productData)
          : showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Alert'),
                    content: Text('No product could be found with that barcode.'),
                    actions: [
                      CupertinoDialogAction(
                        isDefaultAction: true,
                        child: Text('Confirm'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ));
    } catch (e) {
      print(e.toString());
    }
  }

  Future _updateProductInfo(dynamic productJson) async {
    setState(() {
      _nameController.text = productJson['title'];
      _descriptionController.text = productJson['description'] ?? _descriptionController.text;
    });

    print("Latest product name is ->>>" + _nameController.text);
    print("==============================================================");
  }

  void _pickReminderTime(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
              height: 500,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                        minimumDate: DateTime.now().add(Duration(minutes: 1)),
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: DateTime.now().add(Duration(minutes: 1)),
                        onDateTimeChanged: (changedDate) {
                          setState(() => reminderTime = changedDate);
                        }),
                  ),
                  CupertinoButton(
                      child: Text(
                        'Confirm',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context))
                ],
              ),
            ));
  }

  void _pickExpiryDate(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => Container(
              height: 500,
              color: Colors.white,
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: expiryDate,
                      onDateTimeChanged: (changedDate) {
                        setState(() => expiryDate = changedDate);
                      },
                    ),
                  ),
                  CupertinoButton(
                      child: Text(
                        'Confirm',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.pop(context))
                ],
              ),
            ));
  }
}
