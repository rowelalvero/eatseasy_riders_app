import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';
import '../imageGetters/rider_profile.dart';
import '../../widgets/image_picker.dart';

class OrCrScreen extends StatefulWidget {
  const OrCrScreen({Key? key}) : super(key: key);

  @override
  _OrCrScreenState createState() => _OrCrScreenState();
}

class _OrCrScreenState extends State<OrCrScreen> {
  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedORCRScreen = false; // Flag to track if button is pressed

  bool _isOrHasNoImage = false;
  bool _isCrHasNoImage = false;

  bool _isOrSelected = false;
  bool _isOrWillDeleted = false;

  //Get image and save it to imageXFile

  _getImage() async {
    XFile? file = await ImageHelper.getImage(context);
    _isOrSelected ? orImage = file : crImage = file;

    setState(() {
      _isOrHasNoImage = false;
      _isCrHasNoImage = false;
      isButtonPressedORCRScreen = false;
      changesSaved = false;
      isCompleted = false;
    });
  }

  Future<void> _removeImage() async {
    setState(() {
      isButtonPressedORCRScreen = false;
      changesSaved = false;
      isCompleted = false;
    });

    setState(() {
      _isOrWillDeleted
        ? orImage = null
        : crImage = null;
    });
  }

  _showLicensePreviewDialog() async {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () {
          Navigator.of(context).pop(); // Close dialog
        },
        child: FractionallySizedBox(
          widthFactor: 1.0, // Cover entire width
          heightFactor: 2.0, // Cover entire height
          child: Container(
            color: Colors.black26, // Set background color for the content area
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("images/frontLicenseExample.jpg",
                  fit: BoxFit.cover, // Ensure the image covers the available space
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveUserDataToPrefs() async {

    //Save image locally
    if (orImage != null) {
      await sharedPreferences?.setString('orImagePath', orImage!.path);
      await sharedPreferences?.setString('crImagePath', crImage!.path);

      //Save changesSaved value to true
      await sharedPreferences?.setBool('isChangesSavedORCRScreen', true);
      await sharedPreferences?.setBool('isButtonPressedORCRScreen', true);
      // Store completion status in shared preferences
      await sharedPreferences?.setBool('orCrCompleted', true);

      setState(() {
        changesSaved  = true;
        isCompleted = true;
        // Toggle the button state
        isButtonPressedORCRScreen = !isButtonPressedORCRScreen;
      });
    }
    else {
      setState(() {
        _isOrHasNoImage = true;
        _isCrHasNoImage = true;
      });
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select an image.",
            );
          });
    }
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      //Load image
      String? orImagePath = sharedPreferences?.getString('orImagePath');
      String? crImagePath = sharedPreferences?.getString('crImagePath');
      if (orImagePath != null && orImagePath.isNotEmpty) {
        setState(() {
          orImage = XFile(orImagePath);
        });
      } else {
        orImage = null;
      }

      if (crImagePath != null && crImagePath.isNotEmpty) {
        setState(() {
          crImage = XFile(crImagePath);
        });
      } else {
        crImage = null;
      }

      if (sharedPreferences!.containsKey('orCrCompleted')) {
        changesSaved  = sharedPreferences?.getBool('isChangesSavedORCRScreen') ?? false;
      }
      isButtonPressedORCRScreen = sharedPreferences?.getBool('isButtonPressedORCRScreen') ?? false;
    });
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
          if (sharedPreferences!.containsKey('orImagePath')) {

            _loadUserDetails();

          } else {
            orImage = null;
            crImage = null;
          }
        });
        return true; // Allow pop after changes are discarded
      }
      return false; // Prevent pop if changes are not discarded
    }
    return true; // Allow pop if changes are saved or no changes were made
  }

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }
  @override
  Widget build(BuildContext context) {
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
                                    "OR / CR",
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

                                //spacing
                                const SizedBox(height: 10),

                                //Header
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Upload Image",
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontFamily: "Poppins",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600
                                              )),
                                          const SizedBox(height: 10),
                                          const Text("Upload your OR/CR: ",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                                fontFamily: "Poppins",
                                              )),
                                          const Text("Accepted file formats: .jpg, .png, .jpeg",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black54,
                                                fontFamily: "Poppins",
                                              )),
                                          Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Text("Original Receipt",
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontFamily: "Poppins",
                                                        color: Colors.black,
                                                      )),
                                                  const Text(" (Required)",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.orangeAccent,
                                                        fontFamily: "Poppins",
                                                      )),
                                                  const SizedBox(width: 10),
                                                  TextButton(
                                                    onPressed: () {
                                                      _showLicensePreviewDialog();
                                                    },
                                                    child: const Text(
                                                      "See example",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        color: Color.fromARGB(255, 242, 198, 65),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                // Image Picker
                                InkWell(
                                  onTap: () {
                                    _getImage();
                                    setState(() {
                                      _isOrHasNoImage = false;
                                      _isOrSelected = true;
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.23 * 4,
                                      height: MediaQuery.of(context).size.width * 0.27 * 2,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 230, 229, 229),
                                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                                        border: Border.all(
                                          color: _isOrHasNoImage ? Colors.red : Colors.transparent, // Choose your border color
                                          width: 1, // Choose the border width
                                        ),
                                      ),
                                      child: orImage == null
                                          ? Icon(
                                        Icons.add_photo_alternate,
                                        size: MediaQuery.of(context).size.width * 0.20,
                                        color: Colors.grey,
                                      )
                                          : Image.file(File(orImage!.path), fit: BoxFit.cover),
                                    ),
                                  ),
                                ),

                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            _getImage();
                                            setState(() {
                                              _isOrHasNoImage = false;
                                              _isOrSelected = true;
                                            });
                                          },

                                          child: const Text(
                                            "Upload Image",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Poppins",
                                              color: Color.fromARGB(255, 242, 198, 65),
                                            ),
                                          ),
                                        ),

                                        // Remove image button
                                        if (orImage != null)
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isOrWillDeleted = true;
                                              });

                                              _removeImage();
                                            },
                                            child: const Text(
                                              "Remove",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),

                                Column(
                                  children: [
                                    Padding(padding: const EdgeInsets.only(left: 18),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          const Text("Crt. of Registration",
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontFamily: "Poppins",
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400,
                                              )),
                                          const Text(" (Required)",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.orangeAccent,
                                                fontFamily: "Poppins",
                                              )),
                                          const SizedBox(width: 10),
                                          TextButton(
                                            onPressed: () {
                                              _showLicensePreviewDialog();
                                            },
                                            child: const Text(
                                              "See example",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                                color: Color.fromARGB(255, 242, 198, 65),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),

                                // Image Picker
                                InkWell(
                                  onTap: () {
                                    _getImage();
                                    setState(() {
                                      _isCrHasNoImage = false;
                                      _isOrSelected = false;
                                    });
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.23 * 4,
                                      height: MediaQuery.of(context).size.width * 0.27 * 2,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 230, 229, 229),
                                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                                        border: Border.all(
                                          color: _isCrHasNoImage ? Colors.red : Colors.transparent, // Choose your border color
                                          width: 1, // Choose the border width
                                        ),
                                      ),
                                      child: crImage == null
                                          ? Icon(
                                        Icons.add_photo_alternate,
                                        size: MediaQuery.of(context).size.width * 0.20,
                                        color: Colors.grey,
                                      )
                                          : Image.file(File(crImage!.path), fit: BoxFit.cover),
                                    ),
                                  ),
                                ),

                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton(
                                          onPressed: () {
                                            _getImage();
                                            setState(() {
                                              _isCrHasNoImage = false;
                                              _isOrSelected = false;
                                            });
                                          },

                                          child: const Text(
                                            "Upload Image",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontFamily: "Poppins",
                                              color: Color.fromARGB(255, 242, 198, 65),
                                            ),
                                          ),
                                        ),

                                        // Remove image button
                                        if (crImage != null)
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _isOrWillDeleted = false;
                                              });

                                              _removeImage();
                                            },
                                            child: const Text(
                                              "Remove",
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontFamily: "Poppins",
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),

                                //Spacing
                                const SizedBox(
                                  height: 10,
                                ),
                                // Submit button
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isButtonPressedORCRScreen ? null : () => _saveUserDataToPrefs(),
                                          // Register button styling
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonPressedORCRScreen ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            elevation: 4, // Elevation for the shadow
                                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                          ),
                                          child: Text(
                                            isButtonPressedORCRScreen ? "Saved" : "Save",
                                            style: TextStyle(
                                              color: isButtonPressedORCRScreen ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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
                                //Spacing
                                const SizedBox(
                                  height: 20,
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


