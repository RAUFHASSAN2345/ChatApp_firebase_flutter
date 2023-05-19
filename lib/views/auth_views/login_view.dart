import 'dart:developer';
import 'dart:io';

import 'package:chat_app/api/api.dart';
import 'package:chat_app/helper/Dialogs.dart';
import 'package:chat_app/views/home_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool _icon_animated = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _icon_animated = true;
      });
    });
  }

  _handleloginbutton() {
    Dialogs.circularprogessbar(context);
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        log('\nuser : ${user.user}');
        log('\nuser additionalInfo : ${user.additionalUserInfo}');
        if ((await Api.userExist())) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomeView(),
              ));
        } else {
          await Api.createUser().then((value) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeView(),
                ));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await Api.inst.signInWithCredential(credential);
    } catch (e) {
      print('error : $e');
      Dialogs.snackbar(context, 'Something Went Wrong');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Welcome to We Chat',
        ),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * .15,
            left: _icon_animated ? mq.width * .15 : mq.width * .5,
            width: mq.width * .7,
            duration: Duration(seconds: 1),
            child: Image.asset(
              'assets/app_icon.png',
              fit: BoxFit.fill,
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            left: mq.width * .05,
            width: mq.width * .9,
            height: mq.height * .07,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  elevation: 1,
                  backgroundColor: Color.fromARGB(255, 142, 192, 143),
                  shape: StadiumBorder()),
              onPressed: () {
                _handleloginbutton();
              },
              icon: SizedBox(
                  height: 40,
                  child: Image.asset(
                    'assets/google_icon.png',
                    fit: BoxFit.fill,
                  )),
              label: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Colors.black, fontSize: mq.width * 0.04),
                      children: [
                    TextSpan(text: ' Login With '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.w600))
                  ])),
            ),
          ),
        ],
      ),
    );
  }
}
