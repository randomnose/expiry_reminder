import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({Key key, this.toggleView}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  GlobalKey<FormState> _formKey;
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  TextEditingController _emailController;
  TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _formKey = GlobalKey<FormState>();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _formKey = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: appSignInBgGreen,
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Image.asset('assets/logo_no_name.png'),
                        //   Text('ER',
                        //       style: TextStyle(
                        //           fontSize: 100,
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.bold)),
                      ),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: _emailController,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Email Address',
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined)),
                              validator: (formVal) =>
                                  formVal.isEmpty ? 'Enter an email' : null,
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    new RegExp(r"\s\b|\b\s"))
                              ],
                            ),
                            SizedBox(height: 20.0),
                            // TODO: add prefix icon
                            TextFormField(
                              controller: _passwordController,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Password',
                                  labelText: 'Password',
                                  prefixIcon: Icon(CupertinoIcons.lock)),
                              validator: (formVal) => formVal.length < 6
                                  ? 'Enter a password longer than 6 characters'
                                  : null,
                              obscureText: true,
                              onChanged: (val) {
                                setState(() => password = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            ButtonTheme(
                              minWidth: Get.width * 0.6,
                              height: 40,
                              child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20)),
                                color: appButtonBrown,
                                child: Text('LOGIN', style: whiteTextStyle),
                                onPressed: () async {
                                  if (_formKey.currentState.validate()) {
                                    setState(() {
                                      loading = true;
                                    });
                                    dynamic result =
                                        await _auth.signInWithEmailAndPassword(
                                            email: _emailController.text,
                                            password: _passwordController.text);
                                    if (result == null) {
                                      setState(() {
                                        error =
                                            'Error: \n Could not sign in with those credentials!';
                                        loading = false;
                                      });
                                    }
                                  }
                                  print(email);
                                  print(password);
                                },
                              ),
                            ),
                            SizedBox(height: 15),
                            Divider(
                                height: 10,
                                color: CupertinoColors.separator,
                                thickness: 0.7),
                            TextButton(
                                child: Text(
                                  'REGISTER NOW',
                                  style: whiteTextStyle,
                                ),
                                onPressed: () {
                                  widget.toggleView();
                                }),
                            SizedBox(height: 20),
                            Text(
                              error,
                              style: errorTextStyle,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
