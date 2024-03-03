import 'package:flutter/material.dart';

import 'login.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 242, 198, 65),
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("EatsEasy",
                          style: TextStyle(
                              fontSize: 30,
                              fontFamily: "Poppins",
                              fontWeight: FontWeight.w800,
                              color: Color.fromARGB(255, 67, 83, 89))),
                      Text(" rider",
                          style: TextStyle(
                              fontSize: 25,
                              fontFamily: "Poppins",
                              fontStyle: FontStyle.italic,
                              color: Color.fromARGB(255, 67, 83, 89))),
                    ],
                  ),
                ],
              ),
              //Remove the appbar back button
              automaticallyImplyLeading: false,
              //appBar elevation/shadow
              elevation: 2,
              centerTitle: true),

          //Login body
          body: const TabBarView(
            children: [
              LogInScreen(),
            ],
          )),
    );
  }
}
