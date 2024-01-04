import 'dart:typed_data';

import 'package:aploadimage/store_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aploadimage/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Register Profile'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Uint8List? _image;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void selectImage() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void saveProfile() async {
    String name = nameController.text;
    String email = emailController.text;
    String phone = phoneController.text;

    try {
      // Call the function to upload image to Firebase Storage and save data
      String imageUrl = await StoreData().saveData(
        name: name,
        email: email,
        phone: phone,
        file: _image!,
      );

      // Display a SnackBar with a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          duration: Duration(seconds: 3), // Adjust the duration as needed
        ),
      );

      // Optionally, you can use the imageUrl or any other response as needed
      print('Image uploaded. URL: $imageUrl');

      // Clear text fields and selected image
      nameController.clear();
      emailController.clear();
      phoneController.clear();
      setState(() {
        _image = null;
      });
    } catch (e) {
      // Display a SnackBar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving profile: $e'),
          duration: const Duration(seconds: 3), // Adjust the duration as needed
        ),
      );
      print('Error saving profile: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 24,
                ),
                Stack(
                  children: [
                    _image != null
                        ? CircleAvatar(
                            radius: 64,
                            backgroundImage: MemoryImage(_image!),
                          )
                        : const CircleAvatar(
                            radius: 64,
                            backgroundImage: NetworkImage(
                                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSVTtlOwG_6l93Lo3NcGZcQpGx4LXNwa3lF5A&usqp=CAU'),
                          ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: saveProfile,
                  child: const Text('Save Profile'),
                ),
                const SizedBox(height: 24),
                // Display saved profiles using StreamBuilder
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('profiles')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No profiles found.');
                    }
                    return Column(
                      children: snapshot.data!.docs.map((doc) {
                        Map<String, dynamic> data =
                            doc.data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text('Name: ${data['name']}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Email: ${data['email']}'),
                              Text('Phone: ${data['phone']}'),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();
  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }
  print('No Images Selected');
}
