import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class dataStore extends StatefulWidget {
  const dataStore({super.key});

  @override
  State<dataStore> createState() => _dataStoreState();
}

class _dataStoreState extends State<dataStore> {
  GlobalKey<FormState> formkey = new GlobalKey<FormState>();
  TextEditingController emailController = new TextEditingController();
  TextEditingController phoneController = new TextEditingController();
  TextEditingController nameController = new TextEditingController();

  String imageUrl = '';
  Future registerUser(
      String name, String email, int phone, String imageUrl) async {
    try {
      if (!imageUrl.isEmpty) {
        CollectionReference users =
            FirebaseFirestore.instance.collection("Users");
        await users
            .add({
              "Name": name,
              "Email": email,
              "Phone": phone,
              "image": imageUrl,
            })
            .then((value) => print("User added"))
            .catchError((error) => print("Failed to add user: $error"));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text("Successfully added")));
        phoneController.text = '';
        emailController.text = '';
        nameController.text = '';
        setState(() {
          imageUrl = '';
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text("Please Select and Upload Image")));
        return;
      }
    } catch (e) {
      print("Error During Storing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Data Store"),
      ),
      body: SingleChildScrollView(
        child: Form(
            key: formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Email address is required";
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      label: Text("Email"),
                      hintText: "Enter your Email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Name is required";
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      label: Text("Name"),
                      hintText: "Enter your Name",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TextFormField(
                    controller: phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "phone is required";
                    },
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      label: Text("Phone"),
                      hintText: "Enter your Phone",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                    child: IconButton(
                        onPressed: () async {
                          try {
                            final fileImg = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (fileImg == null) return null;

                            String fileName = DateTime.now()
                                .microsecondsSinceEpoch
                                .toString();

                            // get reference to storage root
                            Reference referenceRoot =
                                FirebaseStorage.instance.ref();
                            // create image folder insider folder we upload image
                            Reference referenceDirImage =
                                referenceRoot.child('images');
                            // reference for the image
                            Reference referenceImageToUpload =
                                referenceDirImage.child(fileName);

                            await referenceImageToUpload
                                .putFile(File(fileImg.path));

                            imageUrl =
                                await referenceImageToUpload.getDownloadURL();
                          } catch (e) {
                            print("Error during uploading: $e");
                          }
                        },
                        icon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                "Upload Image",
                                style: TextStyle(fontSize: 18),
                              ),
                              Icon(
                                Icons.camera_alt,
                                size: 30,
                              ),
                            ],
                          ),
                        ))),
                SizedBox(
                  height: 10,
                ),
                GestureDetector(
                  onTap: () async {
                    if (formkey.currentState?.validate() ?? false) {
                      await registerUser(
                          nameController.text.trim(),
                          emailController.text.trim(),
                          int.parse(phoneController.text.trim()),
                          imageUrl);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 18),
                    height: 50,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(30)),
                    child: Center(
                      child: Text("Submit",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "Displaying Data",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("Users")
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          if (snapshot.data == null ||
                              snapshot.data!.docs.isEmpty) {
                            return Text('No data available');
                          } else {
                            List users = snapshot.data!.docs;
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {});
                              },
                              child: ListView.builder(
                                itemCount: users.length,
                                itemBuilder: (context, index) => ListTile(
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(
                                      users[index]['image'],
                                    ),
                                  ),
                                  trailing:
                                      Text(users[index]["Phone"].toString()),
                                  title: Text(users[index]['Name']),
                                  subtitle: Text(users[index]['Email'] ?? ""),
                                ),
                              ),
                            );
                          }
                        }
                      },
                    ))
              ],
            )),
      ),
    );
  }
}
