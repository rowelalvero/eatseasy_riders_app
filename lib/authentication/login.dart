import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/authentication/register.dart';
import 'package:eatseasy_riders_app/authentication/register2.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  //Check email and password
  formValidation(){
   if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
     //Login
     logInNow();
   }
   //If one or both text field are empty display error
   else {
     showDialog(context: context, builder: (c) {
       return const ErrorDialog(
         message: "Please provide email and password",
       );
     });
   }
  }

  logInNow() async {
    showDialog(context: context, builder: (c) {
      return const LoadingDialog(message: "Logging In",);
    });

    //Firebase current user
    User? currentUser;
    //Authenticate vendor
    await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
    ).then((auth) {
      //
      currentUser = auth.user!;


    }).catchError((error) {
      //
      Navigator.pop(context);
      showDialog(context: context, builder: (c) {
        return ErrorDialog(
          message: error.message.toString(),
        );
      });
    });
    //
    if(currentUser != null) {

      readDataAndSetDataLocally(currentUser!).then((value) {
        Navigator.pop(context);
        //Route newRoute = MaterialPageRoute(builder: (c) => const HomeScreen());
        //Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async {
    await FirebaseFirestore.instance.collection("vendors").
    doc(currentUser.uid)
        .get().then((snapshot) async {
          await sharedPreferences!.setString("uid", currentUser.uid);
          await sharedPreferences!.setString("email", snapshot.data()!["vendorEmail"]);
          await sharedPreferences!.setString("name", snapshot.data()!["businessName"]);
          await sharedPreferences!.setString("photoUrl", snapshot.data()!["vendorAvatarUrl"]);
          await sharedPreferences!.setString("contactNumber", snapshot.data()!["contactNumber"]);
          await sharedPreferences!.setString("address", snapshot.data()!["businessAddress"]);
    });
  }

  void registrationPage() {
    //show loading screen after submitting
    showDialog(
        context: context,
        builder: (c) {
          return const LoadingDialog(
            message: "Loading",
          );
        });

    Timer(const Duration(seconds: 3), () async {
      Navigator.pop(context);
      Navigator.push(context,MaterialPageRoute(builder: (c) => RegisterScreen2()));
    });


  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(height: 20),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Welcome!",
                        style: TextStyle(
                          fontSize: 30,
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w800,
                        )),
                    Text(
                      'Login with your Rider account to continue.',
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontSize: 14,
                          color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Image.asset(
                "images/signup.png",
                height: 270,
              ),
            ),
          ),

          //Header
          Form(
            key: _formKey,
            child: Column(
              children: [


                //spacing
                const SizedBox(height: 20),

                //Vendor credential inputs
                //Email text field
                CustomTextField(
                  data: Icons.email_rounded,
                  controller: emailController,
                  hintText: "Email",
                  isObsecure: false,
                  keyboardType: TextInputType.text,
                ),

                //Password text field
                CustomTextField(
                  data: Icons.password_rounded,
                  controller: passwordController,
                  hintText: "Password",
                  isObsecure: true,
                  keyboardType: TextInputType.text,
                ),
              ],
            ),
          ),

          //Spacing
          const SizedBox(
            height: 10,
          ),

          //Login button
          ElevatedButton(
            onPressed: () => formValidation(),
            // ignore: sort_child_properties_last
            child: const Text(
              "Login",
              style: TextStyle(
                color: Color.fromARGB(255, 67, 83, 89),
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),

            //Login button styling
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 242, 198, 65),
                padding:
                    const EdgeInsets.symmetric(horizontal: 166, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),
          ),

          //Register Button
          Column(
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
        ],
      ),
    );
  }
}
