import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/shared/constants.dart';
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
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

// TODO: allow user to add quantity for their entry of reminders.
class AddNewReminder extends StatefulWidget {
  @override
  _AddNewReminder createState() => _AddNewReminder();
}

class _AddNewReminder extends State<AddNewReminder> {
  File _image;
  final imagePicker = ImagePicker();

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
    final user = Provider.of<User>(context);

    CollectionReference reminderCollection = Firestore.instance
        .collection('appUsers')
        .document(user.uid)
        .collection('reminders');

    return Scaffold(
        appBar: CupertinoNavigationBar(
          actionsForegroundColor: Colors.black,
          backgroundColor: appGreen,
          middle: Text(
            'Add a Reminder',
            style: TextStyle(fontSize: 20),
          ),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(20),
              width: Get.width,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 5),
                      height: 200,
                      child: _image == null
                          ? Image(
                              image: AssetImage('assets/image_placeholder.png'))
                          : Image.file(_image, fit: BoxFit.fill),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                          onPressed: getImage,
                          icon: Icon(CupertinoIcons.photo_camera),
                          label: Text('Take a photo of the product')),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      validator: (formVal) {
                        if (formVal == null || formVal.isEmpty) {
                          return 'Product name is needed';
                        } else {
                          return null;
                        }
                      },
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Product Name', labelText: 'Product Name'),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _barcodeController,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Product Barcode',
                          labelText: 'Product Barcode'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        label: Text('Use the barcode scanner instead'),
                        icon: Icon(CupertinoIcons.qrcode_viewfinder),
                        onPressed: () {
                          barcodeScan(context);
                        },
                      ),
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      validator: (formVal) {
                        if (formVal == null || formVal.isEmpty) {
                          return 'Product description is needed';
                        } else {
                          return null;
                        }
                      },
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Product Description (mark "-" if none)',
                          labelText: 'Product Description'),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Reminding you on:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Row(
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
                          child: Icon(CupertinoIcons.calendar),
                          onTap: () {
                            _pickReminderTime(context);
                            hasPickedDate = true;
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Expiry Date:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(hasPickedExpiry
                              ? dateFormat.format(expiryDate)
                              : 'Expiry Date (Please pick)'),
                        ),
                        InkWell(
                          child: Icon(CupertinoIcons.calendar),
                          onTap: () {
                            _pickExpiryDate(context);
                            hasPickedExpiry = true;
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Expired? : ${(showDateDifference(expiryDate) <= 0 && hasPickedExpiry == true) ? 'Yes' : 'No'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    ButtonTheme(
                      child: CupertinoButton.filled(
                          child: Text('Create reminder'),
                          onPressed: () async {
                            if (_formKey.currentState.validate() &&
                                hasPickedDate == true &&
                                hasPickedExpiry == true) {
                              if (hasTakenImage == true) {
                                String fileName = basename(_image.path);
                                StorageReference firebaseStorageRef =
                                    FirebaseStorage.instance
                                        .ref()
                                        .child('images/$fileName');
                                StorageUploadTask uploadTask =
                                    firebaseStorageRef.putFile(_image);
                                StorageTaskSnapshot taskSnapshot =
                                    await uploadTask.onComplete;
                                final String imageUrl =
                                    await taskSnapshot.ref.getDownloadURL();
                                reminderCollection.add({
                                  'productImage': hasTakenImage ? imageUrl : '',
                                  'productBarcode':
                                      _barcodeController.text == null
                                          ? ''
                                          : _barcodeController.text.toString(),
                                  'reminderName': _nameController.text,
                                  'reminderDate': reminderTime.toLocal(),
                                  'reminderDesc': _descriptionController.text,
                                  'isExpired':
                                      (showDateDifference(expiryDate) <= 0 &&
                                              hasPickedExpiry == true)
                                          ? 'Yes'
                                          : 'No',
                                  'expiryDate': expiryDate.toLocal(),
                                }).whenComplete(() => Navigator.pop(context));
                              } else {
                                reminderCollection.add({
                                  'productImage': '',
                                  'productBarcode':
                                      _barcodeController.text == null
                                          ? ''
                                          : _barcodeController.text.toString(),
                                  'reminderName': _nameController.text,
                                  'reminderDate': reminderTime.toLocal(),
                                  'reminderDesc': _descriptionController.text,
                                  'isExpired':
                                      (showDateDifference(expiryDate) <= 0 &&
                                              hasPickedExpiry == true)
                                          ? 'Yes'
                                          : 'No',
                                  'expiryDate': expiryDate.toLocal(),
                                }).whenComplete(() => Navigator.pop(context));
                              }

                              print('all is good');
                            } else {
                              setState(() {
                                error =
                                    'Please check that you have entered all details.';
                              });
                              print('please check ur details');
                              print(_nameController.text);
                              print(reminderTime.toString());
                              print(_descriptionController.text);
                            }
                          }),
                    ),
                    SizedBox(height: 10),
                    Text(
                      error,
                      style: errorTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Future barcodeScan(BuildContext context) async {
    try {
      var barcodeValue = await FlutterBarcodeScanner.scanBarcode(
          '#ca2b2b', 'Cancel', false, ScanMode.BARCODE);

      // use upcdatabase.org to find the product info
      // EXAMPLE: https://api.upcdatabase.org/product/8000380004881?apikey=4653186551EF1AA505DE0EC0CEB509C0

      if (barcodeValue == '-1') {
        print('User cancelled using the barcode reader');
      } else {
        setState(() {
          _barcodeController.text = barcodeValue;
        });
        print("==============================================================");
        print("Latest barcode controller text is ->" + _barcodeController.text);
        _getProductInfoFromAPI(context);
      }
      return barcodeValue;
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  Future _getProductInfoFromAPI(BuildContext context) async {
    try {
      print('The barcode getting from _getProductInfoAPI is -> ' +
          _barcodeController.text);

      var result = await http.get(
          "https://api.upcdatabase.org/product/${_barcodeController.text}?apikey=4653186551EF1AA505DE0EC0CEB509C0");
      Map<String, dynamic> productData =
          new Map<String, dynamic>.from(json.decode(result.body));

      print(productData);
      productData['success'] == true
          ? _updateProductInfo(productData)
          : showDialog(
              context: context,
              builder: (BuildContext context) => CupertinoAlertDialog(
                    title: Text('Alert'),
                    content:
                        Text('No product could be found with that barcode.'),
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
    // might not need this delay anymore
    // await new Future.delayed(const Duration(seconds: 3));
    setState(() {
      _nameController.text = productJson['title'];
      _descriptionController.text =
          productJson['description'] ?? _descriptionController.text;
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
                      mode: CupertinoDatePickerMode.dateAndTime,
                      initialDateTime: reminderTime,
                      onDateTimeChanged: (changedDate) {
                        setState(() {
                          reminderTime = changedDate;
                        });
                      },
                    ),
                  ),
                  CupertinoButton(
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
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
                        setState(() {
                          expiryDate = changedDate;
                        });
                      },
                    ),
                  ),
                  CupertinoButton(
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ));
  }

  Future getImage() async {
    final image = await imagePicker.getImage(source: ImageSource.camera);
    setState(() {
      _image = File(image.path);
      hasTakenImage = true;
    });
  }

  // Future uploadImageToFirebase(BuildContext context,
  //     CollectionReference reminderCollection, String uid) async {
  //   String fileName = basename(_image.path);
  //   StorageReference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child('images/$fileName');
  //   StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   taskSnapshot.ref.getDownloadURL().then((value) {
  //     print("Link retrieval done: $value");
  //     reminderCollection.add({'productImage': value});
  //     return value;
  //   });
  // }
}
