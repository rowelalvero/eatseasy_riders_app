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

  bool isCheckboxesCompleted = false;

  bool box1 = false;
  bool box2 = false;
  bool box3= false;
  bool box4 = false;
  bool box5 = false;

  Map<String, bool> checkboxes = {
    'Checkbox 1': false,
    'Checkbox 2': false,
    'Checkbox 3': false,
    'Checkbox 4': false,
    'Checkbox 5': false,
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
      setState(() {
        changesSaved  = true;
        isCompleted = true;
      });

      // Toggle the button state
      isButtonPressedInDeclarations = !isButtonPressedInDeclarations;

    } else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please fill up all required checkboxes*",
            );
          });

      setState(() {
        changesSaved = false;
        isCompleted = false;
        isButtonPressedInDeclarations = false;
        isCheckboxesCompleted = false;
      });
    }
  }

  Future<void> _loadUserDetails() async {
    box1 = sharedPreferences?.getBool('box1') ?? false;
    box2 = sharedPreferences?.getBool('box2') ?? false;
    box3 = sharedPreferences?.getBool('box3') ?? false;
    box4 = sharedPreferences?.getBool('box4') ?? false;
    box5 = sharedPreferences?.getBool('box5') ?? false;

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
    checkboxes['Checkbox 1'] = box1;
    checkboxes['Checkbox 2'] = box2;
    checkboxes['Checkbox 3'] = box3;
    checkboxes['Checkbox 4'] = box4;
    checkboxes['Checkbox 5'] = box5;
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
    checkboxes['Checkbox 1'] = box1;
    checkboxes['Checkbox 2'] = box2;
    checkboxes['Checkbox 3'] = box3;
    checkboxes['Checkbox 4'] = box4;
    checkboxes['Checkbox 5'] = box5;
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
                  "Declarations",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 67, 83, 89),
                  ),
                ),
              ],
            ),
          ],
        ),
        // appBar elevation/shadow
        elevation: 2,
        centerTitle: true,
        leadingWidth: 40.0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0), // Adjust the left margin here
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded), // Change this icon to your desired icon
            onPressed: () async {
              // Call _onWillPop to handle the back button press
              final bool canPop = await _onWillPop();
              if (canPop) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),

      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: checkboxes.keys.map((String text) {
                      return CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(text),
                        value: checkboxes[text],
                        onChanged: (bool? value) {
                          setState(() {
                            switch (text) {
                              case 'Checkbox 1':
                                box1 = value!;
                                break;
                              case 'Checkbox 2':
                                box2 = value!;
                                break;
                              case 'Checkbox 3':
                                box3 = value!;
                                break;
                              case 'Checkbox 4':
                                box4 = value!;
                                break;
                              case 'Checkbox 5':
                                box5 = value!;
                                break;
                            }
                            setState(() {
                              changesSaved = false;
                              isCompleted = false;
                              isButtonPressedInDeclarations = false;
                              isCheckboxesCompleted = false;
                            });
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

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
        ),
      ),
    );
  }
}




