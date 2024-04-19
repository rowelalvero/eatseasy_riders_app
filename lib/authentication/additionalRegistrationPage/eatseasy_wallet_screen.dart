import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';

class EatsEasyPayWalletScreen extends StatefulWidget {
  const EatsEasyPayWalletScreen({Key? key}) : super(key: key);

  @override
  _EatsEasyPayWalletScreenState createState() => _EatsEasyPayWalletScreenState();
}

class _EatsEasyPayWalletScreenState extends State<EatsEasyPayWalletScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedInEatsEasyPayWallet = false; // Flag to track if button is pressed

  bool isCheckboxesCompleted = true;

  bool firstBox1 = false;
  bool secondBox1 = false;

  Map<String, bool> checkboxes = {
    "I have already informed EatsEasy about the personal information I have (including my government ID, profile details, and status) in order to: Provide financial products and services; Perform background checks; Link my personal information to the EatsEasy Customer app (if I have access to them); and Provide reasonable compensation based on EatsEasy privacy policy.": false,
    "I understand that they are linking the EatsEasyPay Wallet to my EatsEasyPay Customer App. If I don't have a EatsEasyPay Wallet, I may need to sign up to get it.": false,
  };

  bool _allChecked() {
    return checkboxes.values.every((value) => value == true);
  }

  void _saveUserDataToPrefs() async {
    if (_allChecked()) {
      await sharedPreferences?.setBool('firstBox1', true);
      await sharedPreferences?.setBool('secondBox1', true);

      await sharedPreferences?.setBool('isChangesSavedInEatsEasyPayWallet', true);
      await sharedPreferences?.setBool('isButtonPressedInEatsEasyPayWallet', true);
      // Store completion status in shared preferences
      await sharedPreferences?.setBool('eatsEasyPayWalletCompleted', true);

      await sharedPreferences?.setBool('isRiderAcceptedEasyPayWallet', true);
      setState(() {
        changesSaved  = true;
        isCompleted = true;
      });

      // Toggle the button state
      isButtonPressedInEatsEasyPayWallet = !isButtonPressedInEatsEasyPayWallet;

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
      firstBox1 = sharedPreferences?.getBool('firstBox1') ?? false;
      secondBox1 = sharedPreferences?.getBool('secondBox1') ?? false;
    });

    setState(() {
      if (sharedPreferences!.containsKey('eatsEasyPayWalletCompleted')) {
        changesSaved  = sharedPreferences?.getBool('isChangesSavedInEatsEasyPayWallet') ?? false;
      }
      isButtonPressedInEatsEasyPayWallet = sharedPreferences?.getBool('isButtonPressedInEatsEasyPayWallet') ?? false;
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
          if (sharedPreferences!.containsKey('firstBox1')) {

            _loadUserDetails();

          } else {
            firstBox1 = false;
            secondBox1 = false;
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
    checkboxes["I have already informed EatsEasy about the personal information I have (including my government ID, profile details, and status) in order to: Provide financial products and services; Perform background checks; Link my personal information to the EatsEasy Customer app (if I have access to them); and Provide reasonable compensation based on EatsEasy privacy policy."] = firstBox1;
    checkboxes["I understand that they are linking the EatsEasyPay Wallet to my EatsEasyPay Customer App. If I don't have a EatsEasyPay Wallet, I may need to sign up to get it."] = secondBox1;

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
                                  Text(
                                    "EatsEasyPay Wallet",
                                    style: TextStyle(color: Colors.white,
                                        fontSize: 40,
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
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: checkboxes.keys.map((String text) {
                                      return CheckboxListTile(
                                        controlAffinity: ListTileControlAffinity.leading,
                                        title: Text(text,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black,
                                            fontFamily: "Poppins", // Change the font family here
                                          ),
                                        ),
                                        value: checkboxes[text],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            switch (text) {
                                              case "I have already informed EatsEasy about the personal information I have (including my government ID, profile details, and status) in order to: Provide financial products and services; Perform background checks; Link my personal information to the EatsEasy Customer app (if I have access to them); and Provide reasonable compensation based on EatsEasy privacy policy.":
                                                firstBox1 = value!;
                                                break;
                                              case "I understand that they are linking the EatsEasyPay Wallet to my EatsEasyPay Customer App. If I don't have a EatsEasyPay Wallet, I may need to sign up to get it.":
                                                secondBox1 = value!;
                                                break;
                                            }
                                            changesSaved = false;
                                            isCompleted = false;
                                            isButtonPressedInEatsEasyPayWallet = false;
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
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isButtonPressedInEatsEasyPayWallet ? null : () => _saveUserDataToPrefs(),
                                          // Register button styling
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonPressedInEatsEasyPayWallet ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            elevation: 4, // Elevation for the shadow
                                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                          ),
                                          child: Text(
                                            isButtonPressedInEatsEasyPayWallet ? "Saved" : "Save",
                                            style: TextStyle(
                                              color: isButtonPressedInEatsEasyPayWallet ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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


