import 'package:flutter/material.dart';

import 'additionalRegistrationPage/personal_details_screen.dart';

class RegisterScreen2 extends StatefulWidget {
  const RegisterScreen2({Key? key}) : super(key: key);

  @override
  _RegisterScreen2State createState() => _RegisterScreen2State();
}

class _RegisterScreen2State extends State<RegisterScreen2> {
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
                  "EatsEasy",
                  style: TextStyle(
                    fontSize: 30,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 67, 83, 89),
                  ),
                ),
                Text(
                  " register",
                  style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Poppins",
                    fontStyle: FontStyle.italic,
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
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Complete your application and start driving with EatsEasy!",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 67, 83, 89),
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      "Provide the following information.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 67, 83, 89),
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              'Personal',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Colors.black54,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const LinkTile(title: 'Personal Details', destination: '/personalDetails', isRequired: true),
          const LinkTile(title: 'Driver License', destination: '/driversLicense', isRequired: true),
          const LinkTile(title: 'Declarations', destination: '/declarations', isRequired: true),
          const LinkTile(title: 'Consents', destination: '/consents', isRequired: true),
          const LinkTile(title: 'EatsEasy Wallet', destination: '/eatsEasyWallet', isRequired: true),
          const LinkTile(title: 'TIN Number', destination: '/tinNumber', isOptional: true),
          const LinkTile(title: 'NBI Clearance', destination: '/nbiClearance', isOptional: true),
          const LinkTile(title: 'Emergency Contact', destination: '/emergencyContact', isOptional: true),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Text(
              'Transport',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
                color: Colors.black54,
              ),
              textAlign: TextAlign.left,
            ),
          ),
          const LinkTile(title: 'Vehicle Info', destination: '/vehicleInfo', isRequired: true),
          const LinkTile(title: 'OR/CR', destination: '/orCr', isRequired: true),
          const LinkTile(title: 'Vehicle Documents', destination: '/vehicleDocs', isOptional: true),

          //spacing
          const SizedBox(
            height: 30,
          ),

          //submit button
          ElevatedButton(
            onPressed: () {

            },
            //register button styling
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 242, 198, 65),
                padding: const EdgeInsets.symmetric(
                    horizontal: 158, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0))),

            child: const Text(
              "Submit",
              style: TextStyle(
                color: Color.fromARGB(255, 67, 83, 89),
                fontFamily: "Poppins",
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),

          //spacing
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }
}

class LinkTile extends StatelessWidget {
  final String title;
  final String destination;
  final bool isRequired;
  final bool isOptional;

  const LinkTile({
    Key? key,
    required this.title,
    required this.destination,
    this.isRequired = false,
    this.isOptional = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, destination);
            },
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontFamily: "Poppins",
                      color: Colors.black54,
                    ),
                  ),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 8.0),
                  const Text(
                    'Required',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Poppins",
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
                if (isOptional) ...[
                  const SizedBox(width: 8.0),
                  const Text(
                    'Optional',
                    style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Poppins",
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
                const Icon(Icons.arrow_forward_ios_rounded, color: Color.fromARGB(255, 67, 83, 89)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LinkScreen extends StatelessWidget {
  final String title;
  final String message;

  const LinkScreen({Key? key, required this.title, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(message),
      ),
    );
  }
}

Route _createRoute() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PersonalDetailsScreen(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.easeInOut;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}