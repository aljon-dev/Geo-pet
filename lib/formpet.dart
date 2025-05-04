import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/adminbottom.dart'; // Assuming bottom.dart for BottomPage navigation
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AdminFormPetPage(),
  ));
}

class AdminFormPetPage extends StatefulWidget {
  const AdminFormPetPage({super.key});

  @override
  _AdminFormPetPageState createState() => _AdminFormPetPageState();
}

class _AdminFormPetPageState extends State<AdminFormPetPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  final user = FirebaseAuth.instance.currentUser;

  final TextEditingController typeController = TextEditingController();
  final TextEditingController pet_nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController arrivaldateController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController sexController = TextEditingController();

  // New Controllers for additional information
  final TextEditingController rescueLocationController =
      TextEditingController();
  final TextEditingController firstOwnerController = TextEditingController();
  final TextEditingController healthIssuesController = TextEditingController();
  final TextEditingController additionalDetailsController =
      TextEditingController();

  String images = "";
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
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });

        return const AlertDialog(
          title: Text('Waiting...'),
          content: Text("Waiting to Upload Image to Firebase"),
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
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 0, 63, 157),
            title: Row(
              children: [
                GestureDetector(
                  child: const Icon(
                    Icons.arrow_back,
                    size: 40,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminBottomPage(),
                        ));
                  },
                ),
                const Text(
                  'Pet Form',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          body: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                        FontAwesomeIcons.image,
                                        size: 70,
                                      ),
                            const Text(
                              'Add Image of Pet',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    buildTextField('Type', typeController),
                    buildTextField('pet_name', pet_nameController),
                    buildTextField('Age', ageController),
                    buildTextField('Color', colorController),
                    buildTextField('Arrival Date', arrivaldateController),
                    buildTextField('Size Weight', sizeController),
                    buildTextField('Sex', sexController),
                    buildTextField('Rescue Location', rescueLocationController),
                    buildTextField('First Owner', firstOwnerController),
                    buildTextField('Health Issues', healthIssuesController,
                        maxLines: 3),
                    buildTextField(
                        'Additional Details', additionalDetailsController,
                        maxLines: 3),
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
                            FirebaseFirestore.instance
                                .collection('pet')
                                .doc()
                                .set({
                              'type': typeController.text,
                              'pet_name': pet_nameController.text,
                              'age': ageController.text,
                              'color': colorController.text,
                              'arrivaldate': arrivaldateController.text,
                              'size': sizeController.text,
                              'sex': sexController.text,
                              'rescue_location': rescueLocationController.text,
                              'first_owner': firstOwnerController.text,
                              'health_issues': healthIssuesController.text,
                              'additional_details':
                                  additionalDetailsController.text,
                              'images': downloadURL,
                              'status': 'Available',
                            }).then((value) {
                              var snackBar = const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text('Pet submitted successfully'));
                              _globalKey.currentState?.showSnackBar(snackBar);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AdminBottomPage()));
                            });
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                        ),
                      ),
                    ),
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

  Widget buildTextField(String labelText, TextEditingController controller,
      {int maxLines = 1}) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
          color: const Color.fromARGB(82, 228, 228, 228),
          borderRadius: BorderRadius.circular(30)),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
            labelText: labelText,
            border: InputBorder.none,
            labelStyle: const TextStyle(color: Colors.black)),
      ),
    );
  }
}
