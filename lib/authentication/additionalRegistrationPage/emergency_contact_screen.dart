import 'package:animate_do/animate_do.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';

class EmergencyContactScreen extends StatefulWidget {
  const EmergencyContactScreen({Key? key}) : super(key: key);

  @override
  _EmergencyContactScreenState createState() => _EmergencyContactScreenState();
}

class _EmergencyContactScreenState extends State<EmergencyContactScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController emergencyContactNameController = TextEditingController();
  TextEditingController emergencyNumberController = TextEditingController();
  TextEditingController emergencyAddressController = TextEditingController();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedInEmergencyContact = false; // Flag to track if button is pressed

  bool _isEmergencyContactNameControllerInvalid = false;

  bool _isRelationshipEmpty = false;
  bool _isEmergencyNumberCompleted = true;
  bool _isUserTypingEmergencyNumber = false;
  bool _isEmergencyNumberControllerInvalid = false;
  bool _isEmergencyAddressControllerInvalid = false;
  bool _isFormComplete = true;

  final List<String> _relationshipDropdownItems = [
    "Parent",
    "Child",
    "Sibling",
    "Spouse",
    "Partner",
    "Grandparent",
    "Grandchild",
    "Aunt/Uncle",
    "Niece/Nephew",
    "Cousin",
    "Friend",
    "Colleague",
    "Mentor",
    "Protege",
    "Neighbor",
    "Roommate",
    "Godparent",
    "In-law",
    "Ex-partner/ex-spouse",
    "Acquaintance"
  ];

  String? relationshipController;

  void _validateTextFields() {
    if (emergencyContactNameController.text.isEmpty) {
      setState(() {
        _isEmergencyContactNameControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (relationshipController == null) {
      setState(() {
        _isRelationshipEmpty = true;
        _isFormComplete = false;
      });
    }
    if (emergencyNumberController.text.isEmpty) {
      setState(() {
        _isEmergencyNumberControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (emergencyAddressController.text.isEmpty) {
      setState(() {
        _isEmergencyAddressControllerInvalid = true;
        _isFormComplete = false;
      });
    }
    if (emergencyContactNameController.text.isNotEmpty &&
        relationshipController != null &&
        emergencyNumberController.text.isNotEmpty &&
        emergencyAddressController.text.isNotEmpty) {

      _isFormComplete = true;
    }
  }

  void _saveUserDataToPrefs() async {
    _validateTextFields();
    if(_isFormComplete) {
      sharedPreferences = await SharedPreferences.getInstance();

      await sharedPreferences?.setString('emergencyContactName', emergencyContactNameController.text);
      await sharedPreferences?.setString('relationship', relationshipController!);
      await sharedPreferences?.setString('emergencyNumber', emergencyNumberController.text);
      await sharedPreferences?.setString('emergencyAddress', emergencyAddressController.text);

      await sharedPreferences?.setBool('isChangesSavedInEmergencyContact', true);
      await sharedPreferences?.setBool('isButtonPressedInEmergencyContact', true);

      setState(() {
        changesSaved  = true;
        isCompleted = true;
        // Toggle the button state
        isButtonPressedInEmergencyContact = !isButtonPressedInEmergencyContact;
      });

      // Store completion status in shared preferences
      await sharedPreferences?.setBool('emergencyContactCompleted', true);
    } else {
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
    setState(() {
      emergencyContactNameController.text = sharedPreferences?.getString('emergencyContactName') ?? '';
      relationshipController = sharedPreferences?.getString('relationship');
      emergencyNumberController.text = sharedPreferences?.getString('emergencyNumber') ?? '';
      emergencyAddressController.text = sharedPreferences?.getString('emergencyAddress') ?? '';
    });

    if (sharedPreferences!.containsKey('emergencyContactCompleted')) {
      changesSaved  = sharedPreferences?.getBool('isChangesSavedInEmergencyContact') ?? false;
    }
    isButtonPressedInEmergencyContact = sharedPreferences?.getBool('isButtonPressedInEmergencyContact') ?? false;
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
          if (sharedPreferences!.containsKey('emergencyContactName')) {

            _loadUserDetails();

          } else {
            emergencyContactNameController.text = '';
            emergencyNumberController.text = '';
            emergencyAddressController.text = '';
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
                                    "Emergency Contact",
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
                                const SizedBox(height: 10,),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      //spacing
                                      const SizedBox(height: 10),

                                      // Emergency Contact Name
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Emergency Contact Name",
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

                                      CustomTextField(
                                          data: Icons.person_2_rounded,
                                          controller: emergencyContactNameController,
                                          hintText: "",
                                          isObsecure: false,
                                          keyboardType: TextInputType.text,
                                          textCapitalization: TextCapitalization.sentences,
                                          redBorder: _isEmergencyContactNameControllerInvalid,
                                          noLeftMargin: false,
                                          noRightMargin: false,
                                          onChanged:(value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedInEmergencyContact = false;
                                              _isEmergencyContactNameControllerInvalid = false;
                                            });
                                          }
                                      ),
                                      //Show "Please enter emergency contact name"
                                      if (_isEmergencyContactNameControllerInvalid == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Please enter the emergency contact name",
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

                                      //spacing
                                      const SizedBox(height: 20),
                                      // Relationship
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Relationship",
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
                                        padding: const EdgeInsets.all(4),
                                        margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0E3E7),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _isRelationshipEmpty ? Colors.red : Colors.transparent,
                                          ),
                                        ),
                                        child: DropdownButtonFormField2<String>(
                                          isExpanded: true,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                          ),
                                          hint: const Text(
                                            'Select relationship',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          value: relationshipController, //
                                          items: _relationshipDropdownItems.map((item) => DropdownMenuItem<String>(
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
                                              return 'Select relationship';
                                            }
                                            return null;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedInEmergencyContact = false;
                                              _isRelationshipEmpty = false;
                                              relationshipController = value.toString();
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

                                      //Show "Please choose your relationship to the person"
                                      if (_isRelationshipEmpty == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Please choose your relationship to the person",
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

                                      //spacing
                                      const SizedBox(height: 20),
                                      // Emergency Contact Number
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Emergency Contact Number",
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
                                      //Contact number text field,
                                      Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: CustomTextField(
                                              data: Icons.phone,
                                              hintText: "+63",
                                              isObsecure: false,
                                              keyboardType: TextInputType.none,
                                              noLeftMargin: false,
                                              noRightMargin: true,
                                              redBorder: false,
                                              enabled: false,
                                            ),
                                          ),

                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE0E3E7),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: _isEmergencyNumberControllerInvalid
                                                      ? Colors.red
                                                      : _isUserTypingEmergencyNumber ? (_isEmergencyNumberCompleted ? Colors.green : Colors.red) : Colors.transparent,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(4),
                                              margin: const EdgeInsets.only(left: 4.0, right: 18.0, top: 8.0),
                                              child: LayoutBuilder(
                                                builder: (BuildContext context, BoxConstraints constraints) {
                                                  double maxWidth = MediaQuery.of(context).size.width * 0.9;
                                                  return ConstrainedBox(
                                                    constraints: BoxConstraints(maxWidth: maxWidth),
                                                    child: TextFormField(
                                                      enabled: true,
                                                      controller: emergencyNumberController,
                                                      obscureText: false,
                                                      cursorColor: const Color.fromARGB(255, 242, 198, 65),
                                                      keyboardType: TextInputType.phone,
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        focusColor: Theme.of(context).primaryColor,
                                                        hintText: "",
                                                      ),
                                                      onChanged: (value) {
                                                        setState(() {
                                                          changesSaved = false;
                                                          isCompleted = false;
                                                          isButtonPressedInEmergencyContact = false;
                                                          _isUserTypingEmergencyNumber = true;
                                                          _isEmergencyNumberControllerInvalid = false;
                                                        });
                                                        if (value.length == 10) {
                                                          setState(() {
                                                            _isEmergencyNumberCompleted = true;
                                                          });
                                                        }
                                                        else {
                                                          if (emergencyNumberController.text.isEmpty) {
                                                            setState(() {
                                                              _isUserTypingEmergencyNumber = false;
                                                            });
                                                          }
                                                          else {
                                                            setState(() {
                                                              _isEmergencyNumberCompleted = false;
                                                            });
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      //Show "Enter a valid emergency contact number"
                                      if ((_isUserTypingEmergencyNumber &&
                                          _isEmergencyNumberCompleted == false) || _isEmergencyNumberControllerInvalid)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Enter a valid emergency contact number",
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
                                      //Emergency Address
                                      const SizedBox(height: 10),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 18),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Emergency Address",
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

                                      //Emergency Address
                                      CustomTextField(
                                          data: Icons.house_rounded,
                                          controller: emergencyAddressController,
                                          hintText: "",
                                          isObsecure: false,
                                          keyboardType: TextInputType.text,
                                          textCapitalization: TextCapitalization.sentences,
                                          redBorder: _isEmergencyAddressControllerInvalid,
                                          noLeftMargin: false,
                                          noRightMargin: false,
                                          onChanged:(value) {
                                            setState(() {
                                              changesSaved = false;
                                              isCompleted = false;
                                              isButtonPressedInEmergencyContact = false;
                                              _isEmergencyAddressControllerInvalid = false;
                                            });
                                          }
                                      ),
                                      //Show "Enter a valid emergency contact number"
                                      if (_isEmergencyAddressControllerInvalid == true)
                                        const Row(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(left: 35),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 2),
                                                  Text("Enter a valid emergency contact number",
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
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                // Submit button
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: isButtonPressedInEmergencyContact ? null : () => _saveUserDataToPrefs(),
                                          // Register button styling
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isButtonPressedInEmergencyContact ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            elevation: 4, // Elevation for the shadow
                                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                                          ),
                                          child: Text(
                                            isButtonPressedInEmergencyContact ? "Saved" : "Save",
                                            style: TextStyle(
                                              color: isButtonPressedInEmergencyContact ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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


