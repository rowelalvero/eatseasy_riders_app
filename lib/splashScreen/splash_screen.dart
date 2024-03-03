import 'dart:async';

import 'package:eatseasy_riders_app/authentication/auth_screen.dart';
import 'package:eatseasy_riders_app/global/global.dart';
import 'package:flutter/material.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {

    //Splash Screen wait 4 seconds
    Timer(const Duration(seconds: 4), () async {

      //If the vendor already Logged in send them directly to the Home screen
      if (firebaseAuth.currentUser != null) {
        //Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const HomeScreen()));
      }
      //If vendor is not logged in send them to Authentication and LogIn screen
      else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const AuthScreen()));
      }
    });
  }

  //Start timer
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {

    //Splash Screen
    return Material(
      child: Container(
        color: const Color.fromARGB(255, 242, 198, 65),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Image.asset("images/logo.png"),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
