import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../provider/internet_provider.dart';
import '../provider/sign_in_provider.dart';
import '../utils/next_screen.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import '../global/global.dart';
import 'imageGetters/rider_profile.dart';
import 'imageUpload/image_upload.dart';

class RegisterScreen2 extends StatefulWidget {
  const RegisterScreen2({Key? key}) : super(key: key);

  @override
  _RegisterScreen2State createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
  late Future<bool> _isPersonalDetailsCompleted;
  late Future<bool> _isDriverLicenseCompleted;
  late Future<bool> _isDeclarationsCompleted;
  late Future<bool> _isConsentsCompleted;
  late Future<bool> _isEatsEasyPayWalletCompleted;
  late Future<bool> _isTINNumberCompleted;
  late Future<bool> _isNBIClearanceCompleted;
  late Future<bool> _isEmergencyContactCompleted;
  late Future<bool> _isVehicleInfoCompleted;
  late Future<bool> _isORCRCompleted;
  late Future<bool> _isVehicleDocumentsCompleted;

  bool isButtonPressed = false;
  bool changesSaved = false;
  String? currentUserUid;

  Future<bool> _checkPersonalDetailsCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('personalDetailsCompleted') ?? false;
  }

  Future<bool> _checkDriverLicenseCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('driverLicenseCompleted') ?? false;
  }

  Future<bool> _checkDeclarationsCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('declarationsCompleted') ?? false;
  }

  Future<bool> _checkConsentsCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('consentsCompleted') ?? false;
  }

  Future<bool> _checkEatsEasyPayWalletCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('eatsEasyPayWalletCompleted') ?? false;
  }

  Future<bool> _checkTINNumberCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('TINNumberCompleted') ?? false;
  }

  Future<bool> _checkNBIClearanceCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('NBIClearanceCompleted') ?? false;
  }

  Future<bool> _checkEmergencyContactCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('emergencyContactCompleted') ?? false;
  }

  Future<bool> _checkVehicleInfoCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('vehicleInfoCompleted') ?? false;
  }

  Future<bool> _checkORCRCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('orCrCompleted') ?? false;
  }

  Future<bool> _checkVehicleDocumentsCompleted() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getBool('vehicleDocumentsCompleted') ?? false;
  }

  //Form validation
  Future<void> formValidation() async {
    bool isPersonalDetailsCompleted = await _checkPersonalDetailsCompleted();
    bool isDriverLicenseCompleted = await _checkDriverLicenseCompleted();
    bool isDeclarationsCompleted = await _checkDeclarationsCompleted();
    bool isConsentsCompleted = await _checkConsentsCompleted();
    bool isEatsEasyPayWalletCompleted = await _checkEatsEasyPayWalletCompleted();
    bool isVehicleInfoCompleted = await _checkVehicleInfoCompleted();
    bool isORCRCompleted = await _checkORCRCompleted();

    if (isPersonalDetailsCompleted &&
        isDriverLicenseCompleted &&
        isDeclarationsCompleted &&
        isConsentsCompleted &&
        isEatsEasyPayWalletCompleted &&
        isVehicleInfoCompleted &&
        isORCRCompleted) {
      showDialog(
          context: context,
          builder: (c) {
            return const LoadingDialog(
              message: "Submitting", isRegisterPage: false,
            );
          });
      //Authenticate the rider
      authenticateRiderAndSignUp();
    }
    else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please complete the required sections.",
            );
          });
    }
  }

  //Authenticate the rider
  void authenticateRiderAndSignUp() async {
    sharedPreferences = await SharedPreferences.getInstance();

    final sp = context.read<SignInProvider>();
    final ip = context.read<InternetProvider>();
    await ip.checkInternetConnection();

    //Create or authenticate rider email and password to Firestore
    sp.checkUserExists().then((value) async {
      if (value == true) {
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
        await sp.saveRegisterDataToFirestore().then((value) =>
            sp.saveDataToSharedPreferences().then(
                    (value) =>
                    sp.setSignIn().then((value) {
                      sp.userSignOut();
                      nextScreenReplace(context, '/logInScreen');
                    })));
      }
    });
  }

  Future<bool> _onWillPop() async {
    if (!changesSaved) {
      final result = await showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(
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

        if (sharedPreferences!.containsKey('currentUserUid')) {
          try {
            User? user = FirebaseAuth.instance.currentUser;
            //Clear all data saved from sharedPreferences
            await sharedPreferences?.clear();
            await user?.delete();
            print("User account deleted successfully.");
          } catch (error) {
            print("Failed to delete user account: $error");
          }

          await sharedPreferences?.clear();
        } else {

        }
        return true; // Allow pop after changes are discarded
      }
      return false; // Prevent pop if changes are not discarded
    }
    return true; // Allow pop if changes are saved or no changes were made
  }

  @override
  void initState() {
    super.initState();
    //Initialize the status of every sections
    _isPersonalDetailsCompleted = _checkPersonalDetailsCompleted();
    _isDriverLicenseCompleted = _checkDriverLicenseCompleted();
    _isDeclarationsCompleted = _checkDeclarationsCompleted();
    _isConsentsCompleted = _checkConsentsCompleted();
    _isEatsEasyPayWalletCompleted = _checkEatsEasyPayWalletCompleted();
    _isTINNumberCompleted = _checkTINNumberCompleted();
    _isNBIClearanceCompleted = _checkNBIClearanceCompleted();
    _isEmergencyContactCompleted = _checkEmergencyContactCompleted();
    _isVehicleInfoCompleted = _checkVehicleInfoCompleted();
    _isORCRCompleted = _checkORCRCompleted();
    _isVehicleDocumentsCompleted = _checkVehicleDocumentsCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: WillPopScope(
          onWillPop: _onWillPop,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              // Change mainAxisSize to MainAxisSize.min
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      image: const DecorationImage(
                          image: AssetImage('images/background.png'), // Replace with your desired image
                          fit: BoxFit.cover,
                          opacity: 0.1
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter, colors: [
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
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 45,
                                      fontFamily: "Poppins",
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "register",
                                  style: TextStyle(color: Colors.white,
                                      fontSize: 23,
                                      fontFamily: "Poppins",
                                      fontStyle: FontStyle.italic),
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
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  const Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 20),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              "Complete your application and start driving with EatsEasy!",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                            Text(
                                              "Provide the following information.",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20, bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Personal",
                                              style: TextStyle(color: Colors.black,
                                                  fontSize: 30,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  LinkTile(
                                    title: 'Personal Details',
                                    destination: '/personalDetails',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isPersonalDetailsCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isPersonalDetailsCompleted =
                                            _checkPersonalDetailsCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'Driver License',
                                    destination: '/driversLicense',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isDriverLicenseCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isDriverLicenseCompleted =
                                            _checkDriverLicenseCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'Declarations',
                                    destination: '/declarations',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isDeclarationsCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isDeclarationsCompleted =
                                            _checkDeclarationsCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'Consents',
                                    destination: '/consents',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isConsentsCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isConsentsCompleted =
                                            _checkConsentsCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'EatsEasyPay Wallet',
                                    destination: '/eatsEasyPayWallet',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isEatsEasyPayWalletCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isEatsEasyPayWalletCompleted =
                                            _checkEatsEasyPayWalletCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'TIN Number',
                                    destination: '/tinNumber',
                                    isOptionalBasedOnCompletion: true,
                                    isRequiredBasedOnCompletion: false,
                                    isCompleted: _isTINNumberCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isTINNumberCompleted =
                                            _checkTINNumberCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'NBI Clearance',
                                    destination: '/nbiClearance',
                                    isOptionalBasedOnCompletion: true,
                                    isRequiredBasedOnCompletion: false,
                                    isCompleted: _isNBIClearanceCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isNBIClearanceCompleted =
                                            _checkNBIClearanceCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'Emergency Contact',
                                    destination: '/emergencyContact',
                                    isOptionalBasedOnCompletion: true,
                                    isRequiredBasedOnCompletion: false,
                                    isCompleted: _isEmergencyContactCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isEmergencyContactCompleted =
                                            _checkEmergencyContactCompleted();
                                      });
                                    },),
                                  const SizedBox(height: 10),
                                  const Padding(
                                    padding: EdgeInsets.only(left: 20, bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Transport",
                                              style: TextStyle(color: Colors.black,
                                                  fontSize: 30,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w700),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  LinkTile(
                                    title: 'Vehicle Info',
                                    destination: '/vehicleInfo',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isVehicleInfoCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isVehicleInfoCompleted =
                                            _checkVehicleInfoCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'OR/CR',
                                    destination: '/orCr',
                                    isOptionalBasedOnCompletion: false,
                                    isRequiredBasedOnCompletion: true,
                                    isCompleted: _isORCRCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isORCRCompleted =
                                            _checkORCRCompleted();
                                      });
                                    },),
                                  LinkTile(
                                    title: 'Vehicle Documents',
                                    destination: '/vehicleDocs',
                                    isOptionalBasedOnCompletion: true,
                                    isRequiredBasedOnCompletion: false,
                                    isCompleted: _isVehicleDocumentsCompleted,
                                    updateCompletionStatus: () {
                                      setState(() {
                                        _isVehicleDocumentsCompleted =
                                            _checkVehicleDocumentsCompleted();
                                      });
                                    },),

                                  //spacing
                                  const SizedBox(
                                    height: 20,
                                  ),

                                  //submit button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: isButtonPressed
                                                ? null
                                                : () => formValidation(),
                                            // Register button styling
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: isButtonPressed
                                                  ? Colors.grey
                                                  : const Color.fromARGB(255, 242, 198, 65),
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0),
                                              ),
                                              elevation: 4,
                                              // Elevation for the shadow
                                              shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                            ),
                                            child: Text(
                                              isButtonPressed
                                                  ? "Submitted"
                                                  : "Submit",
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .center,
                                    children: [
                                      TextButton(
                                        onPressed: () =>
                                            sharedPreferences?.clear(),
                                        child: const Text(
                                          "RegistrationScreen2() Reset",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  //spacing
                                  const SizedBox(
                                    height: 20,
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
        )
    );
  }
}

class LinkTile extends StatelessWidget {
  final String title;
  final String destination;
  final bool isRequiredBasedOnCompletion ;
  final bool isOptionalBasedOnCompletion;
  final Future<bool> isCompleted;
  final VoidCallback? updateCompletionStatus;

  const LinkTile({
    Key? key,
    required this.title,
    required this.destination,
    required this.isRequiredBasedOnCompletion,
    required this.isOptionalBasedOnCompletion,
    required this.isCompleted,
    this.updateCompletionStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isCompleted,
      builder: (context, snapshot) {
        bool completed = snapshot.data ?? false;
        bool isRequired = isRequiredBasedOnCompletion && !completed;
        bool isOptional  = isOptionalBasedOnCompletion && !completed;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Card(
            color: Colors.white,
            elevation: 3,
            // Elevation for the shadow
            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, destination).then((_) {
                  updateCompletionStatus?.call(); // Call the updateCompletionStatus callback after navigating back
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontFamily: "Poppins",
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8.0),
                      const Text(
                        'Required',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: "Poppins",
                          color: Colors.orangeAccent,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    if (isOptional) ...[
                      const SizedBox(width: 8.0),
                      const Text(
                        'Optional',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: "Poppins",
                          color: Colors.black45,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    if (completed) ...[
                      const SizedBox(width: 8.0),
                      const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontFamily: "Poppins",
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color.fromARGB(255, 67, 83, 89)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/*
Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PersonalDetailsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}*/
