import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/authentication/register2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../global/global.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'login.dart';

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
  bool _isPasswordMatched = false;
  bool _obscureText = true;

  FocusNode passwordFocusNode = FocusNode();

  //form key instance
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Text fields controllers
  TextEditingController cityController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleInitialController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  //Dropdown items of service type
  final List<String> _serviceTypeDropdownItems = [
    'Delivery-partners / Riders',
    'Delivery-partners / Bicycle',
    'Delivery-partners / Foot',
  ];

  late List<Map<String, dynamic>> _serviceTypeDropdownItemsWithIcons;

  //Dropdown items of suffixes
  final List<String> _suffixDropdownItems = [
    'Jr.',
    'Sr.',
    'II',
    'III',
    'IV',
    ' '
  ];

  //String var of suffix dropdown
  String? suffixController;
  //String var of service type dropdown
  String? serviceTypeController;

  @override
  void initState() {
    super.initState();
    _serviceTypeDropdownItemsWithIcons = _serviceTypeDropdownItems.map((item) {
      IconData icon;
      if (item.contains('Riders')) {
        icon = Icons.motorcycle_rounded;
      } else if (item.contains('Foot')) {
        icon = Icons.directions_walk;
      } else if (item.contains('Bicycle')) {
        icon = Icons.directions_bike;
      }
      else {
        icon = Icons.place;
      }
      return {'text': item, 'icon': icon};
    }).toList();
  }

  void _validatePassword(String value) {
    setState(() {
      _password = value;
      setState(() {
        _isUserTypingPassword = true; //Track if user is typing
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

  //Check if the passwords are matched
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

  //Check if the password met the validation criteria
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
  bool _isServiceTypeEmpty = false;
  bool _isFirstNameControllerInvalid = false;
  bool _isLastNameControllerInvalid = false;
  bool _isEmailControllerInvalid = false;
  bool _isContactNumberControllerInvalid = false;
  bool _isPasswordControllerInvalid = false;
  bool _isConfirmPasswordControllerInvalid = false;
  bool _isFormComplete = true;

  //Check if the required fields are all filled
  void _validateTextFields() {
    if (cityController.text.isEmpty) {
      setState(() {
        _isCityControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (serviceTypeController == null) {
      setState(() {
        _isServiceTypeEmpty = true;
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
        emailController.text.isNotEmpty &&
        serviceTypeController != null) {

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
    //Check if the required fields are all filled
    _validateTextFields();
    //Check if the form is completed
    if (_isFormComplete) {
      //Check if the password met the validation criteria
      if (_isPasswordValidated()) {
        //Check if the passwords are matched
        if(_isPasswordMatched) {
          //Check if the format of email is valid
          if(isValidEmail(email)) {
            //Check if the contact no. is complete
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
            //Display "invalid email" if its invalid format
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
      "suffix": suffixController, // Storing suffix after trimming leading/trailing whitespace
      "contactNumber": "+63${contactNumberController.text.trim()}", // Storing contact number after trimming leading/trailing whitespace
      "serviceType": serviceTypeController, //Storing the service type of the rider
      "status": "pending", // Setting the status to 'pending'
      "earnings": 0.0, // Initializing earnings as 0.0
    });

    //Save rider's data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("contactNumber", "+63${contactNumberController.text.trim()}");
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
          //appBar elevation/shadow
          elevation: 2,
          centerTitle: true,
          leadingWidth: 40.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0), // Adjust the left margin here
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded), // Change this icon to your desired icon
              onPressed: () {
                // Add functionality to go back
                Navigator.pop(context);
              },
            ),
          ),
        ),

        //Register body
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 20),


              const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Fill-out the required details and start driving with EatsEasy!",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 67, 83, 89),
                            fontFamily: "Poppins",
                          ),
                        ),
                        Text(
                          "Please provide the following information.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color.fromARGB(255, 67, 83, 89),
                            fontFamily: "Poppins",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                          textCapitalization: TextCapitalization.sentences,
                        redBorder: _isCityControllerInvalid,
                          noLeftMargin: false,
                          noRightMargin: false,
                          onChanged:(value) {
                          setState(() {
                            _isCityControllerInvalid = false;
                          });
                          }
                      ),

                      //Show "Please enter your city"
                      if (_isCityControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please enter your city",
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

                      //Service type dropdown
                      Container(
                        padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E3E7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _isServiceTypeEmpty ? Colors.red : Colors.transparent,
                          ),
                        ),
                        child: DropdownButtonFormField2<Map<String, dynamic>>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                          hint: const Text(
                            'Select your service type*',
                            style: TextStyle(fontSize: 16),
                          ),
                          items: _serviceTypeDropdownItemsWithIcons.map((item) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: item,
                              child: Row(
                                children: [
                                  Icon(item['icon']), // Icon
                                  const SizedBox(width: 10),
                                  Text(item['text'], style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            );
                          }).toList(),
                          validator: (value) {
                            if (value == null) {
                              return 'Select your service type*';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              _isServiceTypeEmpty = false;
                              serviceTypeController = value.toString();
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.only(right: 8),
                          ),
                          iconStyleData: const IconStyleData(
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: Colors.black45,
                            ),
                            iconSize: 24,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                      ),

                      //Show "Please select your service type"
                      if (_isServiceTypeEmpty == true)
                         const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please select your service type",
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

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            //Last name text field
                              child: CustomTextField(
                                  data: Icons.person_2_rounded,
                                  controller: lastNameController,
                                  hintText: "Last Name*",
                                  isObsecure: false,
                                  keyboardType: TextInputType.text,
                                  textCapitalization: TextCapitalization.sentences,
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
                              child: DropdownButtonFormField2<String>(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                hint: const Text('Suffix',
                                  style: TextStyle(fontSize: 16),
                                ),
                                items: _suffixDropdownItems.map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ))
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Suffix';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    suffixController = value.toString();
                                  });
                                },
                                buttonStyleData: const ButtonStyleData(
                                  padding: EdgeInsets.only(right: 8),
                                ),
                                iconStyleData: const IconStyleData(
                                  icon: Icon(Icons.arrow_drop_down,
                                    color: Colors.black45,
                                  ),
                                  iconSize: 24,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),

                      //Show "Please enter your first name"
                      if (_isLastNameControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please enter your first name",
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

                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            //Firstname text field
                            child: CustomTextField(
                                data: Icons.person_2_rounded,
                                controller: firstNameController,
                                hintText: "First Name*",
                                isObsecure: false,
                                keyboardType: TextInputType.text,
                                textCapitalization: TextCapitalization.sentences,
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
                              textCapitalization: TextCapitalization.sentences,
                              noLeftMargin: true,
                              noRightMargin: false,
                              redBorder: false,
                            ),
                          ),
                        ],
                      ),

                      //Show "Please enter your last name"
                      if (_isLastNameControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please enter your last name",
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

                      //Contact number text field,
                      Row(
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
                                        hintText: "Contact Number*",
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

                      //Email text field
                      CustomTextField(
                        data: Icons.email_rounded,
                        controller: emailController,
                        hintText: "Email*",
                        isObsecure: false,
                        keyboardType: TextInputType.emailAddress,
                        redBorder: _isEmailControllerInvalid,
                          noLeftMargin: false,
                          noRightMargin: false,
                          onChanged:(value) {
                            setState(() {
                              _isEmailControllerInvalid = false;
                            });
                          }
                      ),

                      //Show "Please enter your valid email format"
                      if (_isEmailControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please enter your valid email format",
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
                                  obscureText: _obscureText,
                                  cursorColor: const Color.fromARGB(255, 242, 198, 65),
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: const Icon(Icons.password_rounded, color: Color.fromARGB(255, 67, 83, 89)),
                                    suffixIcon: IconButton(
                                      icon: Icon(passwordController.text.isNotEmpty
                                          ? (_obscureText ? Icons.visibility : Icons.visibility_off)
                                          : null,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                    ),
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

                      //Show "Please provide a strong password"
                      if (_isPasswordControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please provide a strong password",
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
                                obscureText: _obscureText,
                                cursorColor: const Color.fromARGB(255, 242, 198, 65),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  prefixIcon: const Icon(Icons.password_rounded, color: Color.fromARGB(255, 67, 83, 89)),
                                  suffixIcon: IconButton(
                                    icon: Icon(confirmPasswordController.text.isNotEmpty
                                        ? (_obscureText ? Icons.visibility : Icons.visibility_off)
                                        : null,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    },
                                  ),
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
                          isButtonPressed ? "Sign Up" : "Sign Up",
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

              //Register Button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have an account?",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins",
                          color: Colors.black54,
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Login here",
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
              //Register Button
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Have an account?",
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Poppins",
                          color: Colors.black54,
                        ),
                      ),

                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen2()),
                        ),
                        child: const Text(
                          "Login here",
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
        )
    );
  }

  //Logic for password validation notifier
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

