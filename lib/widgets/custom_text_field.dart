import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData? data;
  final TextInputType? keyboardType;
  final String hintText;
  bool? isObsecure = true;
  bool? enabled = true;
  bool redBorder;
  bool noLeftMargin;
  bool noRightMargin;
  final ValueChanged<String>? onChanged;
  final TextCapitalization textCapitalization;

  CustomTextField({
    Key? key,
    this.controller,
    this.data,
    required this.hintText,
    this.isObsecure,
    this.enabled,
    this.keyboardType,
    required this.redBorder,
    required this.noLeftMargin,
    required this.noRightMargin,
    this.onChanged,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key); // Modify constructor

  @override
  Widget build(BuildContext context) {
    return Container(
      // box styling
      decoration: BoxDecoration(
        color: const Color(0xFFE0E3E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: redBorder ? Colors.red : Colors.transparent,
        ),
      ),
      padding: const EdgeInsets.all(4),
      margin: noLeftMargin
          ? const EdgeInsets.only(left: 4.0, right: 18.0, top: 8.0)
          : (noRightMargin ? const EdgeInsets.only(left: 18.0, right: 4.0, top: 8.0) : const EdgeInsets.only(left: 18.0, right: 18.0, top: 8.0)),

      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          double maxWidth = MediaQuery.of(context).size.width * 0.9; // Set maximum width to 80% of screen width

          return ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: TextFormField(
              enabled: enabled,
              controller: controller,
              obscureText: isObsecure!,
              cursorColor: const Color.fromARGB(255, 242, 198, 65),
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              // icon styling
              decoration: InputDecoration(
                border: InputBorder.none,
                prefixIcon: noLeftMargin
                    ? null
                    : Icon(data, color: const Color.fromARGB(255, 67, 83, 89)),
                focusColor: Theme.of(context).primaryColor,
                hintText: hintText,
              ),
              onChanged: (value) {
                if (onChanged != null) {
                  onChanged!(value);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
