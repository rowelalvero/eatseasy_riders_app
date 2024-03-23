import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/authentication/register2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mime/mime.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../global/global.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool isButtonPressed = false;
  //form key instance
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Text fields controllers
  TextEditingController cityController = TextEditingController();
  TextEditingController serviceType = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleInitialController = TextEditingController();
  TextEditingController suffixController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final List<String> _dropdownItems = [
    'Delivery-partners / Riders',
    'Delivery-partners / Riders - Bicycle',
    'Delivery-partners / Foot',
  ];

  @override
  void initState() {
    super.initState();
    serviceType = TextEditingController();
    // Set the initial value of the controller to the first item in the dropdown
    serviceType.text = _dropdownItems.first;
  }


  //Form validation
  Future<void> formValidation() async {
    //check if password and confirm password are matched
    if (passwordController.text == confirmPasswordController.text) {
      //check if one of the textfields is empty
      if (confirmPasswordController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          lastNameController.text.isNotEmpty &&
          firstNameController.text.isNotEmpty &&
          contactNumberController.text.isNotEmpty &&
          cityController.text.isNotEmpty &&
          serviceType.text.isNotEmpty) {
        //show loading screen after submitting
        showDialog(
            context: context,
            builder: (c) {
              return const LoadingDialog(
                message: "Submitting",
              );
            });

        //Authenticate the rider
        authenticateVendorAndSignUp();
      }
      //fill the empty fields
      else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please fill up all required fields*",
              );
            });
      }
    }
    //please check the password if matched
    else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Passwords do not match.",
            );
          });
    }
  }

  //Authenticate the rider
  void authenticateVendorAndSignUp() async {
    User? currentUser;
    sharedPreferences = await SharedPreferences.getInstance();
    //Create or authenticate rider email and password to Firestore
    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      //Once authenticated, assign the authenticated rider to currentUser variable
      currentUser = auth.user;
    }).catchError((error) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c) {
            return ErrorDialog(
              message: error.message.toString(),
            );
          });
    });

    if (currentUser != null) {
      // Save user's credentials to SharedPreferences
      await saveCurrentUserToSharedPreferences(currentUser!);
      //Set the isButtonPressed to true to disable the button after pressing submit button
      setState(() {
        isButtonPressed = !isButtonPressed;
      });
    }

    //If the rider is authenticated
    if (currentUser != null) {
      //save rider's credential to Firestore by calling the function
      await saveDataToFirestore(currentUser!).then((value) {
        //Stop the loading screen
        Navigator.pop(context);

        //To prevent the user to go directly to home screen after restarted the app
        firebaseAuth.signOut();

        //Going back to Login page to login rider's credentials
        Route newRoute = MaterialPageRoute(builder: (c) => const RegisterScreen2());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }
  //Save currentUser to sharedPreferences
  Future<void> saveCurrentUserToSharedPreferences(User user) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('currentUserUid', user.uid);
  }

  //Saves rider information to Firestore
  Future saveDataToFirestore(User currentUser) async {
    // Accessing the Firestore collection 'riders' and setting the document with their unique currentUser's UID
    await FirebaseFirestore.instance.collection("riders").doc(currentUser.uid).set({
      "riderUID": currentUser.uid, // Storing user's UID
      "riderEmail": currentUser.email, // Storing user's email
      "cityAddress": cityController.text.trim(), // Storing city address after trimming leading/trailing whitespace
      "lastName": lastNameController.text.trim(), // Storing last name after trimming leading/trailing whitespace
      "firstName": firstNameController.text.trim(), // Storing first name after trimming leading/trailing whitespace
      "M.I.": middleInitialController.text.trim(), // Storing middle initial after trimming leading/trailing whitespace
      "suffix": suffixController.text.trim(), // Storing suffix after trimming leading/trailing whitespace
      "contactNumber": contactNumberController.text.trim(), // Storing contact number after trimming leading/trailing whitespace
      "serviceType": serviceType.text.trim(), //Storing the service type of the rider
      "status": "pending", // Setting the status to 'pending'
      "earnings": 0.0, // Initializing earnings as 0.0
    });

    //Save rider's data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("contactNumber", contactNumberController.text.trim());
    await sharedPreferences?.setString('email', emailController.text.trim());
    await sharedPreferences?.setString('password', passwordController.text.trim());
    await sharedPreferences?.setString('confirmPassword', confirmPasswordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    Text(" register",
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

        //Register body
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              //Text Fields
              const SizedBox(height: 10),
              Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      //city text field
                      CustomTextField(
                        data: Icons.location_city_rounded,
                        controller: cityController,
                        hintText: "City*",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                      ),

                      //Service type dropdown
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(
                            left: 18.0, right: 18.0, top: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E3E7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        width: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.6 : double.infinity,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Select an item', // Hint text
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                          value: serviceType.text,
                          items: _dropdownItems.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,child: Row(
                              children: [
                                const Icon(Icons.motorcycle_rounded), // Icon
                                const SizedBox(width: 10), // Add some space between icon and text
                                Text(item),
                              ],
                            ),
                            );
                          }).toList(),
                          onChanged: (String? selectedItem) {
                            setState(() {
                              serviceType.text = selectedItem!;
                            });
                          },
                        ),
                      ),

                      //first name text field
                      CustomTextField(
                        data: Icons.person_2_rounded,
                        controller: firstNameController,
                        hintText: "First Name*",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                      ),

                      //last name text field
                      CustomTextField(
                        data: Icons.person_2_rounded,
                        controller: lastNameController,
                        hintText: "Last Name*",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                      ),

                      //Middle initial text field
                      CustomTextField(
                        data: Icons.person_2_rounded,
                        controller: middleInitialController,
                        hintText: "M.I.",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                      ),

                      //Suffix text field
                      CustomTextField(
                        data: Icons.person_2_rounded,
                        controller: suffixController,
                        hintText: "Suffix",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                      ),

                      //contact number text field
                      CustomTextField(
                        keyboardType: TextInputType.number,
                        data: Icons.phone_android_rounded,
                        controller: contactNumberController,
                        hintText: "Contact Number*",
                        isObsecure: false,
                      ),

                      //email text field
                      CustomTextField(
                        data: Icons.email_rounded,
                        controller: emailController,
                        hintText: "Email*",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                      ),

                      //password text field
                      CustomTextField(
                        data: Icons.password_rounded,
                        controller: passwordController,
                        hintText: "Password*",
                        isObsecure: true,
                        keyboardType: TextInputType.text,
                      ),

                      //confirm password text field
                      CustomTextField(
                        data: Icons.password_rounded,
                        controller: confirmPasswordController,
                        hintText: "Confirm password*",
                        isObsecure: true,
                        keyboardType: TextInputType.text,
                      ),
                    ],
                  )),

              //spacing
              const SizedBox(
                height: 10,
              ),

              //submit button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isButtonPressed ? null : () => formValidation(),
                        // Register button styling
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isButtonPressed ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          elevation: 4, // Elevation for the shadow
                          shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                        ),
                        child: Text(
                          isButtonPressed ? "Submitted" : "Submit",
                          style: TextStyle(
                            color: isButtonPressed ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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

              //spacing
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ));
  }
}
