import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '/services.dart';

void main() {
  runApp(const AdminProfilePage());
}

// ignore: camel_case_types
class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminProfilePage createState() => _AdminProfilePage();
}

// ignore: camel_case_types
class _AdminProfilePage extends State<AdminProfilePage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _uidController = TextEditingController();
  final TextEditingController _firstnameController = TextEditingController();
  final TextEditingController _lastnameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String email = "";

  String images = "";

  @override
  void initState() {
    super.initState();
    // Fetch data based on the provided UID when the widget initializes
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              _idController.text = querySnapshot.docs.first.id;
              _uidController.text = userData['uid'] ?? '';
              _firstnameController.text = userData['firstname'] ?? '';
              _lastnameController.text = userData['lastname'] ?? '';
              _ageController.text = userData['age'] ?? '';
              _contactController.text = userData['contact'] ?? '';
              _addressController.text = userData['address'] ?? '';
              email = userData['email'] ?? '';

              images = userData['images'] ?? '';

              downloadURL = userData['images'] ?? '';

              // Update other controllers for other fields accordingly
            });
          } else {}
        } else {}
      } else {}
      // ignore: empty_catches
    } catch (e) {}
  }

  XFile? image;

  String downloadURL = "";

  Future<void> showImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    setState(() {
      image = img;
    });
    if (img != null) {
      await uploadFirebase(File(img.path));
    }
  }

  Future<void> uploadFirebase(File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Schedule the dialog to close after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });

        return AlertDialog(
          title: const Text('Waiting...'),
          content: const Text("Waiting to Upload Image to firebase"),
        );
      },
    );

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().toIso8601String()}.png');
      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        downloadURL = await storageRef.getDownloadURL();
        setState(() {
          print("Download URL: $downloadURL");
        });
      });
    } catch (e) {
      print("Error during upload: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScaffoldMessenger(
        key: _globalKey,
        child: Scaffold(
          body: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        showImage(ImageSource.gallery).then((value) {});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            image != null
                                ? Image.file(
                                    File(image!.path),
                                    width: 70,
                                    height: 70,
                                  )
                                : images != ''
                                    ? Image.network(
                                        images,
                                        width: 70,
                                        height: 70,
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.userCircle,
                                        size: 70,
                                      ),
                            const Text(
                              'Profile',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(82, 228, 228, 228),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          controller: _firstnameController,
                          decoration: const InputDecoration(
                              labelText: 'Firstname',
                              border: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(82, 228, 228, 228),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          controller: _lastnameController,
                          decoration: const InputDecoration(
                              labelText: 'Lastname',
                              border: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(82, 228, 228, 228),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                              labelText: 'Age',
                              border: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(82, 228, 228, 228),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          controller: _contactController,
                          decoration: const InputDecoration(
                              labelText: 'Contact',
                              border: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(82, 228, 228, 228),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                              labelText: 'Address',
                              border: InputBorder.none,
                              labelStyle: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        margin: const EdgeInsets.only(top: 30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 63, 157),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SizedBox(
                          child: TextButton(
                            onPressed: () {
                              Services()
                                  .updateAdminProfile(
                                _uidController.text,
                                _firstnameController.text,
                                _lastnameController.text,
                                _ageController.text,
                                _contactController.text,
                                _addressController.text,
                                downloadURL,
                                email,
                              )
                                  .then((value) {
                                var snackBar = const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('Success Update Profile'));
                                _globalKey.currentState?.showSnackBar(snackBar);
                              });
                            },
                            child: const Text(
                              'Save',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        )),
                    Container(margin: const EdgeInsets.only(bottom: 20))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
