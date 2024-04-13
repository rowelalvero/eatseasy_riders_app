import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../global/global.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  bool isButtonPressed = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //Check email and password
  _formValidation() {
    isButtonPressed = !isButtonPressed;
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      //Login
      logInNow();
    }
    //If one or both text field are empty display error
    else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please provide email and password",
            );
          });
    }
  }

  logInNow() async {
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: "Logging In",
            isRegisterPage: false,
          );
        });

    //Firebase current user
    User? currentUser;
    //Authenticate vendor
    await firebaseAuth
        .signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    )
        .then((auth) {
      //
      currentUser = auth.user!;
    }).catchError((error) {
      //
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });
    //
    if (currentUser != null) {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance
        .collection("riders")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      // Check if snapshot exists and has data
      if (snapshot.exists) {
        // Access fields safely using null-aware operators
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("riderEmail", snapshot.data()!["riderEmail"] ?? "");
        await sharedPreferences!.setString("firstName", snapshot.data()!["firstName"] ?? "");
        await sharedPreferences!.setString("riderAvatarUrl", snapshot.data()!["riderAvatarUrl"] ?? "");
        await sharedPreferences!.setString("contactNumber", snapshot.data()!["contactNumber"] ?? "");
        await sharedPreferences!.setString("residentialAddress",snapshot.data()!["savedResidentialAddress"] ?? "");

        Navigator.pop(context);
        Navigator.pushReplacementNamed(context, '/homeScreen');
      } else {
        firebaseAuth.signOut();
        Navigator.pop(context);
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "No record found.",
              );
            });
      }
    });
  }

  void registrationPage() {
    Navigator.pushNamed(context, '/registerScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Change mainAxisSize to MainAxisSize.min
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  image: const DecorationImage(
                      image: AssetImage('images/background.png'), // Replace with your desired image
                      fit: BoxFit.cover,
                      opacity: 0.4
                  ),
                  gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                    Colors.orange.shade900,
                    Colors.orange.shade800,
                    Colors.orange.shade400
                  ])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                child: const Text(
                                  "EatsEasy",
                                  style: TextStyle(color: Colors.white, fontSize: 65, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                                )),
                            const SizedBox(
                              height: 10,
                            ),
                            FadeInUp(
                                duration: const Duration(milliseconds: 500),
                                child: const Text(
                                  "rider",
                                  style: TextStyle(color: Colors.white, fontSize: 33, fontFamily: "Poppins", fontStyle: FontStyle.italic),
                                )),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(60),
                            topRight: Radius.circular(60))),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                FadeInUp(
                                    duration: const Duration(milliseconds: 500),
                                    child: const Text(
                                      "Welcome!",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 40,
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w700
                                      ),
                                    )),
                                const SizedBox(
                                  height: 10,
                                ),
                                FadeInUp(
                                    duration: const Duration(milliseconds: 500),
                                    child: const Text(
                                      "Login with your Rider account to continue",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                          fontFamily: "Poppins"
                                      ),
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: Column(
                                children: <Widget>[
                                  //Vendor credential inputs
                                  //Email text field
                                  CustomTextField(
                                    data: Icons.email_rounded,
                                    controller: emailController,
                                    hintText: "Email",
                                    isObsecure: false,
                                    redBorder: false,
                                    noLeftMargin: false,
                                    noRightMargin: false,
                                    keyboardType: TextInputType.text,
                                  ),

                                  //Password text field
                                  CustomTextField(
                                    data: Icons.password_rounded,
                                    controller: passwordController,
                                    hintText: "Password",
                                    isObsecure: true,
                                    redBorder: false,
                                    noLeftMargin: false,
                                    noRightMargin: false,
                                    keyboardType: TextInputType.text,
                                  ),
                                ],
                              )),
                          /*const SizedBox(
                            height: 40,
                          ),
                          FadeInUp(
                              duration: const Duration(milliseconds: 500),
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(color: Colors.grey),
                              )),
                          const SizedBox(
                            height: 40,
                          ),*/
                          const SizedBox(
                            height: 40,
                          ),
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: isButtonPressed
                                          ? null
                                          : () => _formValidation(),
                                      // Register button styling
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isButtonPressed
                                            ? Colors.grey
                                            : const Color.fromARGB(255, 242, 198, 65),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        elevation: 4,
                                        // Elevation for the shadow
                                        shadowColor: Colors.grey
                                            .withOpacity(0.3), // Light gray
                                      ),
                                      child: Text(
                                        isButtonPressed ? "Sign In" : "Sign In",
                                        style: TextStyle(
                                          color: isButtonPressed
                                              ? Colors.black54
                                              : const Color.fromARGB(
                                              255, 67, 83, 89),
                                          fontFamily: "Poppins",
                                          fontWeight: FontWeight.w700,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Register Button
                          FadeInUp(
                            duration: const Duration(milliseconds: 500),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account?",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontFamily: "Poppins",
                                        color: Colors.black54,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => registrationPage(),
                                      child: const Text(
                                        "Register",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Poppins",
                                          color: Color.fromARGB(255, 242, 198, 65),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                          /*const SizedBox(height: 50,),
                        FadeInUp(duration: const Duration(milliseconds: 500), child: const Text("Continue with social media", style: TextStyle(color: Colors.grey),)),
                        const SizedBox(height: 30,),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: FadeInUp(duration: const Duration(milliseconds: 500), child: MaterialButton(
                                onPressed: (){},
                                height: 50,
                                color: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Center(
                                  child: Text("Facebook", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              )),
                            ),
                            const SizedBox(width: 30,),
                            Expanded(
                              child: FadeInUp(duration: const Duration(milliseconds: 500), child: MaterialButton(
                                onPressed: () {},
                                height: 50,
                                shape: RoundedRectangleBorder(


 borderRadius: BorderRadius.circular(50),

                                ),
                                color: Colors.black,
                                child: const Center(
                                  child: Text("Github", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                ),
                              )),
                            )
                          ],
                        )*/
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
