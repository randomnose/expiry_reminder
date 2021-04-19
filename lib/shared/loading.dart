import 'dart:math';

import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  List<String> loadingQuotes = [
    'Always remember to finish you food.',
    'Don\'t forget to enjoy your food!',
    'Never waste your food.',
    'Remember to check your expiry date!',
    'Buy it with thought.',
    'Buy only what you need.',
    'Buy only what you can finish.',
    'Food always tastes better when it\'s fresh.'
  ];

  final _randomiser = new Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appSignInBgGreen,
      body: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpinKitFadingCube(color: appBottomNavGreen, size: 70),
              SizedBox(height: 40),
              Text(loadingQuotes[_randomiser.nextInt(loadingQuotes.length)])
            ],
          ),
        ),
      ),
    );
  }
}
