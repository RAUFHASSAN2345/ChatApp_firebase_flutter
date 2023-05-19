import 'dart:developer';

import 'package:chat_app/api/api.dart';
import 'package:chat_app/views/auth_views/login_view.dart';
import 'package:chat_app/views/home_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
      if (Api.inst.currentUser != null) {
        log('\nUser: ${Api.inst.currentUser}');
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeView()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginView()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.asset('assets/app_icon.png'),
            Text(
              'We Chat',
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.10,
                  fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
    );
  }
}
