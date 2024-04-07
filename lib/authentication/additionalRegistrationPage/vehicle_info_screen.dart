import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';

class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({Key? key}) : super(key: key);

  @override
  _VehicleInfoScreenState createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController plateNumberController = TextEditingController();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedInVehicleInfo = false; // Flag to track if button is pressed

  bool _isPlateNumberInvalid = false;

  void _saveUserDataToPrefs() async {
    if (plateNumberController.text.isNotEmpty) {
      await sharedPreferences?.setString('plateNumber', plateNumberController.text);

      await sharedPreferences?.setBool('isChangesSavedInVehicleInfo', true);
      await sharedPreferences?.setBool('isButtonPressedInVehicleInfo', true);

      setState(() {
        changesSaved  = true;
        isCompleted = true;
        // Toggle the button state
        isButtonPressedInVehicleInfo = !isButtonPressedInVehicleInfo;
      });

      // Store completion status in shared preferences
      await sharedPreferences?.setBool('vehicleInfoCompleted', true);
    } else {
      setState(() {
        _isPlateNumberInvalid = true;
      });

      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please provide your plate number",
            );
          });
    }

  }

  Future<void> _loadUserDetails() async {
    plateNumberController.text = sharedPreferences?.getString('plateNumber') ?? '';

    if (sharedPreferences!.containsKey('vehicleInfoCompleted')) {
      changesSaved  = sharedPreferences?.getBool('isChangesSavedInVehicleInfo') ?? false;
    }

    isButtonPressedInVehicleInfo = sharedPreferences?.getBool('isButtonPressedInVehicleInfo') ?? false;
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
          if (sharedPreferences!.containsKey('plateNumber')) {

            _loadUserDetails();

          } else {
            plateNumberController.text = '';
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
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 242, 198, 65),
        title: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Vehicle Info",
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
                const SizedBox(height: 10,),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [

                      const SizedBox(height: 10),

                      // Emergency Contact Name
                      const Padding(
                        padding: EdgeInsets.only(left: 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Plate Number",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 67, 83, 89),
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
                          data: Icons.numbers_rounded,
                          controller: plateNumberController,
                          hintText: "",
                          isObsecure: false,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          redBorder: _isPlateNumberInvalid,
                          noLeftMargin: false,
                          noRightMargin: false,
                          onChanged:(value) {
                            setState(() {
                              changesSaved = false;
                              isCompleted = false;
                              isButtonPressedInVehicleInfo = false;
                              _isPlateNumberInvalid = false;
                            });
                          }
                      ),
                      const Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 2),
                                Text("MV Numbers are accepted",
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

                      if (_isPlateNumberInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please enter your plate number",
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
                          onPressed: isButtonPressedInVehicleInfo ? null : () => _saveUserDataToPrefs(),
                          // Register button styling
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonPressedInVehicleInfo ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4, // Elevation for the shadow
                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                          ),
                          child: Text(
                            isButtonPressedInVehicleInfo ? "Saved" : "Save",
                            style: TextStyle(
                              color: isButtonPressedInVehicleInfo ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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


