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
  bool isContactNumberCompleted = true;
  String _password = '';
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasEightChar = false;
  bool _isUserTypingPassword = false;
  bool _isUserTypingConfirmPassword = false;
  bool _isUserTypingContactNumber = false;
  bool _isUserTypingEmail = false;
  bool _isPasswordMatched = false;

  FocusNode passwordFocusNode = FocusNode();

  //form key instance
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Text fields controllers
  TextEditingController cityController = TextEditingController();
  TextEditingController serviceType = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleInitialController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  final List<String> _dropdownItems = [
    'Delivery-partners / Riders',
    'Delivery-partners / Riders - Bicycle',
    'Delivery-partners / Foot',
  ];

  final List<String> _suffixDropdownItems = [
    'Jr.',
    'Sr.',
    'II',
    'III',
    'IV',
    ' '
  ];

  String? _suffixController;

  @override
  void initState() {
    super.initState();
    serviceType = TextEditingController();
    // Set the initial value of the controller to the first item in the dropdown
    serviceType.text = _dropdownItems.first;
    /*suffixController.text = _suffixDropdownItems.first;*/
  }

  void _validatePassword(String value) {
    setState(() {
      _password = value;
      setState(() {
        _isUserTypingPassword = true;
        _matchPassword();
      });
      // Password must have uppercase at least
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(_password);
      // Password must have lowercase at least
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(_password);
      // Password must have one number at least
      _hasNumber = RegExp(r'[0-9]').hasMatch(_password);
      // Password length should be at least 8 characters
      if (_password.length >= 8) {
        setState(() {
          _hasEightChar = true;
        });
      }
      else {
        setState(() {
          _hasEightChar = false;
        });
      }
    });
  }

  void _matchPassword() {
    if (passwordController.text == confirmPasswordController.text) {
      if (confirmPasswordController.text.isEmpty) {
        setState(() {
          _isPasswordMatched = false;
        });
      }
      else {
        setState(() {
          _isPasswordMatched = true;
        });
      }
    }
    else {
      setState(() {
        _isPasswordMatched = false;
      });
    }
  }

  bool _isPasswordValidated() {
    if (_hasUpperCase == true &&
        _hasLowerCase == true &&
        _hasNumber == true &&
        _hasEightChar == true){

      return true;
    }

    return false;
  }

  bool _isCityControllerInvalid = false;
  bool _isFirstNameControllerInvalid = false;
  bool _isLastNameControllerInvalid = false;
  bool _isEmailControllerInvalid = false;
  bool _isContactNumberControllerInvalid = false;
  bool _isPasswordControllerInvalid = false;
  bool _isConfirmPasswordControllerInvalid = false;
  bool _isFormComplete = true;

  //Check if the required fields are filled
  void _validateTextFields() {
    if (cityController.text.isEmpty) {
      setState(() {
        _isCityControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (firstNameController.text.isEmpty) {
      setState(() {
        _isFirstNameControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (lastNameController.text.isEmpty) {
      setState(() {
        _isLastNameControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (contactNumberController.text.isEmpty) {
      setState(() {
        _isContactNumberControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (passwordController.text.isEmpty) {
      setState(() {
        _isPasswordControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        _isConfirmPasswordControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (emailController.text.isEmpty) {
     setState(() {
       _isEmailControllerInvalid = true;
       _isFormComplete = false;
     });
    }
    if (cityController.text.isNotEmpty &&
        firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty) {

      _isFormComplete = true;
    }
  }



  //Check if the format of email is valid
  bool isValidEmail(email) {
    // Regular expression for email validation
    final RegExp emailRegex =
    RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegex.hasMatch(email);
  }

  //Form validation
  Future<void> _formValidation() async {
    String email = emailController.text.trim();
    _validateTextFields();
    if (_isFormComplete) {
      if (_isPasswordValidated()) {
        if(_isPasswordMatched) {
          if(isValidEmail(email)) {
            if (isContactNumberCompleted) {
              //show loading screen after submitting
              showDialog(
                  context: context,
                  builder: (c) {
                    return const LoadingDialog(
                      message: "Submitting", isRegisterPage: false,
                    );
                  });

              //Authenticate the rider
              authenticateVendorAndSignUp();
            }
            else {
              showDialog(
                  context: context,
                  builder: (c) {
                    return const ErrorDialog(
                      message: "Invalid contact number. Please try again.",
                    );
                  });
            }
          }
          else {
            setState(() {
              _isEmailControllerInvalid = true;
            });
            showDialog(
                context: context,
                builder: (c) {
                  return const ErrorDialog(
                    message: "Email format is invalid.",
                  );
                });
          }
        }
        else {
          showDialog(
              context: context,
              builder: (c) {
                return const ErrorDialog(
                  message: "Passwords don't match.",
                );
              });
        }
      }
      else {
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Password is invalid.",
              );
            });
      }
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
      "suffix": _suffixController, // Storing suffix after trimming leading/trailing whitespace
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
                      //City text field
                      CustomTextField(
                        data: Icons.location_city_rounded,
                        controller: cityController,
                        hintText: "City*",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                        redBorder: _isCityControllerInvalid,
                          noLeftMargin: false,
                          noRightMargin: false,
                          onChanged:(value) {
                          setState(() {
                            _isCityControllerInvalid = false;
                          });
                          }
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

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            //Last name text field
                              child: CustomTextField(
                                  data: Icons.person_2_rounded,
                                  controller: lastNameController,
                                  hintText: "Last Name*",
                                  isObsecure: false,
                                  keyboardType: TextInputType.text,
                                  redBorder: _isLastNameControllerInvalid,
                                  noLeftMargin: false,
                                  noRightMargin: true,
                                  onChanged:(value) {
                                    setState(() {
                                      _isLastNameControllerInvalid = false;
                                    });
                                  }
                              ),
                          ),

                          //Suffix text field
                          Expanded(
                              flex: 1,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              margin: const EdgeInsets.only(left: 4.0, right: 18.0, top: 8.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE0E3E7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: SizedBox(
                                child: DropdownButtonFormField<String>(
                                  hint: const Text('Suffix'), // Hint text
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  value: _suffixController,
                                  onChanged: (String? newValue) async {
                                    setState(() {
                                      _suffixController = newValue!;
                                    });
                                  },
                                  items: _suffixDropdownItems.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  dropdownColor: Colors.white,
                                  // Set the background color of the dropdown list
                                  elevation: 2, // Set the elevation of the dropdown list
                                ),
                              ),
                            ),
                          ),

                          /*Expanded(
                            flex: 1,
                              child: CustomTextField(
                                data: null,
                                controller: suffixController,
                                hintText: "Suffix",
                                isObsecure: false,
                                keyboardType: TextInputType.text,
                                noLeftMargin: true,
                                noRightMargin: false,
                                redBorder: false,
                              ),
                          ),*/
                        ],
                      ),

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            //Firstname text fields
                            child: CustomTextField(
                                data: Icons.person_2_rounded,
                                controller: firstNameController,
                                hintText: "First Name*",
                                isObsecure: false,
                                keyboardType: TextInputType.text,
                                redBorder: _isFirstNameControllerInvalid,
                                noLeftMargin: false,
                                noRightMargin: true,
                                onChanged:(value) {
                                  setState(() {
                                    _isFirstNameControllerInvalid = false;
                                  });
                                }
                            ),
                          ),
                          //Middle Initial text field
                          Expanded(
                            flex: 1,
                            child: CustomTextField(
                              data: null,
                              controller: middleInitialController,
                              hintText: "Middle In.",
                              isObsecure: false,
                              keyboardType: TextInputType.text,
                              noLeftMargin: true,
                              noRightMargin: false,
                              redBorder: false,
                            ),
                          ),
                        ],
                      ),
                      //Contact number text field,
                      Container(
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
                        margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
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
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(Icons.phone_android_rounded, color: Color.fromARGB(255, 67, 83, 89)),
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: "Contact Number*",
                                  ),
                                onChanged: (value) {
                                    setState(() {
                                      _isUserTypingContactNumber = true;
                                      _isContactNumberControllerInvalid = false;
                                    });
                                  if (value.length == 11) {
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

                      //Show "Invalid Contact number"
                      if (_isUserTypingContactNumber && isContactNumberCompleted == false)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text("Invalid Contact number",
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

                      //Email text field
                      CustomTextField(
                        data: Icons.email_rounded,
                        controller: emailController,
                        hintText: "Email*",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                        redBorder: _isEmailControllerInvalid,
                          noLeftMargin: false,
                          noRightMargin: false,
                          onChanged:(value) {
                            setState(() {
                              _isEmailControllerInvalid = false;
                              _isUserTypingEmail= true;
                            });
                          }
                      ),
                      //Show "Passwords don't match"
                      if (_isEmailControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text("Email format is invalid",
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

                      //Password text field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E3E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isPasswordControllerInvalid
                                ? Colors.red
                                : _isUserTypingPassword ? (_isPasswordValidated() ? Colors.green : Colors.red) : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            double maxWidth = MediaQuery.of(context).size.width * 0.9;
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxWidth),
                              child: TextFormField(
                                  enabled: true,
                                  controller: passwordController,
                                  obscureText: true,
                                  cursorColor: const Color.fromARGB(255, 242, 198, 65),
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(Icons.password_rounded, color: Color.fromARGB(255, 67, 83, 89)),
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: "Password*",
                                  ),
                                  onChanged: (value) {
                                    _isPasswordControllerInvalid = false;
                                    _validatePassword(value);
                                  }
                              ),
                            );
                          },
                        ),
                      ),

                      //Validation notifier
                      if (_isUserTypingPassword)
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Password must contain: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: "Poppins",
                                      color: Color.fromARGB(255, 67, 83, 89),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildValidationRow(
                                        'At least one uppercase letter',
                                        _hasUpperCase,
                                      ),
                                      _buildValidationRow(
                                        'At least one lowercase letter',
                                        _hasLowerCase,
                                      ),
                                      _buildValidationRow(
                                        'At least one number',
                                        _hasNumber,
                                      ),
                                      _buildValidationRow(
                                        'Minimum of 8 characters',
                                        _hasEightChar,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                      //Confirm password text field
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E3E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isConfirmPasswordControllerInvalid
                                ? Colors.red
                                : _isUserTypingConfirmPassword ? (_isPasswordMatched ? Colors.green : Colors.red) : Colors.transparent,
                          ),
                        ),
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                        child: LayoutBuilder(
                          builder: (BuildContext context, BoxConstraints constraints) {
                            double maxWidth = MediaQuery.of(context).size.width * 0.9;
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: maxWidth),
                              child: TextFormField(
                                enabled: true,
                                controller: confirmPasswordController,
                                obscureText: true,
                                cursorColor: const Color.fromARGB(255, 242, 198, 65),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(Icons.password_rounded, color: Color.fromARGB(255, 67, 83, 89)),
                                  focusColor: Theme.of(context).primaryColor,
                                  hintText: 'Confirm Password*',
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _isUserTypingConfirmPassword = true;
                                    _isConfirmPasswordControllerInvalid = false;
                                  });

                                  _matchPassword();
                                  }
                              ),
                            );
                          },
                        ),
                      ),

                      //Show "Passwords don't match"
                      if (_isUserTypingConfirmPassword && _isPasswordMatched == false)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 10),
                                  Text("Passwords don't match",
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
                    ],
                  )),

              //spacing
              const SizedBox(
                height: 10,
              ),

              //Submit button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isButtonPressed ? null : () => _formValidation(),
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

  Widget _buildValidationRow(String message, bool isValid) {
    return Row(
      children: <Widget>[
        Icon(
          isValid ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 10),
        Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: isValid ? Colors.green : const Color.fromARGB(255, 67, 83, 89),
            fontFamily: "Poppins",
          ),
        ),
      ],
    );
  }
}

