import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ProfilePage());
}

// ignore: camel_case_types
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePage createState() => _ProfilePage();
}

// ignore: camel_case_types
class _ProfilePage extends State<ProfilePage> {
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
  String images2 = "";
  String images3 = "";

  String firstname = "";

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
              firstname = userData['firstname'] ?? '';
              _lastnameController.text = userData['lastname'] ?? '';
              _ageController.text = userData['age'] ?? '';
              _contactController.text = userData['contact'] ?? '';
              _addressController.text = userData['address'] ?? '';
              email = userData['email'] ?? '';

              images = userData['images'] ?? '';
              images2 = userData['images2'] ?? '';
              images3 = userData['images3'] ?? '';

              downloadURL = userData['images'] ?? '';
              downloadURL2 = userData['images2'] ?? '';
              downloadURL3 = userData['images3'] ?? '';

              // Update other controllers for other fields accordingly
              print(_firstnameController.text);
              print('asdsad');
            });

            print(_firstnameController.text);

            print('asdsad');
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

  XFile? image2;

  String downloadURL2 = "";

  Future<void> showImage2(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    setState(() {
      image2 = img;
    });
    if (img != null) {
      await uploadFirebase2(File(img.path));
    }
  }

  Future<void> uploadFirebase2(File imageFile) async {
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
        downloadURL2 = await storageRef.getDownloadURL();
        setState(() {
          print("Download URL: $downloadURL2");
        });
      });
    } catch (e) {
      print("Error during upload: $e");
    }
  }

  XFile? image3;

  String downloadURL3 = "";

  Future<void> showImage3(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    setState(() {
      image3 = img;
    });
    if (img != null) {
      await uploadFirebase3(File(img.path));
    }
  }

  Future<void> uploadFirebase3(File imageFile) async {
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
        downloadURL3 = await storageRef.getDownloadURL();
        setState(() {
          print("Download URL: $downloadURL3");
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
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 63, 157),
            title: const Text(
              'Profile',
              style: TextStyle(color: Colors.white),
            ),
          ),
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
                      alignment: Alignment.bottomLeft,
                      margin: const EdgeInsets.only(top: 20),
                      child: const Text(
                        "Valid ID's",
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showImage2(ImageSource.gallery).then((value) {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            image2 != null
                                ? Image.file(
                                    File(image2!.path),
                                  )
                                : images2 != ''
                                    ? Image.network(
                                        images2,
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.upload,
                                        size: 70,
                                      ),
                          ],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        showImage3(ImageSource.gallery).then((value) {});
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            image3 != null
                                ? Image.file(
                                    File(image3!.path),
                                  )
                                : images3 != ''
                                    ? Image.network(
                                        images3,
                                      )
                                    : const FaIcon(
                                        FontAwesomeIcons.upload,
                                        size: 70,
                                      ),
                          ],
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
                              // Services()
                              //     .Profile(
                              //   _uidController.text,
                              //   _firstnameController.text,
                              //   _lastnameController.text,
                              //   _ageController.text,
                              //   _contactController.text,
                              //   _addressController.text,
                              //   downloadURL,
                              //   downloadURL2,
                              //   downloadURL3,
                              //   email,
                              // )

                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user!.uid)
                                  .set({
                                'uid': user!.uid,
                                'firstname': _firstnameController.text,
                                'lastname': _lastnameController.text,
                                'age': _ageController.text,
                                'contact': _contactController.text,
                                'address': _addressController.text,
                                'images': downloadURL,
                                'images2': downloadURL2,
                                'images3': downloadURL3,
                                'type': 'customer',
                                'email': user!.email,
                              }).then((value) {
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
