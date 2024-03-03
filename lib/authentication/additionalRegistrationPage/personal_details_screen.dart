import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/custom_text_field.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({Key? key}) : super(key: key);

  @override
  _PersonalDetailsScreenState createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController secondaryContactNumberController = TextEditingController();
  TextEditingController nationality = TextEditingController();

  // Image picker instance
  File? imageXFile;
  final ImagePicker _picker = ImagePicker();

  // Get image and save it to imageXFile
  Future<void> _getImage() async {
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      // Save image path to SharedPreferences
      SharedPreferences prefsPersonalDetails = await SharedPreferences.getInstance();
      await prefsPersonalDetails.setString('user_image_path', pickedImage.path);

      setState(() {
        imageXFile = File(pickedImage.path);
      });
    }
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


  //Save Image locally
  Future<void> _saveUserImage() async {
    SharedPreferences prefsPersonalDetails = await SharedPreferences.getInstance();
    await prefsPersonalDetails.setString('user_image_path', imageXFile!.path);
  }

  //Save user data locally
  void _saveUserDataFromPrefs() async {
    SharedPreferences prefsPersonalDetails = await SharedPreferences.getInstance();
    await prefsPersonalDetails.setString('secondaryContactNumberController', secondaryContactNumberController.text);
    await prefsPersonalDetails.setString('nationality', nationality.text);
    _saveUserImage();
  }

  late SharedPreferences _prefs;
  String? secondaryContactNumberData;
  String? nationalityData;

  //Load user data if available
  Future<void> _loadUserDetails() async {
    //SharedPreferences prefsPersonalDetails = await SharedPreferences.getInstance();
    //setState(() {
    //  secondaryContactNumberController.text = prefsPersonalDetails.getString('secondaryContactNumberController') ?? '';
    //  nationality.text = prefsPersonalDetails.getString('nationality') ?? '';
    //  String? imagePath = prefsPersonalDetails.getString('user_image_path');
    //  if (imagePath != null) {
    //    setState(() {
    //      imageXFile = File(imagePath);
    //    });
    //  }
    //});

    _prefs = await SharedPreferences.getInstance();
    if (secondaryContactNumberData!.isNotEmpty || nationalityData!.isNotEmpty) {
      setState(() async {
        secondaryContactNumberController.text = _prefs.getString('secondaryContactNumberData')!; // Replace 'key_name' with the key you used to save the data
        nationalityData = _prefs.getString('nationality_Data') ?? '';

      });
    }
    String? imagePath = _prefs.getString('user_image_path');
    if (imagePath != null) {
      setState(() {
        imageXFile = File(imagePath);
      });
    }
  }

  // Remove image
  Future<void> _removeImage() async {
    SharedPreferences prefsPersonalDetails = await SharedPreferences.getInstance();
    await prefsPersonalDetails.remove('user_image_path');

    setState(() {
      imageXFile = null;
    });
  }

  @override
  void initState() {
    super.initState();

    nationality = TextEditingController();
    // Set the initial value of the controller to the first item in the dropdown
    nationality.text = _dropdownItems.first;
    _loadUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope (
      onWillPop: () => _confirmExitDialogue(context),
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
                      // Get image from gallery
                      onTap: () => _getImage(),

                      // Display selected image
                      child: CircleAvatar(
                        radius: MediaQuery.of(context).size.width * 0.20,
                        backgroundColor: const Color.fromARGB(255, 230, 229, 229),
                        backgroundImage: imageXFile == null
                            ? null
                            : FileImage(File(imageXFile!.path)),

                        // Alternative icon
                        child: imageXFile == null
                            ? Icon(
                          Icons.add_photo_alternate,
                          size: MediaQuery.of(context).size.width * 0.20,
                          color: Colors.grey,
                        )
                            : null,
                      ),
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
                              if (imageXFile != null)
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
                    const SizedBox(height: 10),
                    const Text("Secondary Contact Number",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 67, 83, 89),
                          fontFamily: "Poppins",
                        )),
                    // Secondary contact number text field
                    CustomTextField(
                      keyboardType: TextInputType.number,
                      data: Icons.phone_android_rounded,
                      controller: secondaryContactNumberController,
                      hintText: "",
                      isObsecure: false,
                    ),

                    //Spacing
                    const SizedBox(height: 10),

                    // Nationality dropdown
                    Container(
                      padding: const EdgeInsets.all(4),
                      margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: const Color.fromARGB(255, 67, 83, 89),
                        ),
                      ),
                      child: DropdownButton<String>(
                        value: nationalityData,
                        onChanged: (String? newValue) async {
                          setState(() {
                            nationalityData = newValue!;
                          });
                          // Save the selected value to SharedPreferences when it changes
                          await _prefs.setString('nationality_Data', newValue!);
                        },
                        items: _dropdownItems.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),

                  ],
                ),
              ),



              // Spacing
              const SizedBox(
                height: 10,
              ),

              // Submit button
              ElevatedButton(
                onPressed: () {
                  _saveUserDataFromPrefs();
                  },
                // Register button styling
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 242, 198, 65),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 163, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0))),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    color: Color.fromARGB(255, 67, 83, 89),
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
              ),

              // Spacing
              const SizedBox(
                height: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<bool> _confirmExitDialogue(BuildContext context) async {
    if (secondaryContactNumberController.text.isNotEmpty ||
        nationality.text.isNotEmpty) {
      final result = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text('Are you sure you want to discard changes?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, true),
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
        setState(() async {
          Navigator.of(context).pop();
        });
      }
      return result;
    }
    return true;
  }
}
