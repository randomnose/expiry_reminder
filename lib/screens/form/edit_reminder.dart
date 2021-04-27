import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditReminder extends StatefulWidget {
  final dynamic docToEdit;

  const EditReminder({Key key, this.docToEdit}) : super(key: key);

  @override
  _EditReminderState createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  File _image;
  final imagePicker = ImagePicker();
  GlobalKey<FormState> _formKey;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _barcodeController = TextEditingController();
  DateTime reminderTime;
  DateTime expiryDate;
  String imageUrl;
  int notiID;
  int newNotiID;

  bool hasTakenNewImage = false;

  final dateFormat = new DateFormat.yMMMMEEEEd();
  final remindDateFormat = new DateFormat.jms();
  String error = '';

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _nameController =
        TextEditingController(text: widget.docToEdit.data['reminderName']);
    _descriptionController =
        TextEditingController(text: widget.docToEdit.data['reminderDesc']);
    _barcodeController =
        TextEditingController(text: widget.docToEdit.data['productBarcode']);
    reminderTime = widget.docToEdit.data['reminderDate'].toDate();
    expiryDate = widget.docToEdit.data['expiryDate'].toDate();
    imageUrl = widget.docToEdit.data['productImage'];
    notiID = widget.docToEdit.data['notificationID'];
    newNotiID = notiID;
    super.initState();
  }

  @override
  void dispose() {
    _formKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CupertinoNavigationBar(
            actionsForegroundColor: Colors.black,
            backgroundColor: appGreen,
            middle: Text(
              'Edit a Reminder',
              style: TextStyle(fontSize: 20),
            ),
            trailing: Material(
              color: appGreen,
              child: IconButton(
                  icon: Icon(CupertinoIcons.trash),
                  onPressed: () => deleteReminder(widget.docToEdit, true)
                      .whenComplete(() => Navigator.pop(context))),
            )),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
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
                      width: Get.width,
                      padding: EdgeInsets.only(bottom: 5),
                      height: 200,
                      child: hasTakenNewImage
                          ? Image.file(_image)
                          : imageUrl == ''
                              ? Image(
                                  image: AssetImage(
                                      'assets/image_placeholder.jpg'),
                                  fit: BoxFit.cover)
                              : Image.network(imageUrl),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                            onPressed: getImage,
                            icon: Icon(CupertinoIcons.photo_camera,
                                color: appButtonBrown),
                            label: Text('Take a photo of the product',
                                style: TextStyle(color: appButtonBrown))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (formVal) {
                          if (formVal == null || formVal.isEmpty) {
                            return 'Product name is needed';
                          } else {
                            return null;
                          }
                        },
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Product Name',
                            labelText: 'Product Name'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: _barcodeController,
                        decoration: textInputDecoration.copyWith(
                            hintText: 'Product Barcode',
                            labelText: 'Product Barcode'),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 15.0),
                      child: TextFormField(
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
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Reminding you on:',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text(dateFormat.format(reminderTime) +
                                ', ' +
                                remindDateFormat.format(reminderTime)),
                          ),
                          InkWell(
                            child: Icon(CupertinoIcons.calendar),
                            onTap: () {
                              _pickReminderTime(context);
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Expiry Date:',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                      child: Row(
                        children: [
                          Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(dateFormat.format(expiryDate))),
                          InkWell(
                            child: Icon(CupertinoIcons.calendar),
                            onTap: () {
                              _pickExpiryDate(context);
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 10.0, left: 10.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Expired? : ${(showDateDifference(expiryDate) <= 0) ? 'Yes' : 'No'}',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    ButtonTheme(
                      minWidth: Get.width * 0.6,
                      buttonColor: appButtonBrown,
                      height: 50,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20)),
                          child: Text('Confirm changes',
                              style: TextStyle(color: appBgGrey, fontSize: 16)),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              if (widget.docToEdit.data['reminderDate']
                                      .toDate() !=
                                  reminderTime) {
                                setState(() {
                                  newNotiID = getUniqueRandomNumber();
                                  print(
                                      'newNotiID after randomising is->>>>>> $newNotiID');
                                  deleteSpecificScheduledReminder(notiID);
                                  scheduleReminder(reminderTime,
                                      _nameController.text, newNotiID);
                                });
                              }
                              if (hasTakenNewImage == true) {
                                String fileName = basename(_image.path);
                                StorageReference firebaseStorageRef =
                                    FirebaseStorage.instance
                                        .ref()
                                        .child('images/$fileName');
                                StorageUploadTask uploadTask =
                                    firebaseStorageRef.putFile(_image);
                                StorageTaskSnapshot taskSnapshot =
                                    await uploadTask.onComplete;
                                final String newImageUrl =
                                    await taskSnapshot.ref.getDownloadURL();
                                print("new newNotiID is->>>> $newNotiID");
                                widget.docToEdit.reference.updateData({
                                  'notificationID': newNotiID,
                                  'productImage': newImageUrl,
                                  'productBarcode':
                                      _barcodeController.text == null
                                          ? ''
                                          : _barcodeController.text.toString(),
                                  'reminderName': _nameController.text,
                                  'reminderDate': reminderTime.toLocal(),
                                  'reminderDesc': _descriptionController.text,
                                  'isExpired':
                                      (showDateDifference(expiryDate) <= 0)
                                          ? 'Yes'
                                          : 'No',
                                  'expiryDate': expiryDate.toLocal()
                                }).whenComplete(() => Navigator.pop(context));
                              } else {
                                print("new newNotiID is->>>> $newNotiID");
                                widget.docToEdit.reference.updateData({
                                  'notificationID': newNotiID,
                                  'productImage': imageUrl,
                                  'productBarcode':
                                      _barcodeController.text == null
                                          ? ''
                                          : _barcodeController.text.toString(),
                                  'reminderName': _nameController.text,
                                  'reminderDate': reminderTime.toLocal(),
                                  'reminderDesc': _descriptionController.text,
                                  'isExpired':
                                      (showDateDifference(expiryDate) <= 0)
                                          ? 'Yes'
                                          : 'No',
                                  'expiryDate': expiryDate.toLocal()
                                }).whenComplete(() => Navigator.pop(context));
                              }
                            } else {
                              setState(() {
                                error =
                                    'Please check that you have entered all details.';
                              });
                              print('Edit page - please check ur details.');
                            }
                          }),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        error,
                        style: errorTextStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
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
      hasTakenNewImage = true;
    });
  }

  // uploadImageToFirebase() async {
  //   String fileName = basename(_image.path);
  //   StorageReference firebaseStorageRef =
  //       FirebaseStorage.instance.ref().child('images/$fileName');
  //   StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
  //   StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
  //   final String newImageUrl = await taskSnapshot.ref.getDownloadURL();

  //   return newImageUrl;
  // }
}
