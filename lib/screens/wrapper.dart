import 'package:expiry_reminder/models/user.dart';
import 'package:expiry_reminder/screens/home/index.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'authenticate/authenticate.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser>(context);
    print('Current user is:');
    print(user);

    // return either the Home or Authenticate widget
    // if user not signed in, show Authenticate, otherwise, Home.
    if (user == null) {
      return Authenticate();
    } else {
      return IndexPage();
    }
  }
}
