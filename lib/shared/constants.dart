import 'package:flutter/material.dart';

const textInputDecoration = InputDecoration(
  fillColor: Colors.white,
  filled: true,
  contentPadding: EdgeInsets.all(12.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 2.0),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.green, width: 2.0),
  ),
);

const eRNormalText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.normal,
  color: Colors.black
);

const eRWarningText = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.bold,
  color: Colors.red
);