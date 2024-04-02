

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../authentication/auth_screen.dart';
import '../global/global.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 242, 198, 65),
          title: Text(sharedPreferences!.getString("firstName")!,
              style: const TextStyle(
                  fontSize: 30,
                  fontFamily: "Poppins",
                  fontWeight: FontWeight.w800,
                  color: Color.fromARGB(255, 67, 83, 89))),
          //Remove the appbar back button
          automaticallyImplyLeading: false,
          //appBar elevation/shadow
          elevation: 2,
          centerTitle: true
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text(
            "Logout"
          ),
          onPressed: () {
            firebaseAuth.signOut();
            Route newRoute = MaterialPageRoute(builder: (c) => const AuthScreen());
            Navigator.pushReplacement(context, newRoute);
          },
        ),
      ),
    );
  }
}
