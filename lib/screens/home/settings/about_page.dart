import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final String profilePicture =
      'https://firebasestorage.googleapis.com/v0/b/eson-s-expiry-reminder.appspot.com/o/profile_pic.jpg?alt=media&token=32cd72ca-0888-46b0-a1bd-91233858cc5d';
  final String overviewDesc =
      'This is an expiry reminder app that aims to help reduce the number of food waste by reminding people to consume their food before they expire. Although this app is aimed towards iOS mobile phone users, the app is built to support both iOS and Android devices using Flutter SDK. This is a project for my Capstone Project at Sunway University. \n\nSupervisor: Muthukumaran Maruthappa';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: appGreen,
        appBar: AppBar(
          title: Text('About'),
          backgroundColor: appBgGrey,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [appBgGrey, appGreen],
                stops: [0.0, 0.9],
                begin: FractionalOffset(0.0, 0.0),
                end: FractionalOffset(0.0, 1.0),
              ),
            ),
            child: Flex(direction: Axis.horizontal, children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(height: 90),
                    Stack(
                        overflow: Overflow.visible,
                        alignment: AlignmentDirectional.topCenter,
                        children: [
                          Positioned(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 30),
                              width: Get.width * 0.85,
                              decoration: cardDecoration.copyWith(
                                  borderRadius: BorderRadius.circular(15),
                                  color: appBgGrey.withOpacity(0.5)),
                              padding: EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  SizedBox(height: 50),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Text('Owner & Creator:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold, color: appBlack)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5.0),
                                    child: Text('TAN ESON',
                                        style: errorTextStyle
                                            .copyWith(fontSize: 23, color: appBlack, shadows: [
                                          Shadow(
                                              offset: Offset(2.0, 2.0),
                                              blurRadius: 3.0,
                                              color: appGreen),
                                        ])),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 15.0),
                                    child: Text('17071143',
                                        style: TextStyle(fontSize: 16, color: appBlack, shadows: [
                                          Shadow(
                                              offset: Offset(2.0, 2.0),
                                              blurRadius: 4.0,
                                              color: appGreen),
                                        ])),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        InkWell(
                                          onTap: _launchLinkedIn,
                                          child: Text(
                                            'LinkedIn',
                                            style: TextStyle(decoration: TextDecoration.underline),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: _launchGmail,
                                          child: Text(
                                            'E-mail',
                                            style: TextStyle(decoration: TextDecoration.underline),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: -70,
                            child: CircleAvatar(
                              backgroundColor: appBgGrey,
                              radius: 60,
                              backgroundImage: NetworkImage(profilePicture),
                            ),
                          )
                        ]),
                    Container(
                      width: Get.width * 0.85,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OVERVIEW',
                            style: TextStyle(
                                color: appBgGrey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                                shadows: [
                                  Shadow(
                                      offset: Offset(5.0, 5.0), blurRadius: 3.0, color: appGreen),
                                ]),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(8, 8, 8, 30),
                            child: Text(
                              overviewDesc,
                              style: TextStyle(
                                  color: appBlack,
                                  fontSize: 16,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(2.0, 2.0), blurRadius: 5.0, color: appGreen),
                                  ],
                                  height: 1.8),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ));
  }

  _launchLinkedIn() async {
    final String profileUrl = 'http://www.linkedin.com/in/eson-tan';
    if (await canLaunch(profileUrl)) {
      await launch(profileUrl);
    } else {
      throw ('Could not launch LinkedIn profile $profileUrl');
    }
  }

  _launchGmail() async {
    final Uri _emailLauchUri = Uri(
        scheme: 'mailto',
        path: 'tanesonjpg@gmail.com',
        queryParameters: {'subject': 'Expiry Reminder - App Feedback'});

    String _emailToString = _emailLauchUri.toString().replaceAll('+', '%20');
    print(_emailToString);
    // if (await canLaunch(_emailToString)) {
    //   await launch(_emailToString).catchError((onError) => throw (onError));
    // } else {
    //   throw ('Can\'t launch email.... $_emailToString');
    // }

    await launch(_emailToString).catchError((onError) => throw (onError));
  }
}
