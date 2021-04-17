import 'package:flutter/material.dart';

InputDecoration textInputDecoration = InputDecoration(
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.red)),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(color: Colors.black)),
  alignLabelWithHint: true,
);

const eRNormalText =
    TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black);

const eRWarningText =
    TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red);

const appGreen = Color(0xff93A280);
const appRed = Color(0xffD88C8C);
const appBgGrey = Color(0xffFAFAF8);
const appButtonBrown = Color(0xff725A48);
const appListTileGrey = Color(0xffAFAFAF);
const appBottomNavGreen = Color(0xff6E6E61);
