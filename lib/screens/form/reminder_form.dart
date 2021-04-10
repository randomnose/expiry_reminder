import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddNewReminder extends StatefulWidget {
  @override
  _AddNewReminder createState() => _AddNewReminder();
}

class _AddNewReminder extends State<AddNewReminder> {
  GlobalKey<FormState> _formKey;
  String productName = '';
  DateTime reminderTime = DateTime.now();
  String description = '';

  String error = '';
  bool hasPickedDate = false;

  TextEditingController _nameController;
  TextEditingController _descriptionController;


  @override
  void initState() {
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _formKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Create a reminder'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            width: Get.width,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  RaisedButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text('Snap a picture of the product'),
                        SizedBox(width: 20),
                        Icon(Icons.camera)
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    validator: (formVal) => formVal.length == 0
                        ? 'Please enter your product name'
                        : '',
                    decoration:
                        textInputDecoration.copyWith(hintText: 'Product Name'),
                    onChanged: (value) {
                      setState(() {
                        productName = value;
                      });
                    },
                  ),
                  TextButton.icon(
                    label: Text('Use the barcode scanner instead   '),
                    icon: Icon(Icons.add_a_photo_rounded),
                    onPressed: () {},
                  ),
                  SizedBox(height: 20),
                  Text('Reminding you on:',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(hasPickedDate
                            ? reminderTime.toString()
                            : 'Please pick a reminder date.'),
                      ),
                      InkWell(
                        child: Icon(Icons.calendar_today_outlined),
                        onTap: () {
                          _showDatePicker(context);
                          hasPickedDate = true;
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    validator: (formVal) => formVal.length == 0
                        ? 'Please enter your product description'
                        : '',
                    decoration: textInputDecoration.copyWith(
                        hintText: 'Product Description'),
                    onChanged: (value) {
                      setState(() {
                        description = value;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ButtonTheme(
                    minWidth: Get.width,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: RaisedButton(
                      color: Colors.green,
                      child: Text('Create reminder'),
                      onPressed: () {
                        if (_formKey.currentState.validate() &&
                            reminderTime != null) {
                          print('all is good!!!!');
                        } else {
                          print('please check ur details');
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }

  // a future function that will open up the date picker
  Future _showDatePicker(BuildContext context) async {
    final DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: reminderTime,
        firstDate: DateTime(2021),
        lastDate: DateTime(2025));

    if (datePicked != null && datePicked != DateTime.now()) {
      setState(() {
        reminderTime = datePicked;
      });
    }
  }
}
