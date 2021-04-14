import 'package:expiry_reminder/screens/home/home.dart';
import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        appBar: AppBar(
          title: Text('Edit a reminder'),
          centerTitle: true,
          actions: [
            Padding(
                padding: EdgeInsets.only(right: 15),
                child: InkWell(
                    onTap: () {
                      widget.docToEdit.reference
                          .delete()
                          .whenComplete(() => Navigator.pop(context));
                    },
                    child: Icon(CupertinoIcons.delete)))
          ],
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
                          hintText: 'Product Name'),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      keyboardType: TextInputType.number,
                      controller: _barcodeController,
                      decoration: textInputDecoration.copyWith(
                          hintText: 'Product Barcode'),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        label: Text('Use the barcode scanner instead'),
                        icon: Icon(CupertinoIcons.qrcode_viewfinder),
                        onPressed: () {},
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
                          hintText: 'Product Description (mark "-" if none)'),
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
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(reminderTime.toString()),
                        ),
                        InkWell(
                          child: Icon(CupertinoIcons.calendar),
                          onTap: () {
                            _showCupertinoDatePicker(context);
                          },
                        )
                      ],
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Expired? : ${(showDateDifference(reminderTime) <= -1) ? 'Yes' : 'No'}',
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
                                'reminderDate': reminderTime,
                                'reminderDesc': _descriptionController.text,
                                'expiryStatus':
                                    (showDateDifference(reminderTime) <= -1)
                                        ? 'Yes'
                                        : 'No'
                              }).whenComplete(() => Navigator.pop(context));
                              print('all is good');
                            } else {
                              print('please check ur details');
                              print(_nameController.text);
                              print(reminderTime.toString());
                              print(_descriptionController.text);
                            }
                          }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  // // a future function that will open up the date picker
  // Future _showDatePicker(BuildContext context) async {
  //   final DateTime datePicked = await showDatePicker(
  //       context: context,
  //       initialDate: reminderTime,
  //       firstDate: DateTime(2021),
  //       lastDate: DateTime(2025));

  //   if (datePicked != null && datePicked != DateTime.now()) {
  //     setState(() {
  //       reminderTime = datePicked;
  //     });
  //   }
  // }

  int showDateDifference(DateTime date) {
    return DateTime(reminderTime.year, reminderTime.month, reminderTime.day)
        .difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
  }

  void _showCupertinoDatePicker(BuildContext context) {
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
}
