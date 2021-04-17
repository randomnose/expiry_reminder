import 'package:expiry_reminder/shared/constants.dart';
import 'package:expiry_reminder/shared/loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expiry_reminder/services/auth.dart';
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
            backgroundColor: appGreen,
            // TODO: change ui to suggested look
            // appBar: AppBar(
            //   backgroundColor: appGreen,
            //   title: Text('Expiry Reminder - Sign In now'),
            //   // actions: <Widget>[
            //   //   FlatButton.icon(
            //   //     icon: Icon(Icons.app_registration),
            //   //     label: Text('Register Now'),
            //   //     onPressed: () => widget.toggleView(),
            //   //   ),
            //   // ],
            // ),
            body: GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 100),
                        // TODO: put logo here
                        child: Text('ER',
                            style: TextStyle(
                                fontSize: 100,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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
                                  labelText: 'Email'),
                              validator: (formVal) =>
                                  formVal.isEmpty ? 'Enter an email' : null,
                              onChanged: (val) {
                                setState(() => email = val);
                              },
                            ),
                            SizedBox(height: 20.0),
                            TextFormField(
                              controller: _passwordController,
                              decoration: textInputDecoration.copyWith(
                                  hintText: 'Password', labelText: 'Password'),
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
                                shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(20)),
                                color: appButtonBrown,
                                child: Text(
                                  'LOGIN',
                                  style:
                                      TextStyle(color: appBgGrey, fontSize: 16),
                                ),
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
                                            'Could not sign in with those credentials!';
                                        loading = false;
                                      });
                                    }
                                  }
                                  print(email);
                                  print(password);
                                },
                              ),
                            ),
                            TextButton(
                                child: Text(
                                  'REGISTER NOW',
                                  style: TextStyle(
                                      color: appBgGrey, fontSize: 16),
                                ),
                                onPressed: () {
                                  widget.toggleView();
                                }),
                            SizedBox(height: 20),
                            Text(
                              error,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: CupertinoColors.activeOrange,
                                  fontWeight: FontWeight.bold),
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
