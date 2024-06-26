import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/internet_provider.dart';
import '../provider/sign_in_provider.dart';
import '../utils/next_screen.dart';
import '../utils/snack_bar.dart';
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

  TextEditingController contactNumberController = TextEditingController();
  TextEditingController otpCodeController = TextEditingController();

  bool _isContactNumberControllerInvalid = false;
  bool isContactNumberCompleted = true;
  bool _isUserTypingContactNumber = false;
  bool _isFormComplete = true;

  //Check if the required fields are all filled
  void _validateTextFields() {
    if (contactNumberController.text.isEmpty) {
      setState(() {
        _isContactNumberControllerInvalid = true;
        _isFormComplete = false;
      });
    } else {
      _isFormComplete = true;
    }
  }

  //Check email and password
  _formValidation() async {
    _validateTextFields();
    if (contactNumberController.text.isNotEmpty) {
      if (isContactNumberCompleted) {
        showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(
                message: "Submitting", isRegisterPage: false,
              );
            });

        // Check if the number existing
        DocumentSnapshot snap = await FirebaseFirestore.instance.collection('riders').doc("+63${contactNumberController.text.trim()}").get();
        if (snap.exists) {
          print("EXISTING USER");
          login(context, contactNumberController.text.trim());
        } else {
          print("NEW USER");
          setState(() {
            _isContactNumberControllerInvalid = true;
          });

          Navigator.pop(context);
          // user do not exists
          showDialog(
              context: context,
              builder: (c) {
                return const ErrorDialog(
                  message: "Account does not exist.",
                );
              });
        }
        //Login

      } else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Invalid contact number. Please try again.",
              );
            });
      }
    }
    //If contact number is empty, display error
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

  Future login(BuildContext context, String mobile) async {
    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    if (ip.hasInternet == false) {
      Navigator.pop(context);
      openSnackbar(context, "Check your internet connection", Colors.red);
    } else {
      if (_formKey.currentState!.validate()) {
        FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: "+63$mobile",
            verificationCompleted: (AuthCredential credential) async {
              await FirebaseAuth.instance.signInWithCredential(credential);
            },
            verificationFailed: (FirebaseAuthException e) {
              Navigator.pop(context);
              openSnackbar(context, e.toString(), Colors.red);
            },
            codeSent: (String verificationId, int? forceResendingToken) {
              Navigator.pop(context);
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Enter OTP Code"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: otpCodeController,
                            decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.code),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    const BorderSide(color: Colors.red)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    const BorderSide(color: Colors.grey)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                    const BorderSide(color: Colors.grey))),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              showDialog(
                                  context: context,
                                  builder: (c) {
                                    return const LoadingDialog(
                                      message: "We are signing you in", isRegisterPage: false,
                                    );
                                  });
                              final code = otpCodeController.text.trim();
                              AuthCredential authCredential =
                              PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                              User user = (await FirebaseAuth.instance
                                  .signInWithCredential(authCredential))
                                  .user!;

                              sp.phoneNumberLogin(user);

                              if (await sp.checkUserApproved()) {
                                // user exists
                                await sp
                                    .getUserDataFromFirestore(sp.uid)
                                    .then((value) => sp
                                    .saveDataToSharedPreferences()
                                    .then((value) =>
                                    sp.setSignIn().then((value) {

                                      Navigator.pop(context);
                                      isButtonPressed = !isButtonPressed;
                                      nextScreenReplace(context, '/homeScreen');
                                    })));
                              }
                              else {
                                Navigator.pop(context);
                                // user is restricted to login
                                showDialog(
                                    context: context,
                                    builder: (c) {
                                      return const ErrorDialog(
                                        message: "Account is restricted.",
                                      );
                                    });
                              }

                            },
                            child: const Text("Confirm"),
                          )
                        ],
                      ),
                    );
                  });
            },
            codeAutoRetrievalTimeout: (String verification) {});
      }
    }
  }
  /*logInNow() async {
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
    await firebaseAuth.signInWithEmailAndPassword(
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
  }*/

  void registrationPage() {
    Navigator.pushNamed(context, '/registerScreen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
              image: const DecorationImage(
                  image: AssetImage('images/background.png'), // Replace with your desired image
                  fit: BoxFit.cover,
                  opacity: 0.1
              ),
              gradient: LinearGradient(begin: Alignment.topCenter, colors: [
                Colors.yellow.shade900,
                Colors.yellow.shade800,
                Colors.yellow.shade400
              ])),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /*const SizedBox(
                  height: 200,
                ),*/
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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

              /*const SizedBox(height: 130),*/
              Expanded(
                flex: 1,
                child: Container(
                  height: MediaQuery.of(context).size.height,
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
                              const SizedBox(
                                height: 10,
                              ),
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
                          child: //Contact number text field,
                          Form(
                            key: _formKey,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: CustomTextField(
                                    data: Icons.phone,
                                    hintText: "+63",
                                    isObsecure: false,
                                    keyboardType: TextInputType.none,
                                    noLeftMargin: false,
                                    noRightMargin: true,
                                    redBorder: false,
                                    enabled: false,
                                  ),
                                ),

                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE0E3E7),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isContactNumberControllerInvalid
                                            ? Colors.red
                                            : _isUserTypingContactNumber ? (isContactNumberCompleted ? Colors.green : Colors.red) : Colors.transparent,
                                      ),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    margin: const EdgeInsets.only(left: 4.0, right: 18.0, top: 8.0),
                                    child: LayoutBuilder(
                                      builder: (BuildContext context, BoxConstraints constraints) {
                                        double maxWidth = MediaQuery.of(context).size.width * 0.9;
                                        return ConstrainedBox(
                                          constraints: BoxConstraints(maxWidth: maxWidth),
                                          child: TextFormField(
                                            enabled: true,
                                            controller: contactNumberController,
                                            obscureText: false,
                                            cursorColor: const Color.fromARGB(255, 242, 198, 65),
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              focusColor: Theme.of(context).primaryColor,
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                _isUserTypingContactNumber = true;
                                                _isContactNumberControllerInvalid = false;
                                              });
                                              if (value.length == 10) {
                                                setState(() {
                                                  isContactNumberCompleted = true;
                                                });
                                              }
                                              else {
                                                if (contactNumberController.text.isEmpty) {
                                                  setState(() {
                                                    _isUserTypingContactNumber = false;
                                                  });
                                                }
                                                else {
                                                  setState(() {
                                                    isContactNumberCompleted = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        //Show "Invalid Contact number"
                        if ((_isUserTypingContactNumber &&
                            isContactNumberCompleted == false) || _isContactNumberControllerInvalid)
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 2),
                                    Text("Enter a valid contact number",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: "Poppins",
                                          color: Colors.red,
                                        )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
                          height: 20,
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
                                    onPressed: () => nextScreen(context, '/registerScreen'),
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
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
