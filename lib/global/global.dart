import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences? sharedPreferences;
FirebaseAuth firebaseAuth = FirebaseAuth.instance;
var loggedIn = false;

Position? position;
List<Placemark>? placeMarks;
String completeAddress = '';

String perParcelDeliveryAmount = '';
String previousEarnings = ''; // Vendor old total earnings
String previousRiderEarnings = ''; // Rider total earnings