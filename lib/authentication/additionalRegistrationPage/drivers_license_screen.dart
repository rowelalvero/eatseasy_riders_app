import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../global/global.dart';
import '../../widgets/custom_text_field.dart';
import '../imageGetters/rider_profile.dart';
import '../register2.dart';

class DriversLicenseScreen extends StatefulWidget {
  const DriversLicenseScreen({Key? key}) : super(key: key);

  @override
  _DriversLicenseScreenState createState() => _DriversLicenseScreenState();
}

class _DriversLicenseScreenState extends State<DriversLicenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController licenseNumberController = TextEditingController();
  TextEditingController issueDateController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController motherMaidenNameController = TextEditingController();
  TextEditingController residentialAddressController = TextEditingController();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressed = false; // Flag to track if button is pressed

  bool _isLicenseNumberCompleted = false;
  bool _isLicenseNumberControllerInvalid = false;
  bool _isIssueDateCompleted = false;
  bool _isIssueDateControllerInvalid = false;
  bool _isAgeInvalid = false;
  bool _ismotherMaidenNameInvalid = false;

  String? _residentialPermanentAddressController;

  late DateTime _chosenDateTime;

  bool _isFrontImageSelected = false;
  bool _isFrontImageWillDeleted = false;

  bool validateLicenseNumber(String licenseNumber) {
    final RegExp pattern = RegExp(r'^[A-Z]\d{2}-\d{2}-\d{6}$');
    return pattern.hasMatch(licenseNumber.trim());
  }

  void _showDatePicker(ctx) {
    // showCupertinoModalPopup is a built-in function of the cupertino library
    showCupertinoModalPopup(
      context: ctx,
      builder: (_) => Container(
        height: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0), // Adjust the radius as needed
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        child: Column(
          children: [
            // Close the modal
            SizedBox(
              height: 40, // Adjust the height as needed
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Align button to the left
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Poppins",
                        color: Color.fromARGB(255, 242, 198, 65),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black12, // Choose your desired color
                    width: 1.0, // Choose your desired width
                  ),
                ),
              ),
              child: SizedBox(
                height: 250,
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: DateTime.now(),
                  onDateTimeChanged: (val) {
                    setState(() {
                      _isIssueDateControllerInvalid = false;
                      changesSaved = false;
                      isCompleted = false;
                      isButtonPressed = false;
                      _chosenDateTime = val;
                      issueDateController.text = DateFormat('MM/dd/yyyy').format(val); // Format the chosen date and set it to the TextField;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

    XFile? file = await ImagePicker()
        .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    _isFrontImageSelected ? frontLicense = XFile(file!.path): backLicense = XFile(file!.path);
    setState(() {
      isButtonPressed = false;
      changesSaved = false;
      isCompleted = false;
    });
  }

  Future<void> _removeLicenseImage() async {
    setState(() {
      isButtonPressed = false;
      changesSaved = false;
      isCompleted = false;
    });

    setState(() {
      _isFrontImageWillDeleted
          ? frontLicense = null
          : backLicense = null;
      // Update changesSaved based on other changes
    });
  }

  void _saveUserDataToPrefs() async {

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope (
        onWillPop: () async {
      if (!changesSaved) {
        final result = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard Changes?'),
            content: const Text('Are you sure you want to discard changes?'),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    const RegisterScreen2();
                  });
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
            if (sharedPreferences!.containsKey('licenseNumber') &&
                sharedPreferences!.containsKey('issueDate') &&
                sharedPreferences!.containsKey('frontLicense') &&
                sharedPreferences!.containsKey('backLicense')) {
              // Load secondary contact number data
              licenseNumberController.text = sharedPreferences?.getString('licenseNumber') ?? '';
              // Load nationality data
              issueDateController.text = sharedPreferences?.getString('issueDate') ?? '';
              // Load image
              String? frontLicenseImagePath = sharedPreferences?.getString('frontLicense');
              String? backLicenseImagePath = sharedPreferences?.getString('backLicense');
              if (backLicenseImagePath != null && backLicenseImagePath.isNotEmpty) {
                backLicense = XFile(backLicenseImagePath);
              }
              if (frontLicenseImagePath != null && frontLicenseImagePath.isNotEmpty) {
                frontLicense = XFile(frontLicenseImagePath);
              }
              changesSaved = sharedPreferences?.getBool('changesSaved') ?? false;
            } else {
              backLicense = XFile('');
              frontLicense = XFile('');
              issueDateController.text = '';
              licenseNumberController.text = '';
            }
          });
          return true; // Allow pop after changes are discarded
        }
        return false; // Prevent pop if changes are not discarded
      }
      return true; // Allow pop if changes are saved
    },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 242, 198, 65),
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Driver License",
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
          //appBar elevation/shadow
          elevation: 2,
          centerTitle: true,
          leadingWidth: 40.0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 8.0), // Adjust the left margin here
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded), // Change this icon to your desired icon
              onPressed: () {
                // Add functionality to go back
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Text Fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    //spacing
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("License Number (Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )),
                          // Secondary contact number text field

                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E3E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isLicenseNumberControllerInvalid
                              ? Colors.red
                              : _isLicenseNumberCompleted ? Colors.green : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          double maxWidth = MediaQuery.of(context).size.width * 0.9;
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: TextFormField(
                              enabled: true,
                              controller: licenseNumberController,
                              obscureText: false,
                              cursorColor: const Color.fromARGB(255, 242, 198, 65),
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                focusColor: Theme.of(context).primaryColor,
                                hintText: "",
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _isLicenseNumberControllerInvalid = false;
                                  changesSaved = false;
                                  isCompleted = false;
                                  isButtonPressed = false;
                                });
                                if(value.length == 11) {
                                  setState(() {
                                    _isLicenseNumberCompleted = true;
                                  });
                                }
                                else {
                                  setState(() {
                                    _isLicenseNumberCompleted = false;
                                  });
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 2),
                              Text("Standard format: N01-23-456789",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: "Poppins",
                                    color: Colors.grey,
                                  )
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("License Issue Date (Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E3E7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isIssueDateControllerInvalid
                              ? Colors.red
                              : _isIssueDateCompleted ? Colors.green : Colors.transparent,
                        ),
                      ),
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                      child: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          double maxWidth = MediaQuery.of(context).size.width * 0.9;
                          return ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: maxWidth),
                            child: TextFormField(
                              enabled: true,
                              controller: issueDateController,
                              obscureText: false,
                              showCursor: false,
                              keyboardType: TextInputType.none,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  icon: (const Icon(Icons.calendar_month_rounded)),
                                  onPressed: () {
                                    _showDatePicker(context);
                                  },
                                ),
                                focusColor: Theme.of(context).primaryColor,
                                hintText: "",
                              ),
                              onChanged: (value) {
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    //Front Image
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Front Image (Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Image Picker
                    InkWell(
                      //get image from gallery
                      onTap: () {
                        setState(() {
                          _isFrontImageSelected = true;
                        });

                        _getImage();
                      },

                      //display selected image
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.20 * 4,
                          height: MediaQuery.of(context).size.width * 0.20 * 2,
                          color: const Color.fromARGB(255, 230, 229, 229),
                          child: frontLicense == null
                              ? Icon(
                            Icons.add_photo_alternate,
                            size: MediaQuery.of(context).size.width * 0.20,
                            color: Colors.grey,
                          )
                              : Image.file(File(frontLicense!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )

                    ),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isFrontImageSelected = true;
                                });
                                _getImage();
                                } ,
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
                            if (frontLicense != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isFrontImageWillDeleted = true;
                                  });

                                  _removeLicenseImage();
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

                    //Back Image
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Back Image (Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),
                    // Image Picker
                    InkWell(
                      //get image from gallery
                        onTap: () {
                          setState(() {
                            _isFrontImageSelected = false;
                          });

                          _getImage();
                        },

                        //display selected image
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.width * 0.05),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.20 * 4,
                            height: MediaQuery.of(context).size.width * 0.20 * 2,
                            color: const Color.fromARGB(255, 230, 229, 229),
                            child: backLicense == null
                                ? Icon(
                              Icons.add_photo_alternate,
                              size: MediaQuery.of(context).size.width * 0.20,
                              color: Colors.grey,
                            )
                                : Image.file(
                              File(backLicense!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )

                    ),

                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isFrontImageSelected = false;
                                });
                                _getImage();
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
                            if (backLicense != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isFrontImageWillDeleted = false;
                                  });

                                  _removeLicenseImage();
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
                    //Age
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Age (Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),
                    //Age
                    CustomTextField(
                        controller: ageController,
                        hintText: "",
                        isObsecure: false,
                        keyboardType: TextInputType.number,
                        redBorder: _isAgeInvalid,
                        noLeftMargin: false,
                        noRightMargin: false,
                        onChanged:(value) {
                          setState(() {
                            _isAgeInvalid = false;
                          });
                        }
                    ),

                    //Mother's Maiden Name
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Mother's Maiden Name (Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),
                    //Mother's Maiden Name
                    CustomTextField(
                        controller: ageController,
                        hintText: "",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        redBorder: _ismotherMaidenNameInvalid,
                        noLeftMargin: false,
                        noRightMargin: false,
                        onChanged:(value) {
                          setState(() {
                            _ismotherMaidenNameInvalid = false;
                          });
                        }
                    ),

                    //Residential Address
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Residential Address (Optional)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),

                    //Residential Address
                    CustomTextField(
                        controller: ageController,
                        hintText: "",
                        isObsecure: false,
                        keyboardType: TextInputType.text,
                        textCapitalization: TextCapitalization.sentences,
                        redBorder: false,
                        noLeftMargin: false,
                        noRightMargin: false,
                        onChanged:(value) {
                          setState(() {
                          });
                        }
                    ),

                    //Residential is permanent Address?
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.only(left: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Is your residential address the same as you permanent address?(Required)",
                              style: TextStyle(
                                fontSize: 16,
                                color: Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w500,
                              )
                          ),
                        ],
                      ),
                    ),

                    //Residential Address
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E3E7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField2<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                        hint: const Text('Select an option',
                          style: TextStyle(fontSize: 16),
                        ),
                        items: ['Yes', 'No'].map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(item,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ))
                            .toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Suffix';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _residentialPermanentAddressController = value.toString();
                          });
                        },
                        buttonStyleData: const ButtonStyleData(
                          padding: EdgeInsets.only(right: 8),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(Icons.arrow_drop_down,
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

                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Expanded(
                        child: FractionallySizedBox(
                          widthFactor: MediaQuery.of(context).orientation == Orientation.landscape ? 0.64 : 1,
                          // Set width factor to 0.64 in landscape mode, and 1 otherwise
                          child: ElevatedButton(
                            onPressed: isButtonPressed ? null : () => _saveUserDataToPrefs(),
                            // Register button styling
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isButtonPressed ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              elevation: 4, // Elevation for the shadow
                              shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                            ),
                            child: Text(
                              isButtonPressed ? "Saved" : "Save",
                              style: TextStyle(
                                color: isButtonPressed ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
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
    );
  }
}




