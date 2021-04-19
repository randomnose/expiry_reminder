import 'package:flutter/material.dart';

InputDecoration textInputDecoration = InputDecoration(
  border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.black)),
  // enabledBorder: OutlineInputBorder(
  //     borderRadius: BorderRadius.circular(20),
  //     borderSide: BorderSide(color: Colors.black)),
  labelStyle: TextStyle(color: Colors.black),
  floatingLabelBehavior: FloatingLabelBehavior.always,
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: Colors.white)),
  alignLabelWithHint: true,
);

// TextStyle eRNormalText =
//     TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: Colors.black);

// TextStyle eRWarningText =
//     TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red);

TextStyle whiteTextStyle = TextStyle(fontSize: 16, color: appBgGrey);
TextStyle greenTextStyle = TextStyle(fontSize: 16, color: appBottomNavGreen);
TextStyle errorTextStyle = TextStyle(
    fontSize: 18, color: Colors.red[400], fontWeight: FontWeight.w300);

Color appGreen = Color(0xff93A280);
Color appRed = Color(0xffD88C8C);
Color appBgGrey = Color(0xffFAFAF8);
Color appButtonBrown = Color(0xff725A48);
Color appListTileGrey = Color(0xffAFAFAF);
Color appBottomNavGreen = Color(0xff6E6E61);
Color appLoadingBgGreen = Color(0xffa3a38c);
Color appSignInBgGreen = Color(0xffa9b39b);
