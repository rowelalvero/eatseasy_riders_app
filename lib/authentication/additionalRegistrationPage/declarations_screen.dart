import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';

class DeclarationsScreen extends StatefulWidget {
  const DeclarationsScreen({Key? key}) : super(key: key);

  @override
  _DeclarationsScreenState createState() => _DeclarationsScreenState();
}

class _DeclarationsScreenState extends State<DeclarationsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedInDeclarations = false; // Flag to track if button is pressed

  bool isCheckboxesCompleted = true;

  bool box1 = false;
  bool box2 = false;
  bool box3= false;
  bool box4 = false;
  bool box5 = false;

  Map<String, bool> checkboxes = {
    "My driver's license has not been suspended or disqualified.": false,
    "I have never been convicted by any court.": false,
    'I allow EatsEasy to check my criminal record.': false,
    "I'm not waiting for any kind of court trial against me.": false,
    "I don't have any medical condition to be unfit driving safely.": false,
  };

  bool _allChecked() {
    return checkboxes.values.every((value) => value == true);
  }

  void _saveUserDataToPrefs() async {
    if (_allChecked()) {
      await sharedPreferences?.setBool('box1', true);
      await sharedPreferences?.setBool('box2', true);
      await sharedPreferences?.setBool('box3', true);
      await sharedPreferences?.setBool('box4', true);
      await sharedPreferences?.setBool('box5', true);

      await sharedPreferences?.setBool('isChangesSavedInDeclarations', true);
      await sharedPreferences?.setBool('isButtonPressedInDeclarations', true);
      // Store completion status in shared preferences
      await sharedPreferences?.setBool('declarationsCompleted', true);

      await sharedPreferences?.setBool('isRiderAcceptedDeclaration', true);
      setState(() {
        changesSaved  = true;
        isCompleted = true;
      });

      // Toggle the button state
      isButtonPressedInDeclarations = !isButtonPressedInDeclarations;

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
      box1 = sharedPreferences?.getBool('box1') ?? false;
      box2 = sharedPreferences?.getBool('box2') ?? false;
      box3 = sharedPreferences?.getBool('box3') ?? false;
      box4 = sharedPreferences?.getBool('box4') ?? false;
      box5 = sharedPreferences?.getBool('box5') ?? false;
    });

    setState(() {
      if (sharedPreferences!.containsKey('declarationsCompleted')) {
        changesSaved  = sharedPreferences?.getBool('isChangesSavedInDeclarations') ?? false;
      }
      isButtonPressedInDeclarations = sharedPreferences?.getBool('isButtonPressedInDeclarations') ?? false;
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
          if (sharedPreferences!.containsKey('box1')) {

            _loadUserDetails();

          } else {
            box1 = false;
            box2 = false;
            box3 = false;
            box4 = false;
            box5 = false;
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
    checkboxes["My driver's license has not been suspended or disqualified."] = box1;
    checkboxes["I have never been convicted by any court."] = box2;
    checkboxes['I allow EatsEasy to check my criminal record.'] = box3;
    checkboxes["I'm not waiting for any kind of court trial against me."] = box4;
    checkboxes["I don't have any medical condition to be unfit driving safely."] = box5;
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
                                    "Declarations",
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
                                              case "My driver's license has not been suspended or disqualified.":
                                                box1 = value!;
                                                break;
                                              case "I have never been convicted by any court.":
                                                box2 = value!;
                                                break;
                                              case 'I allow EatsEasy to check my criminal record.':
                                                box3 = value!;
                                                break;
                                              case "I'm not waiting for any kind of court trial against me.":
                                                box4 = value!;
                                                break;
                                              case "I don't have any medical condition to be unfit driving safely.":
                                                box5 = value!;
                                                break;
                                            }
                                            changesSaved = false;
                                            isCompleted = false;
                                            isButtonPressedInDeclarations = false;
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
                                          onPressed: isButtonPressedInDeclarations ? null : () => _saveUserDataToPrefs(),
                                          // Register button styling
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonPressedInDeclarations ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            elevation: 4, // Elevation for the shadow
                                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                          ),
                                          child: Text(
                                            isButtonPressedInDeclarations ? "Saved" : "Save",
                                            style: TextStyle(
                                              color: isButtonPressedInDeclarations ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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




