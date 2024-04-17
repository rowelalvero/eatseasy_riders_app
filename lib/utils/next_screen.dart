import 'package:flutter/material.dart';

void nextScreen(BuildContext context, String routeName) {
  Navigator.pushNamed(context, routeName);
}

void nextScreenReplace(BuildContext context, String routeName) {
  Navigator.pushReplacementNamed(context, routeName);
}
