import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final IconData? data;
  final TextInputType? keyboardType;
  final String hintText;
  bool? isObsecure = true;
  bool? enabled = true;

  CustomTextField({
    super.key,
    required this.controller,
    this.data,
    required this.hintText,
    this.isObsecure,
    this.enabled,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //box styling
      decoration: BoxDecoration(
        color: const Color(0xFFE0E3E7),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0),

      //text field
      child: TextFormField(
        enabled: enabled,
        controller: controller,
        obscureText: isObsecure!,
        cursorColor: const Color.fromARGB(255, 242, 198, 65),
        keyboardType: keyboardType,

        //icon styling
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(data, color: const Color.fromARGB(255, 67, 83, 89)),
          focusColor: Theme.of(context).primaryColor,
          hintText: hintText,
        ),
      ),
    );
  }
}
