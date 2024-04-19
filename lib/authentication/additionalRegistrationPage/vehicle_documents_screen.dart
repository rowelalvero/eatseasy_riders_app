import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';
import '../imageGetters/rider_profile.dart';
import '../../widgets/image_picker.dart';

class VehicleDocumentsScreen extends StatefulWidget {
  const VehicleDocumentsScreen({Key? key}) : super(key: key);

  @override
  _VehicleDocumentsScreenState createState() => _VehicleDocumentsScreenState();
}

class _VehicleDocumentsScreenState extends State<VehicleDocumentsScreen> {

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedInVehicleDocuments = false; // Flag to track if button is pressed

  String? documentDropdownController;
  bool _isDocumentDropdownEmpty = false;
  bool _isDocumentImageEmpty = false;

  final List<String> _documentDropdownItems = [
    'Authorization Letter',
    'Deed of Sale',
    'Certificate of Repossession',
  ];

  _getImage() async {
    vehicleDoc = await ImageHelper.getImage(context,);

    setState(() {
      _isDocumentImageEmpty = false;
      isButtonPressedInVehicleDocuments = false;
      changesSaved = false;
      isCompleted = false;
    });
  }

  Future<void> _removeImage() async {
    setState(() {
      isButtonPressedInVehicleDocuments = false;
      changesSaved = false;
      isCompleted = false;
    });

    setState(() {
      vehicleDoc = null;
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
    if (documentDropdownController != null) {
      if (vehicleDoc != null) {
        await sharedPreferences?.setString('documentTypeItemDropdown', documentDropdownController!);
        await sharedPreferences?.setString('vehicleDocImagePath', vehicleDoc!.path);

        //Save changesSaved value to true
        await sharedPreferences?.setBool('isChangesSavedInVehicleDocuments', true);
        await sharedPreferences?.setBool('isButtonPressedInVehicleDocuments', true);
        setState(() {
          changesSaved  = true;
          isCompleted = true;
        });

        await sharedPreferences?.setBool('vehicleDocumentsCompleted', true);

        isButtonPressedInVehicleDocuments = !isButtonPressedInVehicleDocuments;
      } else {
        setState(() {
          _isDocumentImageEmpty = true;
        });
        showDialog(
            context: context,
            builder: (c) {
              return const ErrorDialog(
                message: "Please provide your document",
              );
            });
      }

    } else {
      setState(() {
        _isDocumentDropdownEmpty = true;
      });
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select document type",
            );
          });

    }
  }

  Future<void> _loadUserDetails() async {
    String? imagePath = sharedPreferences?.getString('vehicleDocImagePath');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        vehicleDoc = XFile(imagePath);
      });
    } else {
      vehicleDoc = null;
    }

    setState(() {
      documentDropdownController = sharedPreferences?.getString('documentTypeItemDropdown');
    });

    if (sharedPreferences!.containsKey('documentTypeItemDropdown')) {
      changesSaved  = sharedPreferences?.getBool('isChangesSavedInVehicleDocuments') ?? false;
    }
    isButtonPressedInVehicleDocuments = sharedPreferences?.getBool('isButtonPressedInVehicleDocuments') ?? false;
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
          if (sharedPreferences!.containsKey('vehicleDocImagePath')) {

            _loadUserDetails();

          } else {
            vehicleDoc = null;
            documentDropdownController = null;
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
                                    "Vehicle Documents",
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
                                //spacing
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text("Documents (If the OR/CR is not registered under your name.)",
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontFamily: "Poppins",
                                            fontWeight: FontWeight.w500,
                                          )
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: const EdgeInsets.all(4),
                                  margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E3E7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _isDocumentDropdownEmpty ? Colors.red : Colors.transparent,
                                    ),
                                  ),
                                  child: DropdownButtonFormField2<String>(
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                    hint: const Text(
                                      'Select Document',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    value: documentDropdownController, //
                                    items: _documentDropdownItems.map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ))

                                        .toList(),
                                    validator: (value) {
                                      if (value == null) {
                                        return 'Select document';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        changesSaved = false;
                                        isCompleted = false;
                                        isButtonPressedInVehicleDocuments = false;
                                        _isDocumentDropdownEmpty = false;
                                        documentDropdownController = value.toString();
                                      });
                                    },
                                    buttonStyleData: const ButtonStyleData(
                                      padding: EdgeInsets.only(right: 8),
                                    ),
                                    iconStyleData: const IconStyleData(
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.black45,
                                      ),
                                      iconSize: 24,
                                    ),
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    menuItemStyleData: const MenuItemStyleData(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(left: 18.0),
                                  child: const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      Text("For borrowed motorcycles, Authorization Letter written by the Vehicle Owner or Valid ID found in OR/CR.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: "Poppins",
                                            color: Colors.grey,
                                          )
                                      ),
                                    ],
                                  ),
                                ),
                                //if (documentDropdownController == 'Deed of Sale')
                                const SizedBox(height: 20),
                                //Header
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text("Upload Document",
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  fontFamily: "Poppins",
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w600
                                              )),
                                          const SizedBox(height: 10),
                                          const Text("Upload your document: ",
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
                                    ),
                                  ],
                                ),

                                // Image Picker
                                InkWell(
                                  onTap: ()  {
                                    if (documentDropdownController == null) {
                                      setState(() {
                                        _isDocumentImageEmpty = true;
                                      });
                                      showDialog(
                                          context: context,
                                          builder: (c) {
                                            return const ErrorDialog(
                                              message: "Please select a document to upload.",
                                            );
                                          });
                                    } else {
                                      _getImage();
                                    }
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
                                          color: _isDocumentImageEmpty ? Colors.red : Colors.transparent, // Choose your border color
                                          width: 1, // Choose the border width
                                        ),
                                      ),
                                      child: vehicleDoc == null
                                          ? Icon(
                                        Icons.add_photo_alternate,
                                        size: MediaQuery.of(context).size.width * 0.20,
                                        color: Colors.grey,
                                      )
                                          : Image.file(File(vehicleDoc!.path), fit: BoxFit.cover),
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
                                            setState(() {
                                              _isDocumentImageEmpty = true;
                                            });
                                            if (documentDropdownController == null) {
                                              showDialog(
                                                  context: context,
                                                  builder: (c) {
                                                    return const ErrorDialog(
                                                      message: "Please select a document to upload.",
                                                    );
                                                  });
                                            } else {
                                              _getImage();
                                            }
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
                                        if (vehicleDoc != null)
                                          TextButton(
                                            onPressed: () => _removeImage(),
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

                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isButtonPressedInVehicleDocuments ? null : () => _saveUserDataToPrefs(),
                                          // Register button styling
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonPressedInVehicleDocuments ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            elevation: 4, // Elevation for the shadow
                                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                          ),
                                          child: Text(
                                            isButtonPressedInVehicleDocuments ? "Saved" : "Save",
                                            style: TextStyle(
                                              color: isButtonPressedInVehicleDocuments ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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


