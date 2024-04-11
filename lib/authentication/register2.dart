import 'package:animate_do/animate_do.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/error_dialog.dart';
import '../widgets/loading_dialog.dart';
import 'additionalRegistrationPage/personal_details_screen.dart';
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

  String riderImageUrl = "";
  String frontLicenseImageUrl = "";
  String backLicenseImageUrl = "";
  String nbiClearanceImageUrl = "";
  String orImageUrl = "";
  String crImageUrl = "";
  String vehicleDocUrl = "";

  String riderImageType = 'riderImage';
  String fLicenseType = 'fLicense';
  String bLicenseType = 'bLicense';
  String nbiClearanceType = 'nbiClearance';
  String orType = 'officialReceipt';
  String crType = 'certOfReg';
  String vehicleDocType = '';

  String riderProfilePath = '';
  String frontLicensePath = '';
  String backLicensePath = '';
  String nbiClearancePath = '';
  String orPath = '';
  String crPath = '';
  String vehicleDocPath = '';

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
    User? currentUser;
    String? savedEmail = sharedPreferences!.getString('email');
    String? savedPassword = sharedPreferences!.getString('password');

    //Create or authenticate rider email and password to Firestore
    await firebaseAuth.createUserWithEmailAndPassword(
      email: savedEmail!,
      password: savedPassword!,
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

    //If the rider is authenticated
    if (currentUser != null) {
      setState(() {
        vehicleDocType =
        sharedPreferences!.getString('documentTypeItemDropdown')!;
      });

      riderProfilePath = riderProfile!.path;
      frontLicensePath = frontLicense!.path;
      backLicensePath = backLicense!.path;
      if (nbiImage != null) {
        nbiClearancePath = nbiImage!.path;
      }
      orPath = orImage!.path;
      crPath = crImage!.path;
      if (vehicleDoc != null) {
        vehicleDocPath = vehicleDoc!.path;
      }

      //The Rider profile image will upload to Firestorage
      riderImageUrl = await uploadImage(riderProfilePath, riderImageType);
      //The Front License image will upload to Firestorage
      frontLicenseImageUrl = await uploadImage(frontLicensePath, fLicenseType);
      //The Back License image will upload to Firestorage
      backLicenseImageUrl = await uploadImage(backLicensePath, bLicenseType);
      if (nbiImage != null) {
        //The NBI Clearance image will upload to Firestorage
        nbiClearanceImageUrl =
        await uploadImage(nbiClearancePath, nbiClearanceType);
      }
      //The OR image will upload to Firestorage
      orImageUrl = await uploadImage(orPath, orType);
      //The CR image will upload to Firestorage
      crImageUrl = await uploadImage(crPath, crType);
      if (vehicleDoc != null) {
        //The Vehicle Document Type will upload to Firestorage
        vehicleDocUrl = await uploadImage(vehicleDocPath, vehicleDocType!);
      }

      //save rider's credential to Firestore by calling the function
      await _saveDataToFirestore(currentUser!).then((value) {
        //Stop the loading screen
        Navigator.pop(context);

        //To prevent the user to go directly to home screen after restarted the app
        firebaseAuth.signOut();

        //Going back to Login page to login rider's credentials
        Navigator.pushNamed(context, '/authScreen');
      });
    }
  }

  //Saves rider information to Firestore
  Future<void> _saveDataToFirestore(User currentUser) async {
    sharedPreferences = await SharedPreferences.getInstance();
    String? cityAddress = sharedPreferences?.getString('cityAddress');
    String? serviceType = sharedPreferences?.getString('serviceType');
    String? lastName = sharedPreferences?.getString('lastName');
    String? suffix = sharedPreferences?.getString('suffix');
    String? firstName = sharedPreferences?.getString('firstName');
    String? middleInit = sharedPreferences?.getString('M.I.');
    String? contactNumber = sharedPreferences?.getString('contactNumber');
    String? password = sharedPreferences?.getString('password');
    // Personal Details Screen
    String? savedSecondaryContactNumber = sharedPreferences!.getString(
        'secondaryContactNumber');
    String? savedNationality = sharedPreferences!.getString('nationality');
    // Driver License Screen
    String? savedLicenseNumber = sharedPreferences?.getString('licenseNumber');
    String? savedIssueDate = sharedPreferences?.getString('issueDate');
    String? savedAge = sharedPreferences?.getString('age');
    String? savedMotherMaidenName = sharedPreferences?.getString(
        'motherMaiden');
    String? savedResidentialAddress = sharedPreferences?.getString(
        'residentialAddress');
    String? savedIsResidentialPermanentAddress = sharedPreferences?.getString(
        'isResidentialPermanentAddress');
    // Declaration Screen
    bool? savedIsRiderAcceptedDeclaration = sharedPreferences?.getBool(
        'isRiderAcceptedDeclaration');
    // Consent Screen
    bool? savedIsRiderAcceptedConsent = sharedPreferences?.getBool(
        'isRiderAcceptedConsent');
    bool? savedPromotionsSMS = sharedPreferences?.getBool(
        'offersConsentBox1') ?? false;
    bool? savedPromotionsCall = sharedPreferences?.getBool(
        'offersConsentBox2') ?? false;
    bool? savedPromotionsEmail = sharedPreferences?.getBool(
        'offersConsentBox3') ?? false;
    bool? savedPromotionsPushNotif = sharedPreferences?.getBool(
        'offersConsentBox4') ?? false;
    bool? savedOpportunitiesSMS = sharedPreferences?.getBool(
        'additionalConsentBox1') ?? false;
    bool? savedOpportunitiesCall = sharedPreferences?.getBool(
        'additionalConsentBox2') ?? false;
    bool? savedOpportunitiesEmail = sharedPreferences?.getBool(
        'additionalConsentBox3') ?? false;
    bool? savedOpportunitiesPushNotif = sharedPreferences?.getBool(
        'additionalConsentBox4') ?? false;
    // EatsEasyPay Wallet Screen
    bool? savedIsRiderAcceptedEasyPayWallet = sharedPreferences?.getBool(
        'isRiderAcceptedDeclaration');
    // TIN Number
    String? savedTinNumber = sharedPreferences?.getString('TINNumber');
    // Emergency Contact Screen
    String? savedContactName = sharedPreferences?.getString(
        'emergencyContactName');
    String? savedRelationship = sharedPreferences?.getString('relationship');
    String? savedEmergencyNumber = sharedPreferences?.getString(
        'emergencyNumber');
    String? savedEmergencyAddress = sharedPreferences?.getString(
        'emergencyAddress');
    // Vehicle Info Screen
    String? savedPlateNumber = sharedPreferences?.getString('plateNumber') ??
        '';

    try {
      // Accessing the Firestore collection 'riders' and setting the document with their unique currentUser's UID
      await FirebaseFirestore.instance.collection("riders")
          .doc(currentUser.uid)
          .set({
        "riderUID": currentUser.uid,
        // Storing user's UID
        "riderEmail": currentUser.email,
        // Storing user's email
        "password": password,
        // Save password directly
        "cityAddress": cityAddress?.toUpperCase(),
        // Storing city address after trimming leading/trailing whitespace
        "lastName": lastName,
        // Storing last name after trimming leading/trailing whitespace
        "firstName": firstName,
        // Storing first name after trimming leading/trailing whitespace
        "M.I.": middleInit,
        // Storing middle initial after trimming leading/trailing whitespace
        "suffix": suffix,
        // Storing suffix after trimming leading/trailing whitespace
        "contactNumber": "+63$contactNumber",
        // Storing contact number after trimming leading/trailing whitespace
        "serviceType": serviceType,
        //Storing the service type of the rider
        "status": "pending",
        // Setting the status to 'pending'
        "earnings": 0.0,
        // Initializing earnings as 0.0
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
        // Declaration Screen
        "declarationsAccepted": savedIsRiderAcceptedDeclaration,
        // Consent Screen
        "consentAccepted": savedIsRiderAcceptedConsent,
        "promotionsSMS": savedPromotionsSMS,
        "promotionsCall": savedPromotionsCall,
        "promotionsEmail": savedPromotionsEmail,
        "promotionsPushNotif": savedPromotionsPushNotif,
        "opportunitiesSMS": savedOpportunitiesSMS,
        "opportunitiesCall": savedOpportunitiesCall,
        "opportunitiesEmail": savedOpportunitiesEmail,
        "opportunitiesPushNotif": savedOpportunitiesPushNotif,
        // EatsEasyPay Wallet Screen
        "eatsEasyPayWalletAccepted": savedIsRiderAcceptedEasyPayWallet,
        // TIN Number
        "tinNumber": savedTinNumber,
        // NBI Clearance Image
        "nbiClearance": nbiClearanceImageUrl,
        // Emergency Contact Screen
        "emergencyContactName": savedContactName?.toUpperCase(),
        "emergencyContactRelationship": savedRelationship?.toUpperCase(),
        "emergencyNumber": "63$savedEmergencyNumber",
        "emergencyAddress": savedEmergencyAddress?.toUpperCase(),
        // Vehicle Info Screen
        "plateNumber": savedPlateNumber,
        // OR/CR Screen
        "OR": orImageUrl,
        "CR": crImageUrl,
        // Vehicle Documents Screen
        "vehicleDocument": vehicleDocUrl,
      });

      //Clear all data saved from sharedPreferences
      await sharedPreferences?.clear();
      isButtonPressed = !isButtonPressed;

      // Save vendor's data locally
      sharedPreferences = await SharedPreferences.getInstance();
      await sharedPreferences?.setString("uid", currentUser.uid);
      await sharedPreferences?.setString("email", currentUser.email.toString());
      await sharedPreferences?.setString("firstName", firstName!);
      await sharedPreferences?.setString("riderAvatarUrl", riderImageUrl);
      await sharedPreferences?.setString("contactNumber", "+63$contactNumber");
      await sharedPreferences?.setString(
          "residentialAddress", savedResidentialAddress!);
    } catch (e) {
      print("Error saving data to Firestore: $e");
      throw e; // Propagate the error
    }
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
                          opacity: 0.3
                      ),
                      gradient: LinearGradient(
                          begin: Alignment.topCenter, colors: [
                        Colors.orange.shade900,
                        Colors.orange.shade800,
                        Colors.orange.shade400
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