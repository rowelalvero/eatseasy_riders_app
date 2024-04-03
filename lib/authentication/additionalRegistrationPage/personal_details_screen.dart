import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../global/global.dart';
import '../imageGetters/rider_profile.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController secondaryContactNumberController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();

  bool changesSaved = true; // Flag to track if changes are saved
  bool isCompleted = false; // Flag to track if form is completed
  bool isButtonPressed = false; // Flag to track if button is pressed

  bool isSecContactNumberCompleted = false;
  bool _isSecContactNumberControllerInvalid = false;


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

    XFile? file = await ImagePicker()
        .pickImage(source: isCamera ? ImageSource.camera : ImageSource.gallery);
    riderProfile = XFile(file!.path);
    setState(() {
      isButtonPressed = false;
      changesSaved = false;
      isCompleted = false;
    });
  }


  //Nationality dropdown items
  final List<String> _dropdownItems = [
    'Filipino',
    'Afghan',
    'Albanian',
    'Algerian',
    'Andorran',
    'Angolan',
    'Antiguan or Barbudan',
    'Argentine',
    'Armenian',
    'Australian',
    'Austrian',
    'Azerbaijani, Azeri',
    'Bahamian',
    'Bahraini',
    'Bengali',
    'Barbadian',
    'Belarusian',
    'Belgian',
    'Belizean',
    'Beninese, Beninois',
    'Bhutanese',
    'Bolivian',
    'Bosnian or Herzegovinian',
    'Motswana, Botswanan',
    'Brazilian',
    'Bruneian',
    'Bulgarian',
    'Burkinabé',
    'Burmese',
    'Burundian',
    'Cabo Verdean',
    'Cambodian',
    'Cameroonian',
    'Canadian',
    'Central African',
    'Chadian',
    'Chilean',
    'Chinese',
    'Colombian',
    'Comoran, Comorian',
    'Congolese',
    'Congolese',
    'Costa Rican',
    'Ivorian',
    'Croatian',
    'Cuban',
    'Cypriot',
    'Czech',
    'Danish',
    'Djiboutian',
    'Dominican',
    'Dominican',
    'Timorese',
    'Ecuadorian',
    'Egyptian',
    'Salvadoran',
    'Equatorial Guinean, Equatoguinean',
    'Eritrean',
    'Estonian',
    'Ethiopian',
    'Fijian',
    'Finnish',
    'French',
    'Gabonese',
    'Gambian',
    'Georgian',
    'German',
    'Ghanaian',
    'Gibraltar',
    'Greek, Hellenic',
    'Grenadian',
    'Guatemalan',
    'Guinean',
    'Bissau-Guinean',
    'Guyanese',
    'Haitian',
    'Honduran',
    'Hungarian, Magyar',
    'Icelandic',
    'Indian',
    'Indonesian',
    'Iranian, Persian',
    'Iraqi',
    'Irish',
    'Israeli',
    'Italian',
    'Ivorian',
    'Jamaican',
    'Japanese',
    'Jordanian',
    'Kazakhstani, Kazakh',
    'Kenyan',
    'I-Kiribati',
    'North Korean',
    'South Korean',
    'Kuwaiti',
    'Kyrgyzstani, Kyrgyz, Kirgiz, Kirghiz',
    'Lao, Laotian',
    'Latvian, Lettish',
    'Lebanese',
    'Basotho',
    'Liberian',
    'Libyan',
    'Liechtensteiner',
    'Lithuanian',
    'Luxembourg, Luxembourgish',
    'Macedonian',
    'Malagasy',
    'Malawian',
    'Malaysian',
    'Maldivian',
    'Malian, Malinese',
    'Maltese',
    'Marshallese',
    'Martiniquais, Martinican',
    'Mauritanian',
    'Mauritian',
    'Mexican',
    'Micronesian',
    'Moldovan',
    'Monégasque, Monacan',
    'Mongolian',
    'Montenegrin',
    'Moroccan',
    'Mozambican',
    'Namibian',
    'Nauruan',
    'Nepali, Nepalese',
    'Dutch, Netherlandic',
    'New Zealand, NZ, Zelanian',
    'Nicaraguan',
    'Nigerien',
    'Nigerian',
    'Northern Marianan',
    'Norwegian',
    'Omani',
    'Pakistani',
    'Palauan',
    'Palestinian',
    'Panamanian',
    'Papua New Guinean, Papuan',
    'Paraguayan',
    'Peruvian',
    'Polish',
    'Portuguese',
    'Puerto Rican',
    'Qatari',
    'Romanian',
    'Russian',
    'Rwandan',
    'Kittitian or Nevisian',
    'Saint Lucian',
    'Saint Vincentian, Vincentian',
    'Samoan',
    'Sammarinese',
    'São Toméan',
    'Saudi, Saudi Arabian',
    'Senegalese',
    'Serbian',
    'Seychellois',
    'Sierra Leonean',
    'Singapore, Singaporean',
    'Slovak',
    'Slovenian, Slovene',
    'Solomon Island',
    'Somali',
    'South African',
    'South Sudanese',
    'Spanish',
    'Sri Lankan',
    'Sudanese',
    'Surinamese',
    'Swazi',
    'Swedish',
    'Swiss',
    'Syrian',
    'Tajikistani',
    'Tanzanian',
    'Thai',
    'Timorese',
    'Togolese',
    'Tokelauan',
    'Tongan',
    'Trinidadian or Tobagonian',
    'Tunisian',
    'Turkish',
    'Turkmen',
    'Tuvaluan',
    'Ugandan',
    'Ukrainian',
    'Emirati, Emirian, Emiri',
    'UK, British',
    'United States, U.S., American',
    'Uruguayan',
    'Uzbekistani, Uzbek',
    'Ni-Vanuatu, Vanuatuan',
    'Vatican',
    'Venezuelan',
    'Vietnamese',
    'Yemeni',
    'Zambian',
    'Zimbabwean',
  ];

  void userData() async{
    sharedPreferences = await SharedPreferences.getInstance();
    //Save secondaryContactNumber locally
    await sharedPreferences?.setString('secondaryContactNumber', secondaryContactNumberController.text);
    //Save nationality locally
    await sharedPreferences?.setString('nationality', nationalityController.text);
    //Save image locally
    if (riderProfile != null) {
      await sharedPreferences?.setString('user_image_path', riderProfile!.path);
    }

    //Save changesSaved value to true
    await sharedPreferences?.setBool('changesSaved', true);
    await sharedPreferences?.setBool('isButtonPressed', true);
    await sharedPreferences?.setBool('isSecContactNumberCompleted', true);
    setState(() {
      changesSaved  = true;
      isCompleted = true;
    });

    // Store completion status in shared preferences
    await sharedPreferences?.setBool('personalDetailsCompleted', true);

    // Toggle the button state
    isButtonPressed = !isButtonPressed;
  }

  //Save user data locally
  void _saveUserDataToPrefs() async {
    //return error message if user pressed the save button without selecting an image
    if (riderProfile == null) {
      showDialog(
          context: context,
          builder: (c) {
            return const ErrorDialog(
              message: "Please select an image.",
            );
          });
    }
    else {
      if (secondaryContactNumberController.text.isNotEmpty && isSecContactNumberCompleted == false) {
        setState(() {
          _isSecContactNumberControllerInvalid = true;
        });
      } else if (isSecContactNumberCompleted == true) {
        userData();
      } else if (secondaryContactNumberController.text.isEmpty) {
        userData();
      }
    }
  }

  //Load user data if available
  Future<void> _loadUserDetails() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      //Load secondary contact number data
      secondaryContactNumberController.text = sharedPreferences?.getString('secondaryContactNumber') ?? '';
      //Load nationality data
      nationalityController.text = sharedPreferences?.getString('nationality') ?? _dropdownItems.first;
      //
      changesSaved  = sharedPreferences?.getBool('changesSaved') ?? false;
      isButtonPressed = sharedPreferences?.getBool('isButtonPressed') ?? false;
      //isSecContactNumberCompleted = sharedPreferences?.getBool('isSecContactNumberCompleted') ?? false;
    });
    //Load image
    String? imagePath = sharedPreferences?.getString('user_image_path');
    if (imagePath != null && imagePath.isNotEmpty) {
      setState(() {
        riderProfile = XFile(imagePath);
      });
    } else {
      riderProfile = null;
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      isButtonPressed = false;
      changesSaved = false;
      isCompleted = false;
    });

    setState(() {
      riderProfile = null;
    });
  }

  @override
  void initState() {
    super.initState();
    nationalityController = TextEditingController();
    // Set the initial value of the controller to the first item in the dropdown
    nationalityController.text = _dropdownItems.first;
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
          if (sharedPreferences!.containsKey('nationality') &&
              sharedPreferences!.containsKey('user_image_path')) {

            _loadUserDetails();

          } else {
            riderProfile = XFile('');
            nationalityController.text = _dropdownItems.first;
            secondaryContactNumberController.text = '';
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
                    "Additional Details",
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
                  // Text Fields
                  const SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        //spacing
                        const SizedBox(height: 10),

                        //Header
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Profile Photo",
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontFamily: "Poppins",
                                        color: Color.fromARGB(255, 67, 83, 89),
                                      )),
                                  SizedBox(height: 10),
                                  Text("Upload your profile logo: ",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 67, 83, 89),
                                        fontFamily: "Poppins",
                                      )),
                                  Text("Accepted file formats: .jpg, .png, .jpeg",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                        fontFamily: "Poppins",
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),

                        //spacing
                        const SizedBox(height: 20),

                        // Image Picker
                        InkWell(
                          //get image from gallery
                          onTap: () => _getImage(),

                          //display selected image
                          child: CircleAvatar(
                              radius: MediaQuery.of(context).size.width * 0.20,
                              backgroundColor: const Color.fromARGB(255, 230, 229, 229),
                              backgroundImage: riderProfile == null
                                  ? null
                                  : FileImage(File(riderProfile!.path)),

                              //alternative icon
                              child: riderProfile == null
                                  ? Icon(
                                Icons.add_photo_alternate,
                                size: MediaQuery.of(context).size.width * 0.20,
                                color: Colors.grey,
                              )
                                  : null),
                        ),

                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [

                                TextButton(
                                  onPressed: () => _getImage(),

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
                                if (riderProfile != null)
                                  TextButton(
                                    onPressed: () => _removeImage(),
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

                        //Header
                        const Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 18),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Make sure you meet all the requirements",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: "Poppins",
                                        color: Color.fromARGB(255, 67, 83, 89),
                                      )),
                                  Text("    • Avoid wearing accessories.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 67, 83, 89),
                                        fontFamily: "Poppins",
                                      )),
                                  Text("    • Make sure you're in well-lit environment.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 67, 83, 89),
                                        fontFamily: "Poppins",
                                      )),
                                  Text("    • Take a picture with white background.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(255, 67, 83, 89),
                                        fontFamily: "Poppins",
                                      )),
                                ],
                              ),
                            ),
                          ],
                        ),

                        //spacing
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.only(left: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Secondary Contact Number (Optional)",
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

                        //Secondary contact number text field,
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
                                    color: _isSecContactNumberControllerInvalid
                                        ? Colors.red
                                        : isSecContactNumberCompleted ? Colors.green : Colors.transparent,
                                  ),
                                ),
                                padding: const EdgeInsets.all(4),
                                margin: const EdgeInsets.only(left: 4.0, right: 18.0, top: 8.0),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
                                  child: TextFormField(
                                    enabled: true,
                                    controller: secondaryContactNumberController,
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
                                        _isSecContactNumberControllerInvalid = false;
                                        changesSaved = false;
                                        isCompleted = false;
                                        isButtonPressed = false;
                                      });
                                      if(value.length == 10) {
                                        setState(() {
                                          isSecContactNumberCompleted = true;
                                        });
                                      }
                                      else {
                                        setState(() {
                                          isSecContactNumberCompleted = false;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        //Show "Invalid Contact number"
                        if (_isSecContactNumberControllerInvalid == true && isSecContactNumberCompleted == false)
                          const Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 35),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 2),
                                    Text("Enter a valid contact number",
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

                        //Spacing
                        const SizedBox(height: 10),

                        const Padding(
                          padding: EdgeInsets.only(left: 18),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Nationality (Required)",
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
                        // Nationality dropdown
                        Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E3E7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SizedBox(
                            width: MediaQuery.of(context).orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.6 : double.infinity,
                            child: DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Select an item', // Hint text
                                hintStyle: TextStyle(color: Colors.grey),
                                prefixIcon: Icon(Icons.flag_rounded),
                              ),
                              isExpanded: true,
                              value: nationalityController.text,
                              onChanged: (String? newValue) async {
                                setState(() {
                                  nationalityController.text = newValue!;
                                  changesSaved = false;
                                  isCompleted = false;
                                });
                              },
                              items: _dropdownItems.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              dropdownColor: Colors.white,
                              // Set the background color of the dropdown list
                              elevation: 2, // Set the elevation of the dropdown list
                            ),
                          ),
                        ),
                      ],
                    ),
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