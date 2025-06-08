import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MissingPetReportForm extends StatefulWidget {
  const MissingPetReportForm({Key? key}) : super(key: key);

  @override
  State<MissingPetReportForm> createState() => _MissingPetReportFormState();
}

class _MissingPetReportFormState extends State<MissingPetReportForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final _auth = FirebaseAuth.instance;

  // Form Controllers
  final TextEditingController _numberOfPetsController = TextEditingController();
  final TextEditingController _petNamesController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _colorMarkingsController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _circumstancesController = TextEditingController();
  final TextEditingController _collarDescriptionController = TextEditingController();
  final TextEditingController _medicalConditionsController = TextEditingController();

  // Form Variables
  DateTime? _reportDate;
  DateTime? _missingDate;
  TimeOfDay? _lastSeenTime;
  String _petType = '';
  String _gender = '';
  String _size = '';
  bool _wearingCollar = false;
  List<String> _temperament = [];
  List<XFile> _selectedImages = [];

  Future<void> SendReport() async {
    try {
      if (_missingDate == null || _lastSeenTime == "null") {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fill the Dates'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (_numberOfPetsController.text.isEmpty || _petNamesController.text.isEmpty || _petType.isEmpty || _breedController.text.isEmpty || _gender.isEmpty || _size.isEmpty || _ageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fill the Forms'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (_circumstancesController.text.isEmpty || _temperament.isEmpty || _medicalConditionsController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fill the Additional Details'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        List<String> imageUrls = [];
        if (_selectedImages.isNotEmpty) {
          for (int i = 0; i < _selectedImages.length; i++) {
            String fileName = 'pet_reports/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
            Reference storageRef = FirebaseStorage.instance.ref().child(fileName);

            UploadTask uploadTask = storageRef.putFile(File(_selectedImages[i].path));
            TaskSnapshot snapshot = await uploadTask;
            String downloadUrl = await snapshot.ref.getDownloadURL();
            imageUrls.add(downloadUrl);
          }
        }

        Map<String, dynamic> reportData = {
          'reportDate': _reportDate != null ? Timestamp.fromDate(_reportDate!) : Timestamp.now(),
          'missingDate': _missingDate != null ? Timestamp.fromDate(_missingDate!) : null,
          'lastSeenTime': _lastSeenTime != null
              ? {
                  'hour': _lastSeenTime!.hour,
                  'minute': _lastSeenTime!.minute,
                }
              : null,
          'numberOfPets': int.tryParse(_numberOfPetsController.text) ?? 1,
          'petNames': _petNamesController.text.trim(),
          'petType': _petType,
          'breed': _breedController.text.trim(),
          'gender': _gender,
          'size': _size,
          'colorMarkings': _colorMarkingsController.text.trim(),
          'age': _ageController.text.trim(),
          'circumstances': _circumstancesController.text.trim(),
          'wearingCollar': _wearingCollar,
          'collarDescription': _collarDescriptionController.text.trim(),
          'temperament': _temperament,
          'medicalConditions': _medicalConditionsController.text.trim(),
          'imageUrls': imageUrls,
          'imageCount': imageUrls.length,
          'createdAt': Timestamp.now(),
          'status': 'pending',
          'reportId': null,
          'userid': _auth.currentUser!.uid,
        };

        DocumentReference docRef = await FirebaseFirestore.instance.collection('pet_reports').add(reportData);

        // Update document with its own ID
        await docRef.update({'reportId': docRef.id});

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context, rootNavigator: true).pop();

        // Clear form or navigate away
        _clearForm();
      }
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting report: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error sending report: $e');
    }
  }

  void _clearForm() {
    // Clear all controllers
    _numberOfPetsController.clear();
    _petNamesController.clear();
    _breedController.clear();
    _colorMarkingsController.clear();
    _ageController.clear();
    _circumstancesController.clear();
    _collarDescriptionController.clear();
    _medicalConditionsController.clear();

    // Reset form variables
    setState(() {
      _reportDate = null;
      _missingDate = null;
      _lastSeenTime = null;
      _petType = '';
      _gender = '';
      _size = '';
      _wearingCollar = false;
      _temperament = [];
      _selectedImages = [];
    });

    // Reset form validation
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Missing Pet Report'),
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
              _buildSectionTitle('Pet Information'),
              _buildRequiredTextField(
                'Number of missing pets',
                _numberOfPetsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              _buildPetTypeSelection(),
              const SizedBox(height: 16),
              _buildRequiredTextField(
                'Pet Name/s',
                _petNamesController,
                hintText: 'Example: "Max, Bella, Oreo"',
              ),
              const SizedBox(height: 16),
              _buildRequiredTextField(
                'Breed (if same or mixed)',
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
              _buildRequiredTextField(
                'Age (or estimate)',
                _ageController,
              ),
              const SizedBox(height: 16),
              _buildSizeSelection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Last Seen Details'),
              _buildDatePicker(
                'Date Missing',
                _missingDate,
                (date) => setState(() => _missingDate = date),
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTimePicker(),
              const SizedBox(height: 16),
              _buildLocationInfo(),
              const SizedBox(height: 16),
              _buildTextField(
                'Circumstances',
                _circumstancesController,
                hintText: 'e.g., escaped from yard, ran out of gate',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('Identification & Accessories'),
              _buildCollarSection(),
              const SizedBox(height: 24),
              _buildSectionTitle('Behavior & Health'),
              _buildTemperamentSelection(),
              const SizedBox(height: 16),
              _buildTextField(
                'Medical Conditions/Special Needs',
                _medicalConditionsController,
                maxLines: 3,
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

  Widget _buildTimePicker() {
    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: _lastSeenTime ?? TimeOfDay.now(),
        );
        if (picked != null) {
          setState(() => _lastSeenTime = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Time Last Seen *',
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.blue),
        ),
        child: Text(
          _lastSeenTime != null ? _lastSeenTime!.format(context) : 'Select time',
          style: TextStyle(
            color: _lastSeenTime != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildPetTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type of Pet: *',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _petType.contains('Dog'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _petType = 'Dog'; // Fixed: was _petType == 'Dog'
                      }
                    });
                  },
                ),
                const Text('Dog'),
              ],
            ),
            const SizedBox(width: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _petType.contains('Cat'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _petType = 'Cat';
                      }
                    });
                  },
                ),
                const Text('Cat'),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Checkbox(
                  value: _petType.contains('Both'),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _petType = 'Both';
                      }
                    });
                  },
                ),
                const Text('Both'),
              ],
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
        const Text(
          'Location Last Seen:',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('City: City of San Pedro, Laguna'),
              SizedBox(height: 4),
              Text('Barangay: Pacita 1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCollarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Wearing Collar/Tag:',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('Yes'),
                value: true,
                groupValue: _wearingCollar,
                onChanged: (value) => setState(() => _wearingCollar = value!),
              ),
            ),
            Expanded(
              child: RadioListTile<bool>(
                title: const Text('No'),
                value: false,
                groupValue: _wearingCollar,
                onChanged: (value) => setState(() => _wearingCollar = value!),
              ),
            ),
          ],
        ),
        if (_wearingCollar) ...[
          const SizedBox(height: 8),
          _buildTextField(
            'Description of Collar/Tag',
            _collarDescriptionController,
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildTemperamentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Temperament:',
          style: TextStyle(fontSize: 16, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        Wrap(
          children: ['Friendly', 'Shy', 'Aggressive', 'Mixed'].map((temp) {
            return CheckboxListTile(
              title: Text(temp),
              value: _temperament.contains(temp),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _temperament.add(temp);
                  } else {
                    _temperament.remove(temp);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Attach clear, recent photo/s of the missing pet/s'),
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
        onPressed: () => SendReport(),
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
      if (_petType.isEmpty) {
        _showErrorDialog('Please select the type of pet');
        return;
      }
      if (_missingDate == null) {
        _showErrorDialog('Please select the date the pet went missing');
        return;
      }
      if (_lastSeenTime == null) {
        _showErrorDialog('Please select the time the pet was last seen');
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
          content: const Text('Missing pet report submitted successfully!'),
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

  @override
  void dispose() {
    _numberOfPetsController.dispose();
    _petNamesController.dispose();
    _breedController.dispose();
    _colorMarkingsController.dispose();
    _ageController.dispose();
    _circumstancesController.dispose();
    _collarDescriptionController.dispose();
    _medicalConditionsController.dispose();
    super.dispose();
  }
}
