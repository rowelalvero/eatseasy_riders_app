import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../../global/global.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../cameraPage/camera_page.dart';
import '../imageFilePaths/rider_profile.dart';

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
  bool isButtonPressedDriversLicenseScreen = false; // Flag to track if button is pressed

  bool _isLicenseNumberCompleted = false;
  bool _isLicenseNumberControllerInvalid = false;
  bool _isIssueDateControllerInvalid = false;
  bool _isfrontLicenseHasNoImage = false;
  bool _isbackLicenseHasNoImage = false;
  bool _isAgeInvalid = false;
  bool _isMotherMaidenNameInvalid = false;
  bool _isResidentialPermanentAddressEmpty = false;
  bool _isFormComplete = true;

  late String residentialPermanentAddressController = 'Yes';

  late DateTime _chosenDateTime;
  bool _isDateTimeSelected = false;

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
                  initialDateTime: _isDateTimeSelected ? _chosenDateTime : DateTime.now(),
                  onDateTimeChanged: (val) {
                    setState(() {
                      _isIssueDateControllerInvalid = false;
                      changesSaved = false;
                      isCompleted = false;
                      isButtonPressedDriversLicenseScreen = false;
                      _chosenDateTime = val;
                      _isDateTimeSelected = true;
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
                const SizedBox(height: 10),
                Image.asset(_isFrontImageSelected
                    ? "images/frontLicenseExample.jpg" : "images/backLicenseExample.jpg",
                  fit: BoxFit.cover, // Ensure the image covers the available space
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _removeLicenseImage() async {
    setState(() {
      isButtonPressedDriversLicenseScreen = false;
      changesSaved = false;
      isCompleted = false;
    });

    setState(() {
      _isFrontImageWillDeleted
      //then
          ? frontLicense = null
      //else
          : backLicense = null;
    });
  }

  //Check if the format of email is valid
  bool isLicenseNumberFormatValid(String licenseNumber) {
    // Regular expression for email validation
    final RegExp licenseNumberRegex = RegExp(r'^N\d{2}-\d{2}-\d{6}$');

    return licenseNumberRegex.hasMatch(licenseNumber);
  }

  void _validateTextFields() {
    String licenseNumber = licenseNumberController.text.trim();
    if (licenseNumberController.text.isEmpty) {
      setState(() {
        _isLicenseNumberControllerInvalid = true;
        _isLicenseNumberCompleted = false;
        _isFormComplete = false;
      });
    }
    if (isLicenseNumberFormatValid(licenseNumber) == false) {
      setState(() {
        _isLicenseNumberControllerInvalid = true;
        _isLicenseNumberCompleted = false;
        _isFormComplete = false;
      });
    }
    if (issueDateController.text.isEmpty) {
      setState(() {
        _isIssueDateControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (frontLicense == null) {
      setState(() {
        _isfrontLicenseHasNoImage = true;
        _isFormComplete = false;
      });
    }
    if (backLicense == null) {
      setState(() {
        _isbackLicenseHasNoImage = true;
        _isFormComplete = false;
      });
    }
    if (ageController.text.isEmpty) {
      setState(() {
        _isAgeInvalid = true;
        _isFormComplete = false;
      });
    }
    if (ageController.text.isNotEmpty) {
      int age = int.parse(ageController.text);
      if (age < 18) {
        _isAgeInvalid = true;
        _isFormComplete = false;
      }
    }
    if (motherMaidenNameController.text.isEmpty) {
      setState(() {
        _isMotherMaidenNameInvalid = true;
        _isFormComplete = false;
      });
    }
    if (residentialPermanentAddressController  == null) {
      setState(() {
        _isResidentialPermanentAddressEmpty = true;
        _isFormComplete = false;
      });
    }
    if (!_isLicenseNumberControllerInvalid &&
        isLicenseNumberFormatValid(licenseNumber) &&
        !_isIssueDateControllerInvalid &&
        !_isfrontLicenseHasNoImage &&
        !_isbackLicenseHasNoImage &&
        !_isAgeInvalid &&
        !_isMotherMaidenNameInvalid &&
        !_isResidentialPermanentAddressEmpty) {

      _isFormComplete = true;
    }
  }

  void _saveUserDataToPrefs() async {
    _validateTextFields();
    if (_isFormComplete) {
      sharedPreferences = await SharedPreferences.getInstance();

      //Save licenseNumberController locally
      await sharedPreferences?.setString('licenseNumber', licenseNumberController.text.trim());
      //Save issueDateController locally
      await sharedPreferences?.setString('issueDate', issueDateController.text);

      String dateString = _chosenDateTime.toIso8601String(); // Convert DateTime to ISO 8601 string format
      await sharedPreferences?.setString('dateTimeKey', dateString);

      await sharedPreferences?.setBool('isDateTimeSelected', true);

      //Save age locally
      await sharedPreferences?.setString('age', ageController.text.trim());
      //Save motherMaidenName locally
      await sharedPreferences?.setString('motherMaiden', motherMaidenNameController.text.trim());
      //Save residentialAddressController locally
      if (residentialAddressController.text.isNotEmpty) {
        await sharedPreferences?.setString('residentialAddress', residentialAddressController.text.trim());
      }
      //Save residentialPermanentAddressController locally
      await sharedPreferences?.setString('isResidentialPermanentAddress', residentialPermanentAddressController );

      // Store completion status in shared preferences
      await sharedPreferences?.setBool('driverLicenseCompleted', true);
      //Save changesSaved value to true
      await sharedPreferences?.setBool('isChangesSavedInDriversLicenseScreen', true);
      // Save isButtonPressed value to true
      await sharedPreferences?.setBool('isButtonPressedDriversLicenseScreen', true);

      setState(() {
        changesSaved  = true;
        isCompleted = true;
      });

      // Toggle the button state
      isButtonPressedDriversLicenseScreen = !isButtonPressedDriversLicenseScreen;

      //Save frontLicense Image locally
      if (frontLicense != null) {
        await sharedPreferences?.setString('frontLicensePath', frontLicense!.path);
      }
      //Save backLicense Image locally
      if (backLicense != null) {
        await sharedPreferences?.setString('backLicensePath', backLicense!.path);
      }


    }
    else {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please fill up all required fields*",
            );
          });
    }
  }

  Future<void> _loadUserDetails() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      //Load licenseNumber data
      licenseNumberController.text = sharedPreferences?.getString('licenseNumber') ?? '';

      //Load issueDate data
      issueDateController.text = sharedPreferences?.getString('issueDate') ?? '';


      String? dateString = sharedPreferences?.getString('dateTimeKey');
      if (dateString != null) {
        _chosenDateTime = DateTime.tryParse(dateString)!; // Parse the stored string back to DateTime
      }

      _isDateTimeSelected  = sharedPreferences?.getBool('isDateTimeSelected') ?? false;

      // Load age data
      ageController.text = sharedPreferences?.getString('age') ?? '';

      // Load motherMaidenName data
      motherMaidenNameController.text = sharedPreferences?.getString('motherMaiden') ?? '';

      // Load residentialAddress data
      residentialAddressController.text = sharedPreferences?.getString('residentialAddress') ?? '';
      //Load residentialPermanentAddress data
      residentialPermanentAddressController  = sharedPreferences?.getString('residentialPermanentAddress') ?? 'Yes';

      if (sharedPreferences!.containsKey('driverLicenseCompleted')) {
        changesSaved  = sharedPreferences?.getBool('isChangesSavedInDriversLicenseScreen') ?? false;
      }
      isButtonPressedDriversLicenseScreen = sharedPreferences?.getBool('isButtonPressedDriversLicenseScreen') ?? false;
    });

    //Load license images
    String? frontLicenseImagePath = sharedPreferences?.getString('frontLicensePath');
    String? backLicenseImagePath = sharedPreferences?.getString('backLicensePath');

    if (frontLicenseImagePath != null && frontLicenseImagePath.isNotEmpty) {
      setState(() {
        frontLicense = XFile(frontLicenseImagePath);
      });
    }
    else {
      setState(() {
        frontLicense = null;
      });
    }

    if (backLicenseImagePath != null && backLicenseImagePath.isNotEmpty) {
      setState(() {
        backLicense = XFile(backLicenseImagePath);
      });
    }
    else {
      setState(() {
        backLicense = null;
      });
    }
  }

  void _navigateToCamera(bool isFrontLicense) async {

    XFile? capturedImage = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraWidget(isFrontLicense: isFrontLicense),
      ),
    );

    // Handle the captured image
    if (capturedImage != null) {
      setState(() {
        if (isFrontLicense) {
          frontLicense = capturedImage;
        } else {
          backLicense = capturedImage;
        }
      });
    }

    setState(() {
      capturedImage = null;
    });

    changesSaved = false;
    isCompleted = false;
    isButtonPressedDriversLicenseScreen = false;
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
                // Reset the screen to its initial state
                setState(() {
                  // Reset necessary variables or fields here
                  licenseNumberController.text = '';
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
        // If changes are discarded, reload user details or reset fields
        sharedPreferences = await SharedPreferences.getInstance();
        setState(() {
          if (sharedPreferences!.containsKey('licenseNumber') &&
              sharedPreferences!.containsKey('issueDate') &&
              sharedPreferences!.containsKey('frontLicense') &&
              sharedPreferences!.containsKey('backLicense') &&
              sharedPreferences!.containsKey('age') &&
              sharedPreferences!.containsKey('motherMaiden') &&
              sharedPreferences!.containsKey('residentialPermanentAddress')) {

            _loadUserDetails();
          }
        });
        return true; // Allow pop after changes are discarded
      }
      return false; // Prevent pop if changes are not discarded
    }
    return true; // Allow pop if changes are saved
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
                                    "Driver License",
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
                                            Text("License Number",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )),
                                            Text(" (Required)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.orangeAccent,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )),

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
                                                    isButtonPressedDriversLicenseScreen = false;
                                                  });
                                                  if(isLicenseNumberFormatValid(value)) {
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

                                      //Please enter your valid license number"
                                      if (_isLicenseNumberControllerInvalid == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Please enter your valid license number",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        color: Colors.red,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                      //License Issue Date
                                      const SizedBox(height: 10),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("License Issue Date",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )
                                            ),
                                            Text(" (Required)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.orangeAccent,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ],
                                        ),
                                      ),
                                      //License Issue Date
                                      Container(
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E3E7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isIssueDateControllerInvalid
                                                ? Colors.red
                                                : Colors.transparent,
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

                                      // Show "Please select the issue date of your driver's license"
                                      if (_isIssueDateControllerInvalid == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Please select the issue date of your driver's license",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        color: Colors.red,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                      //Front Image
                                      const SizedBox(height: 10),

                                      const Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(left: 18),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Upload Document",
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        fontFamily: "Poppins",
                                                        color: Colors.black,
                                                        fontWeight: FontWeight.w600
                                                    )),
                                                SizedBox(height: 10),
                                                Text("Upload your license: ",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontFamily: "Poppins",
                                                    )),
                                                Text("Accepted file formats: .jpg, .png, .jpeg",
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontFamily: "Poppins",
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              //Back Image
                                              const Padding(
                                                padding: EdgeInsets.only(left: 18),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Front Image",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                          fontFamily: "Poppins",
                                                          fontWeight: FontWeight.w500,
                                                        )
                                                    ),
                                                    Text(" (Required)",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.orangeAccent,
                                                          fontFamily: "Poppins",
                                                          fontWeight: FontWeight.w500,
                                                        )),
                                                  ],
                                                ),
                                              ),

                                              _isfrontLicenseHasNoImage
                                                  ? const Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 35),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(height: 2),
                                                        Text("Please provide license image",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily: "Poppins",
                                                              color: Colors.red,
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  :  Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 35),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            _isFrontImageSelected = true;
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                      // Image Picker
                                      InkWell(
                                        onTap: () {
                                          _navigateToCamera(true);
                                          setState(() {
                                            _isfrontLicenseHasNoImage = false;
                                            _isFrontImageSelected = true;
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
                                                  color: _isfrontLicenseHasNoImage ? Colors.red : Colors.transparent, // Choose your border color
                                                  width: 1, // Choose the border width
                                                )
                                            ),
                                            child: frontLicense == null
                                                ? Icon(
                                              Icons.add_photo_alternate,
                                              size: MediaQuery.of(context).size.width * 0.20,
                                              color: Colors.grey,
                                            )
                                                : Image.file(File(frontLicense!.path), fit: BoxFit.cover),
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
                                                  _isfrontLicenseHasNoImage = false;
                                                  _navigateToCamera(true);
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
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),

                                      // Back License
                                      Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              //Back Image
                                              const SizedBox(height: 10),
                                              const Padding(
                                                padding: EdgeInsets.only(left: 18),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Back Image",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                          fontFamily: "Poppins",
                                                          fontWeight: FontWeight.w500,
                                                        )
                                                    ),
                                                    Text(" (Required)",
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.orangeAccent,
                                                          fontFamily: "Poppins",
                                                          fontWeight: FontWeight.w500,
                                                        )),
                                                  ],
                                                ),
                                              ),

                                              _isbackLicenseHasNoImage
                                                  ? const Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 35),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(height: 2),
                                                        Text("Please provide license image",
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              fontFamily: "Poppins",
                                                              color: Colors.red,
                                                            )
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  :  Row(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 35),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            _isFrontImageSelected = false;
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
                                              )
                                            ],
                                          )
                                        ],
                                      ),

                                      const SizedBox(height: 10),
                                      // Image Picker
                                      InkWell(
                                        onTap: () {
                                          _navigateToCamera(false);
                                          setState(() {
                                            _isbackLicenseHasNoImage = false;
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
                                                color: _isbackLicenseHasNoImage ? Colors.red : Colors.transparent, // Choose your border color
                                                width: 1, // Choose the border width
                                              ),
                                            ),
                                            child: backLicense == null
                                                ? Icon(
                                              Icons.add_photo_alternate,
                                              size: MediaQuery.of(context).size.width * 0.20,
                                              color: Colors.grey,
                                            )
                                                : Image.file(File(backLicense!.path), fit: BoxFit.cover),
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
                                                  _isbackLicenseHasNoImage = false;
                                                  _navigateToCamera(false);
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
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      //Age
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Age",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )
                                            ),
                                            Text(" (Required)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.orangeAccent,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ],
                                        ),
                                      ),
                                      //Age
                                      CustomTextField(
                                          data: Icons.person_outline_rounded,
                                          controller: ageController,
                                          hintText: "",
                                          isObsecure: false,
                                          keyboardType: TextInputType.number,
                                          redBorder: _isAgeInvalid,
                                          noLeftMargin: false,
                                          noRightMargin: false,
                                          onChanged:(value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedDriversLicenseScreen = false;
                                              _isAgeInvalid = false;

                                            });
                                          }
                                      ),

                                      if (_isAgeInvalid == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Please enter your age",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        color: Colors.red,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                      //Mother's Maiden Name
                                      const SizedBox(height: 10),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Mother's Maiden Name",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )
                                            ),
                                            Text(" (Required)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.orangeAccent,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ],
                                        ),
                                      ),
                                      //Mother's Maiden Name
                                      CustomTextField(
                                          data: Icons.girl_rounded,
                                          controller: motherMaidenNameController,
                                          hintText: "",
                                          isObsecure: false,
                                          keyboardType: TextInputType.text,
                                          textCapitalization: TextCapitalization.sentences,
                                          redBorder: _isMotherMaidenNameInvalid,
                                          noLeftMargin: false,
                                          noRightMargin: false,
                                          onChanged:(value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedDriversLicenseScreen = false;
                                              _isMotherMaidenNameInvalid = false;
                                            });
                                          }
                                      ),

                                      if (_isMotherMaidenNameInvalid == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Please enter your mother's maiden name",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: "Poppins",
                                                        color: Colors.red,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),

                                      //Residential Address
                                      const SizedBox(height: 10),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Residential Address",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )
                                            ),
                                            Text(" (Optional)",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black45,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                )),
                                          ],
                                        ),
                                      ),

                                      //Residential Address
                                      CustomTextField(
                                          data: Icons.house_rounded,
                                          controller: residentialAddressController,
                                          hintText: "",
                                          isObsecure: false,
                                          keyboardType: TextInputType.text,
                                          textCapitalization: TextCapitalization.sentences,
                                          redBorder: false,
                                          noLeftMargin: false,
                                          noRightMargin: false,
                                          onChanged:(value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedDriversLicenseScreen = false;
                                            });
                                          }
                                      ),

                                      //Residential is permanent Address?
                                      const SizedBox(height: 10),
                                      Container(
                                        padding: const EdgeInsets.only(left: 18.0, right: 18.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            RichText(
                                              text: const TextSpan(
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.black,
                                                  fontFamily: "Poppins",
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: "Is your residential address the same as your permanent address? ",
                                                  ),
                                                  TextSpan(
                                                    text: "(Required)",
                                                    style: TextStyle(
                                                      color: Colors.orangeAccent, // Change this to the desired color
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                        ),
                                        child: DropdownButtonFormField2<String>(
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          hint: const Text(
                                            'Select an option',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          value: residentialPermanentAddressController, // Set default value to 'Yes'
                                          items: ['Yes', 'No'].map((item) => DropdownMenuItem<String>(
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
                                              return 'Select an option';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedDriversLicenseScreen = false;
                                              _isResidentialPermanentAddressEmpty = false;
                                              residentialPermanentAddressController = value.toString();
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

                                      //Spacing
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      //Submit button
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: isButtonPressedDriversLicenseScreen ? null : () => _saveUserDataToPrefs(),
                                                // Register button styling
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: isButtonPressedDriversLicenseScreen ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12.0),
                                                  ),
                                                  elevation: 4, // Elevation for the shadow
                                                  shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                                ),
                                                child: Text(
                                                  isButtonPressedDriversLicenseScreen ? "Saved" : "Save",
                                                  style: TextStyle(
                                                    color: isButtonPressedDriversLicenseScreen ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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
                                      //spacing
                                      const SizedBox(
                                        height: 20,
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