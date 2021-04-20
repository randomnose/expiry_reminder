import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/shared_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EditReminder extends StatefulWidget {
  final dynamic docToEdit;

  const EditReminder({Key key, this.docToEdit}) : super(key: key);

  @override
  _EditReminderState createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  GlobalKey<FormState> _formKey;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _barcodeController = TextEditingController();
  DateTime reminderTime;
  DateTime expiryDate;

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
                onPressed: () {
                  widget.docToEdit.reference
                      .delete()
                      .whenComplete(() => Navigator.pop(context));
                },
              ),
            )),
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
                    // TODO: create an if statement to show snippet of user's image
                    // if no image, then show placeholder
                    Container(
                      padding: EdgeInsets.only(bottom: 5),
                      height: 200,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/image_placeholder.png'),
                            fit: BoxFit.cover),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                          onPressed: () {},
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
                          hintText: 'Product Barcode', labelText: 'Product Barcode'),
                    ),
                    SizedBox(height: 20),
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
                          hintText: 'Product Description (mark "-" if none)', labelText: 'Product Description'),
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
                            child: Text(dateFormat.format(expiryDate))),
                        InkWell(
                          child: Icon(CupertinoIcons.calendar),
                          onTap: () {
                            _pickExpiryDate(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Expired? : ${(showDateDifference(expiryDate) <= 0) ? 'Yes' : 'No'}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    ButtonTheme(
                      child: CupertinoButton.filled(
                          child: Text('Confirm your changes'),
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              widget.docToEdit.reference.updateData({
                                'productImage': '',
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
}
