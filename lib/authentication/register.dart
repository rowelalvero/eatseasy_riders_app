import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import '../global/global.dart';
import '../provider/internet_provider.dart';
import '../provider/sign_in_provider.dart';
import '../utils/next_screen.dart';
import '../utils/snack_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool changesSaved = false;
  bool isButtonPressed = false;
  bool isContactNumberCompleted = true;
  bool _isUserTypingContactNumber = false;

  //form key instance
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Text fields controllers
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController middleInitialController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController otpCodeController = TextEditingController();

  final List<String> _cities = [
    "Alaminos (Pangasinan)", "Angeles", "Antipolo (Rizal)", "Bacolod", "Bacoor (Cavite)", "Bago (Negros Occidental)",
    "Baguio", "Bais (Negros Oriental)", "Balanga (Bataan)", "Batac (Ilocos Norte)", "Batangas City (Batangas)",
    "Bayawan (Negros Oriental)", "Baybay (Leyte)", "Bayugan (Agusan del Sur)", "Biñan (Laguna)", "Bislig (Surigao del Sur)",
    "Bogo (Cebu)", "Borongan (Eastern Samar)", "Butuan", "Cabadbaran (Agusan del Norte)", "Cabanatuan (Nueva Ecija)",
    "Cabuyao (Laguna)", "Cagayan de Oro", "Calamba (Laguna)", "Calapan (Oriental Mindoro)", "Calbayog (Samar)",
    "Caloocan", "Candon (Ilocos Sur)", "Cauayan (Isabela)", "Cavite City (Cavite)", "Cebu City", "Cotabato City",
    "Dagupan (Pangasinan)", "Danao (Cebu)", "Dapitan (Zamboanga del Norte)", "Dasmarinas (Cavite)", "Davao City",
    "Digos (Davao del Sur)", "Dipolog (Zamboanga del Norte)", "Dumaguete (Negros Oriental)", "El Salvador (Misamis Oriental)",
    "Escalante (Negros Occidental)", "Gapan (Nueva Ecija)", "General Santos", "General Trias (Cavite)", "Gingoog (Misamis Oriental)",
    "Guihulngan (Negros Oriental)", "Himamaylan (Negros Occidental)", "Iligan", "Iloilo City", "Iriga (Camarines Sur)",
    "Isabela City (Basilan)", "Kabankalan (Negros Occidental)", "Kidapawan (Cotabato)", "Koronadal (South Cotabato)",
    "La Carlota (Negros Occidental)", "Lamitan (Basilan)", "Laoag (Ilocos Norte)", "Lapu-Lapu", "Las Piñas",
    "Legazpi (Albay)", "Ligao (Albay)", "Lipa (Batangas)", "Lucena", "Mabalacat (Pampanga)", "Makati", "Malabon",
    "Malaybalay (Bukidnon)", "Malolos (Bulacan)", "Mandaluyong", "Mandaue", "Manila", "Marawi (Lanao del Sur)",
    "Marikina", "Masbate City (Masbate)", "Mati (Davao Oriental)", "Muntinlupa", "Muñoz (Nueva Ecija)",
    "Naga (Camarines Sur)", "Naga (Cebu)", "Navotas", "Olongapo", "Ormoc (Leyte)", "Oroquieta (Misamis Occidental)",
    "Ozamiz (Misamis Occidental)", "Pagadian (Zamboanga del Sur)", "Palayan (Nueva Ecija)", "Panabo (Davao del Norte)",
    "Parañaque", "Pasay", "Pasig", "Passi (Iloilo)", "Puerto Princesa", "Quezon City", "Roxas City (Capiz)",
    "Sagay (Negros Occidental)", "Samal (Davao del Norte)", "San Carlos (Negros Occidental)", "San Carlos (Pangasinan)",
    "San Fernando (La Union)", "San Fernando (Pampanga)", "San Jose (Nueva Ecija)", "San Jose del Monte (Bulacan)",
    "San Juan", "San Pablo (Laguna)", "San Pedro (Laguna)", "Santa Rosa (Laguna)", "Santiago", "Santo Tomas (Batangas)",
    "Silay (Negros Occidental)", "Sipalay (Negros Occidental)", "Sorsogon City (Sorsogon)", "Surigao City (Surigao del Norte)",
    "Tacloban", "Tacurong (Sultan Kudarat)", "Tagaytay (Cavite)", "Tagbilaran (Bohol)", "Taguig", "Tagum (Davao del Norte)",
    "Talisay (Cebu)", "Talisay (Negros Occidental)", "Tanauan (Batangas)", "Tandag (Surigao del Sur)", "Tangub (Misamis Occidental)",
    "Tanjay (Negros Oriental)", "Tarlac City (Tarlac)", "Tayabas (Quezon)", "Toledo (Cebu)", "Trece Martires (Cavite)",
    "Tuguegarao (Cagayan)", "Urdaneta (Pangasinan)", "Valencia (Bukidnon)", "Valenzuela", "Victorias (Negros Occidental)",
    "Vigan (Ilocos Sur)", "Zamboanga City"
  ];

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
  // String var for cities
  String? cityController;

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


  bool _isCityControllerInvalid = false;
  bool _isServiceTypeEmpty = false;
  bool _isFirstNameControllerInvalid = false;
  bool _isLastNameControllerInvalid = false;
  bool _isEmailControllerInvalid = false;
  bool _isContactNumberControllerInvalid = false;
  bool _isFormComplete = true;

  //Check if the required fields are all filled
  void _validateTextFields() {
    if (cityController == null) {
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
    if (emailController.text.isEmpty) {
     setState(() {
       _isEmailControllerInvalid = true;
       _isFormComplete = false;
     });
    }
    if (cityController != null &&
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
    RegExp(r'^([\w-]+\.)?[\w-]+@([\w-]+\.)+[\w-]{2,4}$');

    return emailRegex.hasMatch(email);
  }

  //Form validation
  Future<void> _formValidation() async {
    String email = emailController.text.trim();
    //Check if the required fields are all filled
    _validateTextFields();
    //Check if the form is completed
    if (_isFormComplete) {
      //Check if the email met the validation
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

          // Save user data to Prefs
          login(context, contactNumberController.text.trim());

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
              message: "Please fill up all required fields*",
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
              try {
                // Sign in automatically when verification is completed
                UserCredential userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);

                // After sign-in, check if user exists in Firestore
                await _checkUserInFirestore(context, userCredential.user!, sp);
              } catch (e) {
                Navigator.pop(context);
                openSnackbar(context, e.toString(), Colors.red);
              }
            },
            verificationFailed: (FirebaseAuthException e) {
              Navigator.pop(context);
              openSnackbar(context, e.message ?? "Verification failed", Colors.red);
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
                                      message: "Loading", isRegisterPage: false,
                                    );
                                  });
                              final code = otpCodeController.text.trim();
                              AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: code);
                              User user = (await FirebaseAuth.instance.signInWithCredential(authCredential)).user!;
                              // save the values
                              try {
                                // Manually sign in the user
                                UserCredential userCredential =
                                await FirebaseAuth.instance.signInWithCredential(authCredential);

                                sp.phoneNumberUser(
                                    user,
                                    cityController,
                                    serviceTypeController,
                                    lastNameController.text,
                                    firstNameController.text,
                                    suffixController,
                                    middleInitialController.text,
                                    contactNumberController.text,
                                    emailController.text
                                );

                                // After sign-in, Check if user exists in Firestore
                                await _checkUserInFirestore(
                                    context, userCredential.user!, sp);

                              } catch(e) {
                                Navigator.pop(context); // Close loading dialog
                                openSnackbar(context, e.toString(), Colors.red);
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

  // checking whether user exists,
  Future<void> _checkUserInFirestore(
      BuildContext context, User user, SignInProvider sp) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot userDoc =
      await _firestore.collection('riders').doc(user.uid).get();

      if (userDoc.exists) {
        // User exists in Firestore
        Navigator.pop(context);
        // user exists
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Account already exists.",
              );
            });

      } else {
        // user does not exist
        await sp.saveDataToFirestore().then((value) =>
            sp.saveDataToSharedPreferences().then(
                    (value) =>
                    sp.setSignIn().then((value) {
                      nextScreenReplace(context, '/registerScreen2');
                    })));
      }
    } catch (e) {
      Navigator.pop(context); // Close any loading or OTP dialogs
      openSnackbar(context, e.toString(), Colors.red);
    }
  }

  Future<bool> _onWillPop() async {
    if (!changesSaved) {
      final result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('Are you sure you want to discard changes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
      if (result == true) {
        sharedPreferences = await SharedPreferences.getInstance();

        setState(() {
          if (sharedPreferences!.containsKey('TINNumber')) {

          } else {

          }
        });
        return true; // Allow pop after changes are discarded
      }
      return false; // Prevent pop if changes are not discarded
    }
    return true; // Allow pop if changes are saved or no changes were made
  }

   _navigateToRegisterScreen2() {
    Navigator.pushNamed(context, '/registerScreen2');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max, // Change mainAxisSize to MainAxisSize.min
              children: [
                Container(
                  width: double.infinity,
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
                      const SizedBox(
                        height: 30,
                      ),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                /*IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_rounded), // Change this icon to your desired icon
                                  onPressed: () async {
                                    // Call _onWillPop to handle the back button press
                                    final bool canPop = await _onWillPop();
                                    if (canPop) {
                                      Navigator.of(context).pop();
                                    }
                                  },
                                ),*/
                                Text(
                                  "EatsEasy",
                                  style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: "Poppins", fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "register",
                                  style: TextStyle(color: Colors.white, fontSize: 23, fontFamily: "Poppins", fontStyle: FontStyle.italic),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),

                      FadeInUp(
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(60),
                                    topRight: Radius.circular(60))),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child:  Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("Be part of EatsEasy Riders!",
                                                style: TextStyle(
                                                    fontSize: 30,
                                                    fontFamily: "Poppins",
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600
                                                )),
                                            const SizedBox(height: 10),
                                            const Text(
                                              "Fill-out the required details and start driving with EatsEasy!",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                            const Text(
                                              "Please provide the following information.",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "View the requirements",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: "Poppins",
                                                    color: Colors.black54,
                                                  ),
                                                ),

                                                TextButton(
                                                  onPressed: () => _showPreviewDialog(),
                                                  child: const Text(
                                                    "here!",
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
                                      ),
                                    ],
                                  ),
                                  //Text Fields
                                  Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          //City text field
                                          Container(
                                            padding: const EdgeInsets.all(4),
                                            margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0E3E7),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _isCityControllerInvalid ? Colors.red : Colors.transparent,
                                              ),
                                            ),
                                            child: DropdownButtonFormField2<String>(
                                              isExpanded: true,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                              ),
                                              hint: const Text(
                                                'Select your City',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              items: _cities.map((item) => DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ))
                                                  .toList(),
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Select your city';
                                                }
                                                return null;
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  changesSaved = false;
                                                  cityController = value.toString();
                                                  _isCityControllerInvalid = false;
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
                                                  changesSaved = false;
                                                  _isServiceTypeEmpty = false;
                                                  serviceTypeController = value?['text']; // Extracting text from the selected item
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
                                                flex: 6,
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
                                                        changesSaved = false;
                                                        _isLastNameControllerInvalid = false;
                                                      });
                                                    }
                                                ),
                                              ),

                                              //Suffix text field
                                              Expanded(
                                                flex: 4,
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
                                                    onChanged: (value) {
                                                      setState(() {
                                                        changesSaved = false;
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
                                                        changesSaved = false;
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
                                                  onChanged: (value) {
                                                    changesSaved = false;
                                                  },
                                                ),
                                              ),
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
                                                              changesSaved = false;
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

                                                  changesSaved = false;
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

                                          /*//Password text field
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
                                                        changesSaved = false;
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
                                                          color: Colors.black,
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
                                                          changesSaved = false;
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
                                            ),*/
                                        ],
                                      )
                                  ),

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
                                            onPressed: isButtonPressed
                                                ? null
                                                : changesSaved
                                                ? _navigateToRegisterScreen2()
                                                : () => _formValidation(),
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
                                      TextButton(
                                        onPressed: () => Navigator.pushNamed(context, '/registerScreen2'),
                                        child: const Text(
                                          "Navigate to RegistrationScreen2();",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )
    );
  }


  /*//Logic for password validation notifier
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
  }*/

  void _showPreviewDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Requirements'),
        content: const SizedBox(
          height: 80, // Set your desired height here
          child: SingleChildScrollView(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "• Drivers License",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "• OR/CR",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "• NBI Clearance",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "• TIN Number",
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                Navigator.of(context).pop();
              });
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}



