import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';
import '../imageGetters/rider_profile.dart';

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
    bool? isCamera = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Camera"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Gallery "),
            ),
          ],
        ),
      ),
    );

    if (isCamera == null) return;

    XFile? file = await ImagePicker().pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    _isOrSelected ? orImage = XFile(file!.path): crImage = XFile(file!.path);
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
          if (sharedPreferences!.containsKey('nbiImagePath')) {

            _loadUserDetails();

          } else {
            orImage = null;
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 198, 65),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "OR / CR",
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
                                fontSize: 25,
                                fontFamily: "Poppins",
                                color: Color.fromARGB(255, 67, 83, 89),
                              )),
                          const SizedBox(height: 10),
                          const Text("Upload your profile logo: ",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 67, 83, 89),
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
                                  const Text("OR",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontFamily: "Poppins",
                                        color: Color.fromARGB(255, 67, 83, 89),
                                      )),
                                  const Text(" (Required)",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
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
                                color: Color.fromARGB(255, 67, 83, 89),
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
                          const Text("CR",
                              style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Poppins",
                                color: Color.fromARGB(255, 67, 83, 89),
                              )),
                          const Text(" (Required)",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
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
                                color: Color.fromARGB(255, 67, 83, 89),
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
        ),
      ),
    );
  }
}


