import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageHelper {
  static Future<XFile?> getImage(BuildContext context) async {
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

    if (isCamera == null) return null;

    XFile? file = await ImagePicker().pickImage(
        source: isCamera ? ImageSource.camera : ImageSource.gallery);
    return file;
  }
}
