import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/image_widget.dart';
import 'package:expiry_reminder/shared/loading.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  String imageToBeDeleted;
  int notiID;
  int newNotiID;

  bool hasTakenNewImage = false;
  bool loading = false;
  bool queueDeleteImage = false;

  final dateFormat = new DateFormat.yMMMMEEEEd();
  final remindDateFormat = new DateFormat.jms();
  String error = '';

  @override
  void initState() {
    _formKey = GlobalKey<FormState>();
    _nameController = TextEditingController(text: widget.docToEdit.data['reminderName']);
    _descriptionController = TextEditingController(text: widget.docToEdit.data['reminderDesc']);
    _barcodeController = TextEditingController(text: widget.docToEdit.data['productBarcode']);
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
    bool isKeebActive = MediaQuery.of(context).viewInsets.bottom != 0.0;

    return loading
        ? Loading()
        : Scaffold(
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
                      onPressed: () => showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Text('Are you sure you want to delete this reminder?'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context), child: Text('No')),
                                TextButton(
                                    onPressed: () {
                                      deleteReminder(widget.docToEdit, true)
                                          .whenComplete(() => Navigator.pop(context));
                                      Navigator.pop(context);
                                    },
                                    child: Text('Yes'))
                              ],
                            );
                          })),
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
                        InkWell(
                          onTap: imageUrl != null
                              ? () => showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return hasTakenNewImage
                                        ? AlertDialog(
                                            clipBehavior: Clip.antiAlias,
                                            contentPadding: EdgeInsets.all(0),
                                            content: Image.file(_image),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                            actions: [
                                              FlatButton(
                                                  splashColor: appGreen,
                                                  onPressed: () {},
                                                  child: Text('Remove',
                                                      style: TextStyle(color: appButtonBrown)),
                                                  minWidth: Get.width)
                                            ],
                                          )
                                        : AlertDialog(
                                            clipBehavior: Clip.antiAlias,
                                            contentPadding: EdgeInsets.all(0),
                                            content: Image.network(imageUrl),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20)),
                                            actions: [
                                              FlatButton(
                                                  splashColor: appGreen,
                                                  onPressed: () {
                                                    setState(() {
                                                      imageToBeDeleted = imageUrl;
                                                      imageUrl = null;
                                                      queueDeleteImage = true;
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
                                  image: hasTakenNewImage
                                      ? FileImage(_image)
                                      : imageUrl == null
                                          ? AssetImage('assets/image_placeholder.jpg')
                                          : NetworkImage(imageUrl),
                                )),
                            width: Get.width,
                            padding: EdgeInsets.only(bottom: 5),
                            height: 200,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 15.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                                onPressed: () async {
                                  var image = await ImageWidget.getImage();
                                  if (image != null) {
                                    setState(() {
                                      _image = File(image.path);
                                      hasTakenNewImage = true;
                                    });
                                  }
                                },
                                icon: Icon(CupertinoIcons.photo_camera, color: appButtonBrown),
                                label: Text('Take a photo of the product',
                                    style: TextStyle(color: appButtonBrown))),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
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
                                labelText: 'Product name (Required)',
                                suffixIcon: IconButton(
                                  icon: Icon(CupertinoIcons.clear),
                                  onPressed: () => _nameController.clear(),
                                )),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 20.0),
                          child: TextFormField(
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            controller: _barcodeController,
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Product Barcode (Optional)',
                                hintText: 'Enter product barcode here.',
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
                                labelText: 'Product Description (Optional)',
                                hintText: 'Enter product descripton here.',
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
                                child: Text(dateFormat.format(reminderTime) +
                                    ', ' +
                                    remindDateFormat.format(reminderTime)),
                              ),
                              InkWell(
                                child: Icon(CupertinoIcons.calendar),
                                onTap: () => _pickReminderTime(context),
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
                                  child: Text(dateFormat.format(expiryDate))),
                              InkWell(
                                child: Icon(CupertinoIcons.calendar),
                                onTap: () => _pickExpiryDate(context),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 60.0, left: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Expiry Status : ${(showDateDifference(expiryDate) <= 0) ? 'Expired' : 'Fresh'}',
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
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      setState(() => loading = true);
                      if (widget.docToEdit.data['reminderDate'].toDate() != reminderTime) {
                        setState(() {
                          newNotiID = getUniqueRandomNumber();
                          print('newNotiID after randomising is->>>>>> $newNotiID');
                          deleteSpecificScheduledReminder(notiID);
                          scheduleReminder(reminderTime, _nameController.text, newNotiID);
                        });
                      }
                      if (queueDeleteImage == true) {
                        ImageWidget.deleteImageFromStorage(imageToBeDeleted);
                      }
                      final String newImageUrl = hasTakenNewImage
                          ? await ImageWidget.uploadImageToFirebase(_image, true, imageUrl)
                          : imageUrl;
                      print("new newNotiID is->>>> $newNotiID");
                      widget.docToEdit.reference.updateData({
                        'notificationID': newNotiID,
                        'productImage': newImageUrl,
                        'productBarcode': _barcodeController.text,
                        'reminderName': _nameController.text,
                        'reminderDate': reminderTime.toLocal(),
                        'reminderDesc': _descriptionController.text,
                        'isExpired': (showDateDifference(expiryDate) <= 0) ? 'Yes' : 'No',
                        'expiryDate': expiryDate.toLocal()
                      }).whenComplete(() => Navigator.pop(context));
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
                  },
                  label: Text('Confirm changes')),
            ),
          );
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
