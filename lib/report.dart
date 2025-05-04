import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/bottom.dart';
import 'package:geopawsfinal/home.dart';
import 'package:geopawsfinal/welcome.dart';
import 'package:image_picker/image_picker.dart';
import 'services.dart'; // Import Services

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ReportFormPage(),
  ));
}

class ReportFormPage extends StatefulWidget {
  const ReportFormPage({super.key});

  @override
  _ReportFormPageState createState() => _ReportFormPageState();
}

class _ReportFormPageState extends State<ReportFormPage> {
  final _formKey = GlobalKey<FormState>();

  List<String> reportType = ['Stray', 'Missing'];

  String Type = 'Stray';

  // Controllers
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final animalDescriptionController = TextEditingController();
  final locationController = TextEditingController();
  final dateTimeController = TextEditingController();
  final conditionController = TextEditingController();
  final dangerDescriptionController = TextEditingController();
  final approxAnimalsController = TextEditingController();
  final otherAnimalTypeController = TextEditingController();
  final otherBehaviorController = TextEditingController();

  // Checkboxes
  bool isDog = false;
  bool isCat = false;

  bool isFriendly = false;
  bool isShy = false;
  bool isAggressive = false;
  bool isInjured = false;
  bool isSick = false;

  bool animalStillThereYes = false;
  bool animalStillThereNo = false;
  bool animalStillThereUnknown = false;

  bool immediateDangerYes = false;
  bool immediateDangerNo = false;

  bool canSecureAnimalYes = false;
  bool canSecureAnimalNo = false;

  // Image
  File? _imageFile;

  @override
  void dispose() {
    // Clean up controllers
    fullNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    animalDescriptionController.dispose();
    locationController.dispose();
    dateTimeController.dispose();
    conditionController.dispose();
    dangerDescriptionController.dispose();
    approxAnimalsController.dispose();
    otherAnimalTypeController.dispose();
    otherBehaviorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a photo')),
      );
      return;
    }

    // Check if at least one animal type is selected
    if (!isDog && !isCat) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one animal type')),
      );
      return;
    }

    // Check if a valid animal still there option is selected
    if (!animalStillThereYes &&
        !animalStillThereNo &&
        !animalStillThereUnknown) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select if the animal is still there')),
      );
      return;
    }

    // Check if a valid danger option is selected
    if (!immediateDangerYes && !immediateDangerNo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please select if the animal is in immediate danger')),
      );
      return;
    }

    // Check if a valid secure animal option is selected
    if (!canSecureAnimalYes && !canSecureAnimalNo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select if you can secure the animal')),
      );
      return;
    }

    try {
      // Upload image to Firebase Storage
      final imageName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef =
          FirebaseStorage.instance.ref().child('report_images/$imageName.jpg');
      await storageRef.putFile(_imageFile!);
      final imageUrl = await storageRef.getDownloadURL();

      // Save data to Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'user_id': FirebaseAuth.instance.currentUser!.uid,
        'status': 'In Progress',
        'name': fullNameController.text,
        'phone': phoneController.text,
        'email': emailController.text,
        'report_type': Type,
        'typeOfAnimal': {
          'dog': isDog,
          'cat': isCat,
        },
        'approximateNumber': approxAnimalsController.text,
        'description': animalDescriptionController.text,
        'behaviorObserved': {
          'friendly': isFriendly,
          'shy': isShy,
          'aggressive': isAggressive,
          'injured': isInjured,
          'sick': isSick,
          'other': otherBehaviorController.text,
        },
        'condition': conditionController.text,
        'location': locationController.text,
        'dateTimeSpotted': dateTimeController.text,
        'animalStillThere': animalStillThereYes
            ? 'Yes'
            : animalStillThereNo
                ? 'No'
                : 'Unknown',
        'immediateDanger': immediateDangerYes ? 'Yes' : 'No',
        'dangerDescription': dangerDescriptionController.text,
        'canSecureAnimal': canSecureAnimalYes ? 'Yes' : 'No',
        'photoUrl': imageUrl,
        'submittedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!')),
      );

      // Optionally clear the form
      _formKey.currentState!.reset();
      setState(() {
        _imageFile = null;

        isFriendly = isShy = isAggressive = isInjured = isSick = false;
        animalStillThereYes =
            animalStillThereNo = animalStillThereUnknown = false;
        immediateDangerYes = immediateDangerNo = false;
        canSecureAnimalYes = canSecureAnimalNo = false;
      });
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit report')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => BottomPage()));
            },
            icon: Icon(Icons.arrow_back)),
        title: const Text('🐾 Reporting Form'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Reporter Information',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              TextFormField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  hintText: 'Enter your full name',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number *',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'Enter your email address (optional)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Simple email validation regex
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Report Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: 55, // increased height
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: Type,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: reportType.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        Type = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Pet Information',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Type of Animal *',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Dog'),
                      value: isDog,
                      onChanged: (value) => setState(() => isDog = value!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Cat'),
                      value: isCat,
                      onChanged: (value) => setState(() => isCat = value!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: approxAnimalsController,
                decoration: const InputDecoration(
                  labelText: 'Approximate Number of Animals *',
                  hintText: 'How many animals did you see?',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty
                    ? 'Please enter the approximate number'
                    : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: animalDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (breed, color, size, etc.) *',
                  hintText: 'Describe the animal(s)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Please describe the animal' : null,
              ),
              const SizedBox(height: 10),
              const Text('Behavior Observed',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      title: const Text('Friendly'),
                      value: isFriendly,
                      onChanged: (val) => setState(() => isFriendly = val!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Shy'),
                      value: isShy,
                      onChanged: (val) => setState(() => isShy = val!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Aggressive'),
                      value: isAggressive,
                      onChanged: (val) => setState(() => isAggressive = val!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Injured'),
                      value: isInjured,
                      onChanged: (val) => setState(() => isInjured = val!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Sick'),
                      value: isSick,
                      onChanged: (val) => setState(() => isSick = val!),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: otherBehaviorController,
                decoration: const InputDecoration(
                  labelText: 'Other Behavior (optional)',
                  hintText: 'Any other behavior you observed',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: conditionController,
                decoration: const InputDecoration(
                  labelText: 'Animal Condition *',
                  hintText: 'Describe the animal\'s condition',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                maxLines: 2,
                validator: (value) => value!.isEmpty
                    ? 'Please describe the animal\'s condition'
                    : null,
              ),
              const SizedBox(height: 20),
              const Text('Location Details',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              TextFormField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Exact Location or Landmark *',
                  hintText: 'Where did you see the animal(s)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the location' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: dateTimeController,
                decoration: const InputDecoration(
                  labelText: 'Date and Time Spotted *',
                  hintText: 'When did you see the animal(s)',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter the date and time' : null,
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Is the animal still there? *',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Yes'),
                      value: animalStillThereYes,
                      onChanged: (val) => setState(() {
                        animalStillThereYes = val!;
                        if (val) {
                          animalStillThereNo = false;
                          animalStillThereUnknown = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('No'),
                      value: animalStillThereNo,
                      onChanged: (val) => setState(() {
                        animalStillThereNo = val!;
                        if (val) {
                          animalStillThereYes = false;
                          animalStillThereUnknown = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('Unknown'),
                      value: animalStillThereUnknown,
                      onChanged: (val) => setState(() {
                        animalStillThereUnknown = val!;
                        if (val) {
                          animalStillThereYes = false;
                          animalStillThereNo = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Additional Information',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue)),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Is the animal in immediate danger? *',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Yes'),
                      value: immediateDangerYes,
                      onChanged: (val) => setState(() {
                        immediateDangerYes = val!;
                        if (val) {
                          immediateDangerNo = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('No'),
                      value: immediateDangerNo,
                      onChanged: (val) => setState(() {
                        immediateDangerNo = val!;
                        if (val) {
                          immediateDangerYes = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: dangerDescriptionController,
                decoration: const InputDecoration(
                  labelText: 'Describe the Danger (if applicable)',
                  hintText: 'Describe any immediate danger',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (immediateDangerYes && (value == null || value.isEmpty)) {
                    return 'Please describe the danger';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Can you secure the animal safely? *',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    CheckboxListTile(
                      title: const Text('Yes'),
                      value: canSecureAnimalYes,
                      onChanged: (val) => setState(() {
                        canSecureAnimalYes = val!;
                        if (val) {
                          canSecureAnimalNo = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: const Text('No'),
                      value: canSecureAnimalNo,
                      onChanged: (val) => setState(() {
                        canSecureAnimalNo = val!;
                        if (val) {
                          canSecureAnimalYes = false;
                        }
                      }),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Upload Photo *',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    if (_imageFile != null)
                      Image.file(
                        _imageFile!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(
                          _imageFile == null ? 'Upload Photo' : 'Change Photo'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Submit Report'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
