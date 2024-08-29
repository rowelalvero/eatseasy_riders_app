import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:eatseasy_riders_app/global/global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/sign_in_provider.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    //Splash Screen wait 4 seconds
    Timer(const Duration(seconds: 4), () async {
      final sp = context.read<SignInProvider>();

      //If the vendor already Logged in send them directly to the Home screen
        final currentUser = firebaseAuth.currentUser;
        if (currentUser != null) {
        print(currentUser.phoneNumber);
        print("sasasa");
        await sp
            .getDataFromSharedPreferences()
            .then((value) => sp
            .getUserDataFromFirestore(sp.uid)
            .then((value) => sp
            .saveDataToSharedPreferences()
            .then((value) =>
            sp.setSignIn().then((value) {

              Navigator.pushReplacementNamed(context, '/homeScreen');
            }))));
        /*if (await sp.checkUserApproved()) {

        }*/
      }

      //If vendor is not logged in send them to Authentication and LogIn screen
      else {
        Navigator.pushReplacementNamed(context, '/logInScreen');
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
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "EatsEasy",
                          style: TextStyle(color: Colors.white, fontSize: 65, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "rider",
                          style: TextStyle(color: Colors.white, fontSize: 33, fontFamily: "Poppins", fontStyle: FontStyle.italic),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
