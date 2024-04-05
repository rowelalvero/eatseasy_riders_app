import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../global/global.dart';
import '../../widgets/error_dialog.dart';

class TINNumberScreen extends StatefulWidget {
  const TINNumberScreen({Key? key}) : super(key: key);

  @override
  _TINNumberScreenState createState() => _TINNumberScreenState();
}

class _TINNumberScreenState extends State<TINNumberScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController TINNumberController = TextEditingController();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressedTINNumberScreen = false; // Flag to track if button is pressed

  bool _isTINNumberControllerInvalid = false;
  bool _isTINNumberCompleted = false;

  //Check if the format of email is valid
  bool isTINNumberFormatValid(String tinNumber) {
    // Regular expression for email validation
    final RegExp tinNumberRegex = RegExp(r'^\d{3}-\d{3}-\d{3}-\d{3}$');

    return tinNumberRegex.hasMatch(tinNumber);
  }

  void _validateTextFields() {
    String tinNumber = TINNumberController.text;
    if (TINNumberController.text.isEmpty) {
      setState(() {
        _isTINNumberControllerInvalid = true;
        _isTINNumberCompleted = false;
      });
    }
    if(isTINNumberFormatValid(tinNumber)) {
      _isTINNumberCompleted = true;
    }
  }

  void _saveUserDataToPrefs() async {
    _validateTextFields();
    if (_isTINNumberCompleted) {
      await sharedPreferences?.setString('TINNumber', TINNumberController.text.trim());

      await sharedPreferences?.setBool('isChangesSavedTINNumberScreen', true);
      // Save isButtonPressed value to true
      await sharedPreferences?.setBool('isButtonPressedTINNumberScreen', true);

      await sharedPreferences?.setBool('TINNumberCompleted', true);
      setState(() {
        changesSaved  = true;
        isCompleted = true;
        isButtonPressedTINNumberScreen = !isButtonPressedTINNumberScreen;
      });


    } else {
      setState(() {
        _isTINNumberControllerInvalid = true;
      });

      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please provide your TIN Number",
            );
          }
          );
    }
  }

  Future<void> _loadUserDetails() async {
    setState(() {
      TINNumberController.text = sharedPreferences?.getString('TINNumber') ?? '';

      if (sharedPreferences!.containsKey('TINNumberCompleted')) {
        changesSaved  = sharedPreferences?.getBool('isChangesSavedTINNumberScreen') ?? false;
      }

      isButtonPressedTINNumberScreen = sharedPreferences?.getBool('isButtonPressedTINNumberScreen') ?? false;
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
                    children: [
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
                            color: _isTINNumberControllerInvalid
                                ? Colors.red
                                : _isTINNumberCompleted ? Colors.green : Colors.transparent,
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
                                controller: TINNumberController,
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
                                    _isTINNumberControllerInvalid = false;
                                    changesSaved = false;
                                    isCompleted = false;
                                    isButtonPressedTINNumberScreen = false;
                                  });
                                  if(isTINNumberFormatValid(value)) {
                                    setState(() {
                                      _isTINNumberCompleted = true;
                                    });
                                  }
                                  else {
                                    setState(() {
                                      _isTINNumberCompleted = false;
                                    });
                                  }
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      if (_isTINNumberControllerInvalid == true)
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 35),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 2),
                                  Text("Please provide your TIN Number",
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

                //Spacing
                const SizedBox(
                  height: 20,
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isButtonPressedTINNumberScreen ? null : () => _saveUserDataToPrefs(),
                          // Register button styling
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isButtonPressedTINNumberScreen ? Colors.grey : const Color.fromARGB(255, 242, 198, 65),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            elevation: 4, // Elevation for the shadow
                            shadowColor: Colors.grey.withOpacity(0.3), // Light gray
                          ),
                          child: Text(
                            isButtonPressedTINNumberScreen ? "Saved" : "Save",
                            style: TextStyle(
                              color: isButtonPressedTINNumberScreen ? Colors.black54 : const Color.fromARGB(255, 67, 83, 89),
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
        ),
      ),
    );
  }
}
