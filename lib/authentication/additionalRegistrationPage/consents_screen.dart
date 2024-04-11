import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';

class ConsentsScreen extends StatefulWidget {
  const ConsentsScreen({Key? key}) : super(key: key);

  @override
  _ConsentsScreenState createState() => _ConsentsScreenState();
}

class _ConsentsScreenState extends State<ConsentsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedInConsents = false; // Flag to track if button is pressed

  bool isCheckboxesCompleted = true;

  // First checkbox section items
  bool mainConsentBox1 = false;
  bool mainConsentBox2 = false;
  bool mainConsentBox3 = false;
  bool mainConsentBox4 = false;
  // Second checkbox section items
  bool offersConsentBox1 = false;
  bool offersConsentBox2 = false;
  bool offersConsentBox3 = false;
  bool offersConsentBox4 = false;
  // Third checkbox section items
  bool additionalConsentBox1 = false;
  bool additionalConsentBox2 = false;
  bool additionalConsentBox3 = false;
  bool additionalConsentBox4 = false;


  // First checkbox section texts
  Map<String, bool> mainCheckboxes = {
    "I agree to let EatsEasy collect, use, process, and share my personal data only for Relevant Purposes.": false,
    "I have read, understand, and agree to EatsEasy's Privacy Policy.": false,
    "I have read, understand, and agree to EatsEasy's Code of Conduct.": false,
    "I have read, understand, and agree to EatsEasy's Terms of Service.": false,
  };
  // Second checkbox section texts
  Map<String, bool> offersCheckboxes = {
    "SMS": false,
    "Call": false,
    "Email": false,
    "Push Notifications": false,
  };
  // Third checkbox section texts
  Map<String, bool> additionalCheckboxes = {
    "SMS": false,
    "Call": false,
    "Email": false,
    "Push Notifications": false,
  };

  bool _allChecked() {
    return mainCheckboxes.values.every((value) => value == true);
  }

  void _saveUserDataToPrefs() async {
    if (_allChecked()) {
      // First checkbox section values
      await sharedPreferences?.setBool('mainConsentBox1', true);
      await sharedPreferences?.setBool('mainConsentBox2', true);
      await sharedPreferences?.setBool('mainConsentBox3', true);
      await sharedPreferences?.setBool('mainConsentBox4', true);

      // Second checkbox section values
      await sharedPreferences?.setBool('offersConsentBox1', offersConsentBox1);
      await sharedPreferences?.setBool('offersConsentBox2', offersConsentBox2);
      await sharedPreferences?.setBool('offersConsentBox3', offersConsentBox3);
      await sharedPreferences?.setBool('offersConsentBox4', offersConsentBox4);

      // Third checkbox section values
      await sharedPreferences?.setBool('additionalConsentBox1', additionalConsentBox1);
      await sharedPreferences?.setBool('additionalConsentBox2', additionalConsentBox2);
      await sharedPreferences?.setBool('additionalConsentBox3', additionalConsentBox3);
      await sharedPreferences?.setBool('additionalConsentBox4', additionalConsentBox4);

      await sharedPreferences?.setBool('isChangesSavedInConsents', true);
      await sharedPreferences?.setBool('isButtonPressedInConsents', true);
      // Store completion status in shared preferences
      await sharedPreferences?.setBool('consentsCompleted', true);

      await sharedPreferences?.setBool('isRiderAcceptedConsent', true);
      setState(() {
        changesSaved  = true;
        isCompleted = true;
      });

      // Toggle the button state
      isButtonPressedInConsents = !isButtonPressedInConsents;
    } else {
      setState(() {
        isCheckboxesCompleted = false;
      });
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please fill up all required checkboxes*",
            );
          });

    }
  }
  Future<void> _loadUserDetails() async {
    setState(() {
      // Load first checkbox section values
      mainConsentBox1 = sharedPreferences?.getBool('mainConsentBox1') ?? false;
      mainConsentBox2 = sharedPreferences?.getBool('mainConsentBox2') ?? false;
      mainConsentBox3 = sharedPreferences?.getBool('mainConsentBox3') ?? false;
      mainConsentBox4 = sharedPreferences?.getBool('mainConsentBox4') ?? false;
      // Load second checkbox section values
      offersConsentBox1 = sharedPreferences?.getBool('offersConsentBox1') ?? false;
      offersConsentBox2 = sharedPreferences?.getBool('offersConsentBox2') ?? false;
      offersConsentBox3 = sharedPreferences?.getBool('offersConsentBox3') ?? false;
      offersConsentBox4 = sharedPreferences?.getBool('offersConsentBox4') ?? false;
      // Load third checkbox section values
      additionalConsentBox1 = sharedPreferences?.getBool('additionalConsentBox1') ?? false;
      additionalConsentBox2 = sharedPreferences?.getBool('additionalConsentBox2') ?? false;
      additionalConsentBox3 = sharedPreferences?.getBool('additionalConsentBox3') ?? false;
      additionalConsentBox4 = sharedPreferences?.getBool('additionalConsentBox4') ?? false;
    });

    setState(() {
      if (sharedPreferences!.containsKey('consentsCompleted')) {
        changesSaved  = sharedPreferences?.getBool('isChangesSavedInConsents') ?? false;
      }
      isButtonPressedInConsents = sharedPreferences?.getBool('isButtonPressedInConsents') ?? false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
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
          if (sharedPreferences!.containsKey('mainConsentBox1')) {

            _loadUserDetails();

          } else {
            // First checkbox section items
            mainConsentBox1 = false;
            mainConsentBox2 = false;
            mainConsentBox3 = false;
            mainConsentBox4 = false;
            // Second checkbox section items
            offersConsentBox1 = false;
            offersConsentBox2 = false;
            offersConsentBox3 = false;
            offersConsentBox4 = false;
            // Third checkbox section items
            additionalConsentBox1 = false;
            additionalConsentBox2 = false;
            additionalConsentBox3 = false;
            additionalConsentBox4 = false;
          }
        });
        return true; // Allow pop after changes are discarded
      }
      return false; // Prevent pop if changes are not discarded
    }
    return true; // Allow pop if changes are saved or no changes were made
  }

  @override
  Widget build(BuildContext context) {
    // First checkbox section
    mainCheckboxes["I agree to let EatsEasy collect, use, process, and share my personal data only for Relevant Purposes."] = mainConsentBox1;
    mainCheckboxes["I have read, understand, and agree to EatsEasy's Privacy Policy."] = mainConsentBox2;
    mainCheckboxes["I have read, understand, and agree to EatsEasy's Code of Conduct."] = mainConsentBox3;
    mainCheckboxes["I have read, understand, and agree to EatsEasy's Terms of Service."] = mainConsentBox4;
    // Second checkbox section
    offersCheckboxes["SMS"] = offersConsentBox1;
    offersCheckboxes["Call"] = offersConsentBox2;
    offersCheckboxes["Email"] = offersConsentBox3;
    offersCheckboxes["Push Notifications"] = offersConsentBox4;
    // Third checkbox section
    additionalCheckboxes["SMS"] = additionalConsentBox1;
    additionalCheckboxes["Call"] = additionalConsentBox2;
    additionalCheckboxes["Email"] = additionalConsentBox3;
    additionalCheckboxes["Push Notifications"] = additionalConsentBox4;
    return Scaffold(
        body: WillPopScope(
          onWillPop: _onWillPop,
          child: SizedBox(
            height: MediaQuery
                .of(context)
                .size
                .height,
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
                                  Text(
                                    "Consents",
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 45,
                                        fontFamily: "Poppins",
                                        fontWeight: FontWeight.w700),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(60),
                                  topRight: Radius.circular(60))),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const SizedBox(height: 10),
                                Column(
                                  children: mainCheckboxes.keys.map((String text) {
                                    return CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      title: Text(text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: "Poppins", // Change the font family here
                                        ),
                                      ),
                                      value: mainCheckboxes[text],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          switch (text) {
                                            case "I agree to let EatsEasy collect, use, process, and share my personal data only for Relevant Purposes.":
                                              mainConsentBox1 = value!;
                                              break;
                                            case "I have read, understand, and agree to EatsEasy's Privacy Policy.":
                                              mainConsentBox2 = value!;
                                              break;
                                            case "I have read, understand, and agree to EatsEasy's Code of Conduct.":
                                              mainConsentBox3 = value!;
                                              break;
                                            case "I have read, understand, and agree to EatsEasy's Terms of Service.":
                                              mainConsentBox4 = value!;
                                              break;
                                          }
                                          changesSaved = false;
                                          isCompleted = false;
                                          isButtonPressedInConsents = false;
                                        });
                                      },
                                      side: BorderSide(color: isCheckboxesCompleted ? Colors.black : Colors.red), // Set border color
                                      fillColor: MaterialStateColor.resolveWith((states) {
                                        // Set fill color
                                        if (states.contains(MaterialState.selected)) {
                                          return const Color.fromARGB(255, 242, 198, 65); // Color when checkbox is selected
                                        }
                                        return Colors.transparent; // Default color
                                      }),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),

                                Container(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Offers from EatsEasy",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                              )),
                                          Text(" (Optional)",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black45,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ],
                                      ),
                                      SizedBox(height: 10),

                                      Text(
                                        "I would like to be contacted for promotions, events and other marketing purposes via:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: "Poppins",
                                        ),// Text fading effect when it overflows
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  children: offersCheckboxes.keys.map((String text) {
                                    return CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      title: Text(text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: "Poppins", // Change the font family here
                                        ),
                                      ),
                                      value: offersCheckboxes[text],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          switch (text) {
                                            case "SMS":
                                              offersConsentBox1 = value!;
                                              break;
                                            case "Call":
                                              offersConsentBox2 = value!;
                                              break;
                                            case "Email":
                                              offersConsentBox3 = value!;
                                              break;
                                            case "Push Notifications":
                                              offersConsentBox4 = value!;
                                              break;
                                          }
                                          changesSaved = false;
                                          isCompleted = false;
                                          isButtonPressedInConsents = false;
                                        });
                                      },
                                      side: const BorderSide(color: Colors.black), // Set border color
                                      fillColor: MaterialStateColor.resolveWith((states) {
                                        // Set fill color
                                        if (states.contains(MaterialState.selected)) {
                                          return const Color.fromARGB(255, 242, 198, 65); // Color when checkbox is selected
                                        }
                                        return Colors.transparent; // Default color
                                      }),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text("Additional Income Opportunities",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                              )),
                                          Text(" (Optional)",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black45,
                                                fontFamily: "Poppins",
                                                fontWeight: FontWeight.w500,
                                              )),
                                        ],
                                      ),

                                      SizedBox(height: 10),

                                      Text(
                                        "I would like to be contacted for additional income opportunities via: ",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: "Poppins",
                                        ),// Text fading effect when it overflows
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  children: additionalCheckboxes.keys.map((String text) {
                                    return CheckboxListTile(
                                      controlAffinity: ListTileControlAffinity.leading,
                                      title: Text(text,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black,
                                          fontFamily: "Poppins", // Change the font family here
                                        ),
                                      ),
                                      value: additionalCheckboxes[text],
                                      onChanged: (bool? value) {
                                        setState(() {
                                          switch (text) {
                                            case "SMS":
                                              additionalConsentBox1 = value!;
                                              break;
                                            case "Call":
                                              additionalConsentBox2 = value!;
                                              break;
                                            case "Email":
                                              additionalConsentBox3 = value!;
                                              break;
                                            case "Push Notifications":
                                              additionalConsentBox4 = value!;
                                              break;
                                          }
                                          changesSaved = false;
                                          isCompleted = false;
                                          isButtonPressedInConsents = false;
                                        });
                                      },
                                      side: const BorderSide(color: Colors.black), // Set border color
                                      fillColor: MaterialStateColor.resolveWith((states) {
                                        // Set fill color
                                        if (states.contains(MaterialState.selected)) {
                                          return const Color.fromARGB(255, 242, 198, 65); // Color when checkbox is selected
                                        }
                                        return Colors.transparent; // Default color
                                      }),
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isButtonPressedInConsents ? null : () => _saveUserDataToPrefs(),
                                          // Register button styling
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonPressedInConsents ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            elevation: 4, // Elevation for the shadow
                                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                          ),
                                          child: Text(
                                            isButtonPressedInConsents ? "Saved" : "Save",
                                            style: TextStyle(
                                              color: isButtonPressedInConsents ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        )
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
}


