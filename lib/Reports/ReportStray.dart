import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StrayAnimalReportForm extends StatefulWidget {
  const StrayAnimalReportForm({Key? key}) : super(key: key);

  @override
  State<StrayAnimalReportForm> createState() => _StrayAnimalReportFormState();
}

class _StrayAnimalReportFormState extends State<StrayAnimalReportForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final TextEditingController _numberOfAnimalsController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorMarkingsController = TextEditingController();
  final TextEditingController _otherBehaviorController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();

  // Form Variables
  DateTime? _reportDate;
  DateTime? _seenDate;
  TimeOfDay? _seenTime;
  String _animalType = '';
  String _gender = '';
  String _size = '';
  List<String> _behaviorObserved = [];
  List<XFile> _selectedImages = [];

  // Upload images to Firebase Storage
  Future<List<String>> _uploadImages() async {
    List<String> imageUrls = [];

    if (_selectedImages.isEmpty) return imageUrls;

    try {
      for (int i = 0; i < _selectedImages.length; i++) {
        String fileName = 'animal_reports/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

        UploadTask uploadTask = storageRef.putFile(File(_selectedImages[i].path));
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        imageUrls.add(downloadUrl);
      }
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Failed to upload images');
    }

    return imageUrls;
  }

  Future<void> SendReportStray() async {
    try {
      // Validate form
      if (!_formKey.currentState!.validate()) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Fix the behavior list logic
      List<String> AllBehavior = [];
      AllBehavior.addAll(_behaviorObserved); // Add selected behaviors

      // Add other behavior if not empty
      if (_otherBehaviorController.text.isNotEmpty) {
        AllBehavior.add(_otherBehaviorController.text.trim());
      }

      // Upload images first
      List<String> imageUrls = await _uploadImages();

      // Prepare data for Firestore
      Map<String, dynamic> reportData = {
        'reportDate': _reportDate != null ? Timestamp.fromDate(_reportDate!) : null,
        'seenDate': _seenDate != null ? Timestamp.fromDate(_seenDate!) : null,
        'seenTime': _seenTime != null
            ? {
                'hour': _seenTime!.hour,
                'minute': _seenTime!.minute,
              }
            : null,
        'animalType': _animalType,
        'numberOfAnimals': _numberOfAnimalsController.text.trim(),
        'breed': _breedController.text.trim(),
        'gender': _gender,
        'size': _size,
        'colorMarkings': _colorMarkingsController.text.trim(),
        'behaviorObserved': AllBehavior,
        'additionalNotes': _additionalNotesController.text.trim(),
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Send to Firestore
      DocumentReference docRef = await FirebaseFirestore.instance.collection('animal_reports').add(reportData);

      // Close loading dialog
      Navigator.of(context).pop();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      print('Report submitted with ID: ${docRef.id}');

      // Optional: Clear form after successful submission
      _clearForm();
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );

      print('Error in SendReportStary: $e');
    }
  }

  // Helper function to clear form
  void _clearForm() {
    _numberOfAnimalsController.clear();
    _breedController.clear();
    _colorMarkingsController.clear();
    _otherBehaviorController.clear();
    _additionalNotesController.clear();

    setState(() {
      _reportDate = null;
      _seenDate = null;
      _seenTime = null;
      _animalType = '';
      _gender = '';
      _size = '';
      _behaviorObserved.clear();
      _selectedImages.clear();
    });
  }

  @override
  void dispose() {
    _numberOfAnimalsController.dispose();
    _breedController.dispose();
    _colorMarkingsController.dispose();
    _otherBehaviorController.dispose();
    _additionalNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stray Animal Report'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Report Information'),
              _buildDatePicker(
                'Date of Report',
                _reportDate,
                (date) => setState(() => _reportDate = date),
                required: true,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Animal Information'),
              _buildRequiredTextField(
                'Number of stray animal seen',
                _numberOfAnimalsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildAnimalTypeSelection(),
              const SizedBox(height: 16),
              _buildRequiredTextField(
                'Breed (if known or mixed)',
                _breedController,
              ),
              const SizedBox(height: 16),
              _buildRequiredTextField(
                'Color/Markings',
                _colorMarkingsController,
              ),
              const SizedBox(height: 16),
              _buildGenderSelection(),
              const SizedBox(height: 16),
              _buildSizeSelection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Location Details'),
              _buildLocationInfo(),
              const SizedBox(height: 16),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _buildSectionTitle('Behavior Observed'),
              _buildBehaviorSelection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Additional Information'),
              _buildTextField(
                'Condition or Additional Notes',
                _additionalNotesController,
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Upload Photo'),
              _buildPhotoUpload(),
              const SizedBox(height: 32),
              _buildSubmitButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildRequiredTextField(
    String label,
    TextEditingController controller, {
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: '$label *',
        hintText: hintText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.blue),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        return null;
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        labelStyle: const TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected, {
    bool required = false,
  }) {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          onDateSelected(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          border: const OutlineInputBorder(),
          labelStyle: const TextStyle(color: Colors.blue),
        ),
        child: Text(
          selectedDate != null ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}' : 'Select date',
          style: TextStyle(
            color: selectedDate != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date and Time Seen: *',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _seenDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _seenDate = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date *',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                  child: Text(
                    _seenDate != null ? '${_seenDate!.day}/${_seenDate!.month}/${_seenDate!.year}' : 'Select date',
                    style: TextStyle(
                      color: _seenDate != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _seenTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => _seenTime = picked);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Time *',
                    border: OutlineInputBorder(),
                    labelStyle: TextStyle(color: Colors.blue),
                  ),
                  child: Text(
                    _seenTime != null ? _seenTime!.format(context) : 'Select time',
                    style: TextStyle(
                      color: _seenTime != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimalTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type of Animal: *',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Dog'),
                value: _animalType.contains('Dog'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (_animalType == 'Cat') {
                        _animalType = 'Both';
                      } else {
                        _animalType = 'Dog';
                      }
                    } else {
                      if (_animalType == 'Both') {
                        _animalType = 'Cat';
                      } else {
                        _animalType = '';
                      }
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Cat'),
                value: _animalType.contains('Cat'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      if (_animalType == 'Dog') {
                        _animalType = 'Both';
                      } else {
                        _animalType = 'Cat';
                      }
                    } else {
                      if (_animalType == 'Both') {
                        _animalType = 'Dog';
                      } else {
                        _animalType = '';
                      }
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender:',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Male'),
                value: 'Male',
                groupValue: _gender,
                onChanged: (value) => setState(() => _gender = value!),
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Female'),
                value: 'Female',
                groupValue: _gender,
                onChanged: (value) => setState(() => _gender = value!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size:',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 140,
                child: RadioListTile<String>(
                  title: const Text('Small'),
                  value: 'Small',
                  groupValue: _size,
                  onChanged: (value) => setState(() => _size = value!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 140,
                child: RadioListTile<String>(
                  title: const Text('Medium'),
                  value: 'Medium',
                  groupValue: _size,
                  onChanged: (value) => setState(() => _size = value!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              SizedBox(
                width: 140,
                child: RadioListTile<String>(
                  title: const Text('Large'),
                  value: 'Large',
                  groupValue: _size,
                  onChanged: (value) => setState(() => _size = value!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('City: City of San Pedro, Laguna'),
              SizedBox(height: 4),
              Text('Barangay: Pacita 1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          children: ['Friendly', 'Aggressive', 'Injured', 'Sickly', 'Roaming Pack'].map((behavior) {
            return SizedBox(
              width: MediaQuery.of(context).size.width * 0.45,
              child: CheckboxListTile(
                title: Text(behavior),
                value: _behaviorObserved.contains(behavior),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _behaviorObserved.add(behavior);
                    } else {
                      _behaviorObserved.remove(behavior);
                    }
                  });
                },
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 150,
              child: CheckboxListTile(
                title: const Text('Other:'),
                value: _behaviorObserved.contains('Other'),
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      _behaviorObserved.add('Other');
                    } else {
                      _behaviorObserved.remove('Other');
                      _otherBehaviorController.clear();
                    }
                  });
                },
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: _otherBehaviorController,
                enabled: _behaviorObserved.contains('Other'),
                decoration: const InputDecoration(
                  hintText: 'Specify other behavior',
                  border: OutlineInputBorder(),
                  labelStyle: TextStyle(color: Colors.blue),
                ),
                validator: (value) {
                  if (_behaviorObserved.contains('Other') && (value == null || value.isEmpty)) {
                    return 'Please specify the behavior';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attach photo/s of the stray animal'),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Select Photos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[100],
            foregroundColor: Colors.blue[700],
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _selectedImages.map((image) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(image.path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.remove(image);
                        });
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => SendReportStray(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Submit Report',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    setState(() {
      _selectedImages.addAll(images);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Validate required fields that aren't handled by TextFormField
      if (_reportDate == null) {
        _showErrorDialog('Please select the report date');
        return;
      }
      if (_animalType.isEmpty) {
        _showErrorDialog('Please select the type of animal');
        return;
      }
      if (_seenDate == null) {
        _showErrorDialog('Please select the date the animal was seen');
        return;
      }
      if (_seenTime == null) {
        _showErrorDialog('Please select the time the animal was seen');
        return;
      }

      // Form is valid, process the data
      _showSuccessDialog();
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Stray animal report submitted successfully!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Reset form or navigate to another page
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
