import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../authentication/register.dart';
import '../authentication/register2.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;
  final bool isRegisterPage;

  const LoadingDialog({
    Key? key,
    this.message,
    required this.isRegisterPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isRegisterPage) {
      Future.delayed(const Duration(milliseconds: 500), () {
        // Navigate to the main content page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      });
    }

    // Temporary filler color
    Color fillerColor = Colors.white; // Change this to your desired color

    return Material(
      color: isRegisterPage ? fillerColor : Colors.transparent, // Set the background color here
      child: AlertDialog(
        key: key,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10,),
            LoadingAnimationWidget.inkDrop(
              color: const Color.fromARGB(255, 242, 198, 65),
              size: 35,
            ),
            const SizedBox(height: 10,),
            Text(
              "${message!}, Please wait...",
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
