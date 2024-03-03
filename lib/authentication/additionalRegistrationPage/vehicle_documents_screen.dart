import 'package:flutter/material.dart';

class VehicleDocumentsScreen extends StatefulWidget {
  const VehicleDocumentsScreen({Key? key}) : super(key: key);

  @override
  _VehicleDocumentsScreenState createState() => _VehicleDocumentsScreenState();
}

class _VehicleDocumentsScreenState extends State<VehicleDocumentsScreen> {
  @override
  Widget build(BuildContext context) {return Scaffold(
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
                " rider",
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
            Navigator.of(context).pop();
          },
        ),
      ),
    ),
  );

  }
}


