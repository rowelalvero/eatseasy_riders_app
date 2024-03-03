import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String? message;
  const ErrorDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      key: key,
      content: Text(message!),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 242, 198, 65),
          ),
          onPressed: () => Navigator.pop(context),
          child: const Center(
            child: Text("Ok",
              style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 12,
                  color: Colors.black54
              )),
          ),
        )
      ],
    );
  }
}
