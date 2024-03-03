import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({this.message});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
          Text("${message!}, Please wait...",
            style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 12,
                color: Colors.black54
            ),),
        ],
      ),
    );
  }
}
