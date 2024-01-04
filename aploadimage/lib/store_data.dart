import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StoreData {
  final storage = FirebaseStorage.instance;
  final firestore = FirebaseFirestore.instance;

  Future<String> saveData({
    required String name,
    required String email,
    required String phone,
    required Uint8List file,
  }) async {
    try {
      // Upload image to Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = storage.ref().child('images/$fileName');
      UploadTask uploadTask = storageReference.putData(file);

      // Wait for the upload to complete
      await uploadTask;

      // Get the download URL of the uploaded image
      String imageUrl = await storageReference.getDownloadURL();

      // Save data to Firestore
      DocumentReference documentReference =
          await firestore.collection('profiles').add({
        'name': name,
        'email': email,
        'phone': phone,
        'imageURL': imageUrl, // Include the image URL if needed
      });

      // Return the document ID or any other response
      return documentReference.id;
    } catch (e) {
      print('Error uploading image and saving data: $e');
      // Throw an error to indicate failure
      throw 'Error: Image upload and data save failed.';
    }
  }
}