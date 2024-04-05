import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'additionalRegistrationPage/personal_details_screen.dart';
import '../global/global.dart';
import 'package:image/image.dart' as img;
import 'auth_screen.dart';
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
  bool isButtonPressed = false;

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

  String riderImageUrl = "";
  String frontLicenseImageUrl = "";
  String backLicenseImageUrl = "";

  String riderImageType = 'riderImage';
  String fLicenseType = 'fLicense';
  String bLicenseType = 'bLicense';

  //Form validation
  Future<void> formValidation() async {
    isButtonPressed = !isButtonPressed;
    bool isPersonalDetailsCompleted = await _checkPersonalDetailsCompleted();
    bool isDriverLicenseCompleted = await _checkDriverLicenseCompleted();
    bool isDeclarationsCompleted = await _checkDeclarationsCompleted();
    bool isConsentsCompleted = await _checkConsentsCompleted();
    //check if image is empty
    if (!isPersonalDetailsCompleted &&
        !isDriverLicenseCompleted &&
        !isDeclarationsCompleted &&
        !isConsentsCompleted) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please complete the required sections.",
            );
          });
    }
    else {
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
  }

  //Authenticate the rider
  void authenticateRiderAndSignUp() async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? currentUserUid = sharedPreferences?.getString('currentUserUid');
    /*String? savedEmail = sharedPreferences!.getString('email');
    String? savedPassword = sharedPreferences!.getString('password');*/

    //If the rider is authenticated
    if (currentUserUid != null) {

      String riderProfilePath = riderProfile!.path;
      String frontLicensePath = frontLicense!.path;
      String backLicensePath = backLicense!.path;

      //The Rider profile image will upload to Firestorage
      riderImageUrl = await uploadImage(riderProfilePath, riderImageType);
      //The Front License image will upload to Firestorage
      frontLicenseImageUrl = await uploadImage(frontLicensePath, fLicenseType);
      //The Back License image will upload to Firestorage
      backLicenseImageUrl = await uploadImage(backLicensePath, bLicenseType);
      //await _uploadRiderImage();

      //save rider's credential to Firestore by calling the function
      await _saveDataToFirestore().then((value) {
        //Stop the loading screen
        Navigator.pop(context);

        //To prevent the user to go directly to home screen after restarted the app
        firebaseAuth.signOut();

        //Going back to Login page to login rider's credentials
        Route newRoute = MaterialPageRoute(builder: (c) => const AuthScreen());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  //Saves rider information to Firestore
  Future<User?> _saveDataToFirestore() async {
    sharedPreferences = await SharedPreferences.getInstance();
    // Personal Details Screen
    String? currentUserUid = sharedPreferences?.getString('currentUserUid');
    String? savedSecondaryContactNumber = sharedPreferences!.getString('secondaryContactNumber');
    String? savedNationality = sharedPreferences!.getString('nationality');
    // Driver License Screen
    String? savedLicenseNumber = sharedPreferences?.getString('licenseNumber');
    String? savedIssueDate = sharedPreferences?.getString('issueDate');
    String? savedAge = sharedPreferences?.getString('age');
    String? savedMotherMaidenName = sharedPreferences?.getString('motherMaiden');
    String? savedResidentialAddress = sharedPreferences?.getString('residentialAddress');
    String? savedIsResidentialPermanentAddress = sharedPreferences?.getString('isResidentialPermanentAddress');
    // Declaration Screen
    bool? savedIsRiderAcceptedDeclaration = sharedPreferences?.getBool('isRiderAcceptedDeclaration');

    // Accessing the Firestore collection 'riders' and setting the document with their unique currentUser's UID
    await FirebaseFirestore.instance.collection("riders").doc(currentUserUid).set({
      // Personal Details Screen
      "secondaryContactNumber": "+63$savedSecondaryContactNumber",
      "nationality": savedNationality?.toUpperCase(),
      "riderAvatarUrl": riderImageUrl,
      // Driver License Screen
      "licenseNumber": savedLicenseNumber,
      "licenseIssueDate": savedIssueDate,
      "frontLicenseUrl": frontLicenseImageUrl,
      "backLicenseUrl": backLicenseImageUrl,
      "age": savedAge,
      "motherMaidenName": savedMotherMaidenName?.toUpperCase(),
      "residentialAddress": savedResidentialAddress?.toUpperCase(),
      "isResidentialPermanentAddress": savedIsResidentialPermanentAddress,
      //Declaration Screen
      "declarationsAccepted": savedIsRiderAcceptedDeclaration,
      //
    }, SetOptions(merge: true));

    /*//Save rider's data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("photoUrl", riderImageUrl);*/

    //Clear all data saved from sharedPreferences
    await sharedPreferences?.clear();
    return null;
  }

  @override
  void initState() {
    super.initState();
    //Initialize the status of every sections
    _isPersonalDetailsCompleted = _checkPersonalDetailsCompleted();
    _isDriverLicenseCompleted = _checkDriverLicenseCompleted();
    _isDeclarationsCompleted = _checkDeclarationsCompleted();
    _isConsentsCompleted = _checkConsentsCompleted();
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
                Text(
                  "EatsEasy",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 67, 83, 89),
                  ),
                ),
                Text(
                  " register",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Poppins",
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 67, 83, 89),
                  ),
                ),
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
      body: ListView(
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
                      "Complete your application and start driving with EatsEasy!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 67, 83, 89),
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      "Provide the following information.",
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
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              'Personal',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Colors.black54,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          LinkTile(title: 'Personal Details', destination: '/personalDetails', isRequiredBasedOnCompletion : true, isCompleted: _isPersonalDetailsCompleted, updateCompletionStatus: () {
            setState(() {
              _isPersonalDetailsCompleted = _checkPersonalDetailsCompleted();
            });
          },),
          LinkTile(title: 'Driver License', destination: '/driversLicense', isRequiredBasedOnCompletion: true, isCompleted: _isDriverLicenseCompleted, updateCompletionStatus: () {
            setState(() {
              _isDriverLicenseCompleted = _checkDriverLicenseCompleted();
            });
          },),
          LinkTile(title: 'Declarations', destination: '/declarations', isRequiredBasedOnCompletion: true, isCompleted: _isDeclarationsCompleted, updateCompletionStatus: () {
            setState(() {
              _isDeclarationsCompleted = _checkDeclarationsCompleted();
            });
          },),
          LinkTile(title: 'Consents', destination: '/consents', isRequiredBasedOnCompletion: true, isCompleted: _isConsentsCompleted, updateCompletionStatus: () {
            setState(() {
              _isConsentsCompleted = _checkConsentsCompleted();
            });
          },),
          //LinkTile(title: 'EatsEasy Wallet', destination: '/eatsEasyWallet', isRequired: true, isCompleted: false),
          //LinkTile(title: 'TIN Number', destination: '/tinNumber', isOptional: true, isCompleted: false),
          //LinkTile(title: 'NBI Clearance', destination: '/nbiClearance', isOptional: true, isCompleted: false),
          //LinkTile(title: 'Emergency Contact', destination: '/emergencyContact', isOptional: true, isCompleted: false),
          //SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              'Transport',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Colors.black54,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          //LinkTile(title: 'Vehicle Info', destination: '/vehicleInfo', isRequired: true, isCompleted: false),
          //LinkTile(title: 'OR/CR', destination: '/orCr', isRequired: true, isCompleted: false),
          //LinkTile(title: 'Vehicle Documents', destination: '/vehicleDocs', isOptional: true, isCompleted: false),

          //spacing
          const SizedBox(
            height: 20,
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => sharedPreferences?.clear(),
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
    );
  }
}

class LinkTile extends StatelessWidget {
  final String title;
  final String destination;
  final bool isRequiredBasedOnCompletion ;
  final bool isOptional;
  final Future<bool> isCompleted;
  final VoidCallback? updateCompletionStatus;

  const LinkTile({
    Key? key,
    required this.title,
    required this.destination,
    required this.isRequiredBasedOnCompletion,
    this.isOptional = false,
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
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
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
                          color: Colors.black54,
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
                          color: Colors.orange,
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
                          color: Colors.black,
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
}