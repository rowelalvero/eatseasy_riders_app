import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eatseasy_riders_app/global/global.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../authentication/imageFilePaths/rider_profile.dart';
import '../authentication/imageUpload/image_upload.dart';

class SignInProvider extends ChangeNotifier {
  // instance of firebaseauth, facebook and google
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  bool _isSignedIn = false;
  bool get isSignedIn => _isSignedIn;

  //hasError, errorCode, provider,uid, email, name, imageUrl
  bool _hasError = false;
  bool get hasError => _hasError;

  String? _errorCode;
  String? get errorCode => _errorCode;

  String? _provider;
  String? get provider => _provider;

  String? _riderAvatar;
  String? get riderAvatar => _riderAvatar;

  String? _imageUrl;
  String? get imageUrl => _imageUrl;

  String? _uid;
  String? get uid => _uid;

  String? _city;
  String? get city => _city;

  String? _serviceType;
  String? get serviceType => _serviceType;

  String? _firstName;
  String? get firstName => _firstName;

  String? _lastName;
  String? get lastName => _lastName;

  String? _suffix;
  String? get suffix => _suffix;

  String? _middleInitial;
  String? get middleInitial => _middleInitial;

  String? _contactNum;
  String? get contactNum => _contactNum;

  String? _email;
  String? get email => _email;


  SignInProvider() {
    checkSignInUser();
  }

  Future checkSignInUser() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("signed_in") ?? false;
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    s.setBool("signed_in", true);
    _isSignedIn = true;
    notifyListeners();
  }

  // ENTRY FOR CLOUDFIRESTORE
  Future getUserDataFromFirestore(uid) async {
    await FirebaseFirestore.instance
        .collection("riders")
        .doc(uid)
        .get()
        .then((DocumentSnapshot snapshot) => {
              _riderAvatar = snapshot['riderAvatarUrl'],
              _uid = snapshot['uid'],
              _serviceType = snapshot['serviceType'],
              _city = snapshot['city'],
              _firstName = snapshot['firstName'],
              _lastName = snapshot['lastName'],
              _suffix = snapshot['suffix'],
              _middleInitial = snapshot['middleIn'],
              _contactNum = snapshot['contactNumber'],
              _email = snapshot['email'],
              _imageUrl = snapshot['image_url'],
              _provider = snapshot['provider'],

            });
  }

  Future saveDataToFirestore() async {
    // Accessing the Firestore collection 'riders' and setting the document with their unique currentUser's UID
    await FirebaseFirestore.instance.collection("riders").doc(uid).set({
      "image_url": _imageUrl,
      "provider": _provider,

      "riderAvatarUrl": _riderAvatar,
      "uid": _uid, // Storing user's UID
      "email": _email, // Storing user's email
      "city": _city, // Storing city address after trimming leading/trailing whitespace
      "lastName": _lastName?.trim(), // Storing last name after trimming leading/trailing whitespace
      "firstName": _firstName?.trim(), // Storing first name after trimming leading/trailing whitespace
      "middleIn": _middleInitial?.trim(), // Storing middle initial after trimming leading/trailing whitespace
      "suffix": _suffix, // Storing suffix after trimming leading/trailing whitespace
      "contactNumber": "+63${_contactNum?.trim()}", // Storing contact number after trimming leading/trailing whitespace
      "serviceType": _serviceType, //Storing the service type of the rider
      "status": "pending", // Setting the status to 'pending'
      "earnings": 0.0, // Initializing earnings as 0.0
    });
    notifyListeners();
  }

  Future<void> saveRegisterDataToFirestore() async {
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

    vehicleDocType = sharedPreferences!.getString('documentTypeItemDropdown')!;

    riderProfilePath = riderProfile!.path;
    frontLicensePath = frontLicense!.path;
    backLicensePath = backLicense!.path;
    if (nbiImage != null) { nbiClearancePath = nbiImage!.path; }
    orPath = orImage!.path;
    crPath = crImage!.path;
    if (vehicleDoc != null) { vehicleDocPath = vehicleDoc!.path;}

    //The Rider profile image will upload to Firestorage
    riderImageUrl = await uploadImage(riderProfilePath, riderImageType);
    riderProfile = null;

    //The Front License image will upload to Firestorage
    frontLicenseImageUrl = await uploadImage(frontLicensePath, fLicenseType);
    frontLicense = null;
    frontLicenseToBeCropped = null;

    //The Back License image will upload to Firestorage
    backLicenseImageUrl = await uploadImage(backLicensePath, bLicenseType);
    backLicense = null;
    backLicenseToBeCropped = null;

    // The NBI image will upload to Firestorage
    if (nbiImage != null) {
      nbiClearanceImageUrl = await uploadImage(nbiClearancePath, nbiClearanceType);
      nbiImage = null;
    }

    //The OR image will upload to Firestorage
    orImageUrl = await uploadImage(orPath, orType);
    orImage = null;

    //The CR image will upload to Firestorage
    crImageUrl = await uploadImage(crPath, crType);
    crImage = null;

    //The Vehicle Document Type will upload to Firestorage
    if (vehicleDoc != null) {
      vehicleDocUrl = await uploadImage(vehicleDocPath, vehicleDocType);
      vehicleDoc = null;
    }

    // Personal Details Screen
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
    // Consent Screen
    bool? savedIsRiderAcceptedConsent = sharedPreferences?.getBool('isRiderAcceptedConsent');
    bool? savedPromotionsSMS = sharedPreferences?.getBool('offersConsentBox1') ?? false;
    bool? savedPromotionsCall = sharedPreferences?.getBool('offersConsentBox2') ?? false;
    bool? savedPromotionsEmail = sharedPreferences?.getBool('offersConsentBox3') ?? false;
    bool? savedPromotionsPushNotif = sharedPreferences?.getBool('offersConsentBox4') ?? false;
    bool? savedOpportunitiesSMS = sharedPreferences?.getBool('additionalConsentBox1') ?? false;
    bool? savedOpportunitiesCall = sharedPreferences?.getBool('additionalConsentBox2') ?? false;
    bool? savedOpportunitiesEmail = sharedPreferences?.getBool('additionalConsentBox3') ?? false;
    bool? savedOpportunitiesPushNotif = sharedPreferences?.getBool('additionalConsentBox4') ?? false;
    // EatsEasyPay Wallet Screen
    bool? savedIsRiderAcceptedEasyPayWallet = sharedPreferences?.getBool('isRiderAcceptedDeclaration');
    // TIN Number
    String? savedTinNumber = sharedPreferences?.getString('TINNumber');
    // Emergency Contact Screen
    String? savedContactName = sharedPreferences?.getString('emergencyContactName');
    String? savedRelationship = sharedPreferences?.getString('relationship');
    String? savedEmergencyNumber = sharedPreferences?.getString('emergencyNumber');
    String? savedEmergencyAddress = sharedPreferences?.getString('emergencyAddress');
    // Vehicle Info Screen
    String? savedPlateNumber = sharedPreferences?.getString('plateNumber') ?? '';

    // Accessing the Firestore collection 'riders' and setting the document with their unique currentUser's UID
    await FirebaseFirestore.instance.collection("riders").doc(uid).set({
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
      "emergencyNumber": "+63$savedEmergencyNumber",
      "emergencyAddress": savedEmergencyAddress?.toUpperCase(),
      // Vehicle Info Screen
      "plateNumber": savedPlateNumber,
      // OR/CR Screen
      "OR": orImageUrl,
      "CR": crImageUrl,
      // Vehicle Documents Screen
      "vehicleDocument": vehicleDocUrl,
    }, SetOptions(merge: true));

    // Save vendor's data locally
    await sharedPreferences?.setString("riderAvatarUrl", riderImageUrl);
    await sharedPreferences?.setString("residentialAddress", savedResidentialAddress!);

    _riderAvatar = riderImageUrl;
  }

  Future saveDataToSharedPreferences() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    await s.setString('image_url', _imageUrl!);
    await s.setString('provider', _provider!);

    if (_riderAvatar != null) {
      await s.setString("riderAvatar", _riderAvatar!);
    }
    await s.setString("uid", _uid!);
    await s.setString("city", _city!);
    await s.setString("serviceType", _serviceType!);
    await s.setString("firstName", _firstName!);
    await s.setString("lastName", _lastName!);
    await s.setString("suffix", _suffix!);
    await s.setString("middleInitial", _middleInitial!);
    await s.setString("contactNumber", "+63$_contactNum");
    await s.setString('email', _email!);
    notifyListeners();
  }

  Future getDataFromSharedPreferences() async {
    SharedPreferences s = await SharedPreferences.getInstance();
    _imageUrl = s.getString('image_url');
    _provider = s.getString('provider');

    _riderAvatar = s.getString('riderAvatar');
    _uid = s.getString('uid');
    _city = s.getString('city');
    _serviceType = s.getString('serviceType');
    _firstName = s.getString('firstName');
    _lastName = s.getString('lastName');
    _suffix = s.getString('suffix');
    _middleInitial = s.getString('middleInitial');
    _contactNum = s.getString('contactNumber');
    _email = s.getString('email');
    notifyListeners();
  }

  // check if user is approved
  Future<bool> checkUserApproved() async{
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(_uid).get();
    if ((snap.data() as Map<String, dynamic>)["status"] == "approved") {
      print("APPROVED USER");
      return true;
    } else {
      print("BANNED USER");
      return false;
    }
  }

  // checkUser exists or not in cloudfirestore
  Future<bool> checkUserExists() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('riders').doc(_uid).get();
    if (snap.exists) {
      print("EXISTING USER");
      return true;
    } else {
      print("NEW USER");
      return false;
    }
  }

  // signout
  Future userSignOut() async {
    firebaseAuth.signOut;

    _isSignedIn = false;
    notifyListeners();
    // clear all storage information
    clearStoredData();
  }

  Future clearStoredData() async {
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences?.clear();
  }

  void phoneNumberUser(User user, city, service, lastname, firstname, suffix, middleIn, contactNo, email) {
    _city = city;
    _serviceType = service;
    _firstName = firstname;
    _lastName = lastname;
    _suffix = suffix;
    _middleInitial = middleIn;
    _email = email;
    _contactNum = contactNo;
    _uid = user.phoneNumber;
    if (_riderAvatar == null) {
      _imageUrl =
      "https://winaero.com/blog/wp-content/uploads/2017/12/User-icon-256-blue.png";
    }
    _provider = "PHONE";
    notifyListeners();
  }

  void phoneNumberLogin(User user) {
    _uid = user.phoneNumber;
  }
}
