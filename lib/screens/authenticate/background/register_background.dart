import 'package:expiry_reminder/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterBg extends StatelessWidget {
  final Widget child;

  const RegisterBg({Key key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = Get.size;
    return Scaffold(
      backgroundColor: appBgGrey,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(new FocusNode()),
        child: SingleChildScrollView(
          child: Container(
            height: size.height,
            width: size.width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: -20,
                  left: -130,
                  child: Image.asset(
                    'assets/login/irregular_shape.png',
                    color: appBottomNavGreen,
                  ),
                ),
                Positioned(
                  top: 100,
                  child: Image.asset('assets/logo_no_name.png'),
                ),
                Transform.rotate(
                  origin: Offset(-30, 100),
                  angle: 90,
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    'assets/login/irregular_shape.png',
                    color: appBottomNavGreen,
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: -100,
                  child: Image.asset(
                    'assets/login/irregular_shape.png',
                    color: appBottomNavGreen,
                  ),
                ),
                Positioned(
                  bottom: 50,
                  right: 30,
                  child: Image.asset(
                    'assets/login/login_bottom_left_circle.png',
                    scale: 5,
                    color: appBottomNavGreen,
                  ),
                ),
                Positioned(
                  bottom: 150,
                  right: 90,
                  child: Image.asset(
                    'assets/login/login_bottom_left_circle.png',
                    scale: 20,
                    color: appBottomNavGreen,
                  ),
                ),
                child
              ],
            ),
          ),
        ),
      ),
    );
  }
}
