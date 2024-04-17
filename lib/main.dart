import 'package:eatseasy_riders_app/authentication/register2.dart';
import 'package:eatseasy_riders_app/provider/internet_provider.dart';
import 'package:eatseasy_riders_app/provider/sign_in_provider.dart';
import 'package:eatseasy_riders_app/splashScreen/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:provider/provider.dart';
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

import 'authentication/login.dart';
import 'authentication/register.dart';
import 'global/global.dart';
import 'mainScreens/home_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  sharedPreferences = await SharedPreferences.getInstance();

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<SignInProvider>(
              create: (_) => SignInProvider(),
          ),
          ChangeNotifierProvider<InternetProvider>(
              create: (_) => InternetProvider(),
          )
        ],
      child: MaterialApp(
        title: 'EatsEasy Riders App',
        theme: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        home: const MySplashScreen(),
        routes: {
          '/logInScreen': (context) => const LogInScreen(),
          '/homeScreen': (context) => const HomeScreen(),
          '/registerScreen': (context) => const RegisterScreen(),
          '/registerScreen2': (context) => const RegisterScreen2(),
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
      ),
    );
  }
}
