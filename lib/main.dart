
import 'package:eatseasy_riders_app/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'authentication/additionalRegistrationPage/personal_details_screen.dart';
import 'authentication/additionalRegistrationPage/drivers_license_screen.dart';
import 'authentication/additionalRegistrationPage/declarations_screen.dart';
import 'authentication/additionalRegistrationPage/consents_screen.dart';
import 'authentication/additionalRegistrationPage/eatseasy_wallet_screen.dart';
import 'authentication/additionalRegistrationPage/tin_number_screen.dart';
import 'authentication/additionalRegistrationPage/nbi_clearance_screen.dart';
import 'authentication/additionalRegistrationPage/emergency_contact_screen.dart';
import 'authentication/additionalRegistrationPage/vehicle_info_screen.dart';
import 'authentication/additionalRegistrationPage/orcr_screen.dart';
import 'authentication/additionalRegistrationPage/vehicle_documents_screen.dart';

import 'global/global.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  sharedPreferences = await SharedPreferences.getInstance();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EatsEasy Riders App',
      theme: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      home: const MySplashScreen(),
      routes: {
        '/personalDetails': (context) => const PersonalDetailsScreen(),
        '/driversLicense': (context) => const DriversLicenseScreen(),
        '/declarations': (context) => const DeclarationsScreen(),
        '/consents': (context) => const ConsentsScreen(),
        '/eatsEasyPayWallet': (context) => const EatsEasyPayWalletScreen(),
        '/tinNumber': (context) => const TINNumberScreen(),
        '/nbiClearance': (context) => const NBIClearanceScreen(),
        '/emergencyContact': (context) => const EmergencyContactScreen(),
        '/vehicleInfo': (context) => const VehicleInfoScreen(),
        '/orCr': (context) => const OrCrScreen(),
        '/vehicleDocs': (context) => const VehicleDocumentsScreen()
      },
    );
  }
}
