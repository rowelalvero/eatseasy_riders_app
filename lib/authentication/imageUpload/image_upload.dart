import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;

import '../../global/global.dart';

Future<String> uploadImage(String profilePath, String type) async {
  String? riderEmail = sharedPreferences?.getString('email');
  // Get time and date and store it in imageFileName
  String imageFileName = DateTime.now().millisecondsSinceEpoch.toString();

  // Save the image to reference path and replace image file name with imageFileName
  fStorage.Reference reference = fStorage.FirebaseStorage.instance
      .ref()
      .child("ridersAssets")
      .child(riderEmail!)
      .child("profile")
      .child(type + imageFileName);

  // Get the image file extension (assuming it's either jpg/jpeg or png)
  String fileExtension = profilePath.split('.').last.toLowerCase();

  // Set the content type based on the file extension
  fStorage.SettableMetadata metadata = fStorage.SettableMetadata(contentType: 'image/$fileExtension');

  // Upload the image to the path reference in Firebase storage
  fStorage.UploadTask uploadTask = reference.putFile(File(profilePath), metadata);

  // Get the download URL of the image after the upload is complete
  await uploadTask.whenComplete(() async {
    print("File uploaded");
  });

  // Return the URL
  return await reference.getDownloadURL();
}
