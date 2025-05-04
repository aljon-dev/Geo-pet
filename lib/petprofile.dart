import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/bottom.dart';
import 'package:geopawsfinal/pet2.dart';

class PetProfilePage extends StatefulWidget {
  final docId;
  const PetProfilePage({super.key, required this.docId});

  @override
  _PetProfilePage createState() => _PetProfilePage();
}

class _PetProfilePage extends State<PetProfilePage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();

  String type = "";
  String pet_name = "";
  String age = "";
  String color = "";
  String arrivaldate = "";
  String size = "";
  String sex = "";
  String images = "";
  String microchipped = '';
  String rescue_story = '';
  String medical_conditions = '';
  String temperament = '';
  String training_level = '';
  String vaccinated = '';
  String good_with = '';
  String dewormed = '';
  String rescueStory = '';
  String neutered = '';
  String Breed = '';
  String skin = '';
  String appearance = '';
  String background = '';

  String fullname = "";
  String validId = "";

  // Form controllers
  final _nameController = TextEditingController();
  final _otherStayController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();

  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Household information
  String _residenceType = 'House';
  String _ownership = 'Own';
  String _landlordAllowsPets = 'Yes';
  final _adultsController = TextEditingController();
  final _childrenController = TextEditingController();
  String _allergies = 'No';
  final _allergiesExplanationController = TextEditingController();

  // Pet Preferences
  final _petNameController = TextEditingController();
  String _petType = 'Dog';
  String _petAge = 'Young';
  String _petSize = 'Medium';

  // Care & Commitment
  String _currentPets = 'No';
  final _currentPetsDetailsController = TextEditingController();
  String _pastPets = 'No';
  final _pastPetsDetailsController = TextEditingController();
  final _hoursAloneController = TextEditingController();
  String _petStayWhenAway = 'Indoors';
  final _petSleepLocationController = TextEditingController();
  String _financialResponsibility = 'Yes';

  // References
  final _vetNameController = TextEditingController();
  final _vetPhoneController = TextEditingController();
  final _refNameController = TextEditingController();
  final _refPhoneController = TextEditingController();

  void dispose() {
    // Dispose all controllers
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();

    _phoneController.dispose();
    _emailController.dispose();
    _adultsController.dispose();
    _childrenController.dispose();
    _allergiesExplanationController.dispose();
    _petNameController.dispose();
    _currentPetsDetailsController.dispose();
    _pastPetsDetailsController.dispose();
    _hoursAloneController.dispose();
    _petSleepLocationController.dispose();
    _vetNameController.dispose();
    _vetPhoneController.dispose();
    _refPhoneController.dispose();
    _otherStayController.dispose();
    super.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchData();
    userfetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('pet')
          .doc(widget.docId)
          .get();

      if (documentSnapshot.exists) {
        var userData = documentSnapshot.data() as Map<String, dynamic>;

        setState(() {
          type = userData['type'] ?? '';
          pet_name = userData['pet_name'] ?? '';
          age = userData['age'] ?? '';
          color = userData['color'] ?? '';
          arrivaldate = userData['arrivaldate'] ?? '';
          size = userData['size'] ?? '';
          sex = userData['sex'] ?? '';
          images = userData['images'] ?? '';

          microchipped = userData['microchipped'] ?? '';
          rescue_story = userData['rescue_story'] ?? '';
          medical_conditions = userData['medical_conditions'] ?? '';
          temperament = userData['temperament'] ?? '';
          training_level = userData['training_level'] ?? '';
          vaccinated = userData['vaccinated'] ?? '';

          Breed = userData['breed'] ?? 'None';
          background = userData['background'] ?? 'None';
          skin = userData['skin_condition'] ?? 'None';
          appearance = userData['appearance'] ?? 'No Data';

          print(' TEST ${userData}');
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> userfetchData() async {
    final user = FirebaseAuth.instance.currentUser;

    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();

      if (documentSnapshot.exists) {
        var userData = documentSnapshot.data() as Map<String, dynamic>;

        setState(() {
          String firstname = userData['firstname'] ?? '';
          String lastname = userData['lastname'] ?? '';
          fullname = '$firstname $lastname';
          validId = userData['images3'] ?? '';
          _nameController.text = fullname;
        });
      } else {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ScaffoldMessenger(
        key: _globalKey,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue, // Set background to blue
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.white), // Set back icon to white
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetPage(),
                  ),
                );
              },
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: Image.network(
                        images,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildInfoCard('Age', age),
                              _buildInfoCard('Size', size),
                              _buildInfoCard('Sex', sex),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _SectionHeader(Colors.green,
                              Icons.library_books_outlined, 'Pet Information'),
                          const SizedBox(height: 5),
                          _buildInfoRow('Pet Name', pet_name),
                          _buildInfoRow('Arrival Date', arrivaldate),
                          _buildInfoRow('Breed', Breed),
                          _buildInfoRow('Type', type),
                          _buildInfoRow('Color', color),
                          const SizedBox(height: 5),
                          _SectionHeader(
                              Colors.red,
                              Icons.health_and_safety_sharp,
                              'Health Information'),
                          const SizedBox(height: 5),
                          _buildInfoRow('Vaccinated', vaccinated),
                          _buildInfoRow('Skin Condition', skin),
                          _buildInfoRow('Appearance', appearance),
                          const SizedBox(height: 5),
                          _SectionHeader(Colors.blue, Icons.catching_pokemon,
                              'Personality'),
                          _buildInfoRow('Temperament', temperament),
                          const SizedBox(
                            height: 5,
                          ),
                          _SectionHeader(
                              Colors.yellow, Icons.history_edu, 'Background'),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 80,
                            width: double.infinity,
                            child: Text(background),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.pets, color: Colors.white),
                  label: const Text('Adopt',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  onPressed: () {
                    if (validId == '') {
                      const snackbar = SnackBar(
                        content: Text(
                          'Please upload Valid Id First',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      );
                      _globalKey.currentState!.showSnackBar(snackbar);
                    } else {
                      _showConfirmationDialog(context, user);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _SectionHeader(Color color, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: color),
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ],
    );
  }

  void _showConfirmationDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure you want to adopt this pet?"),
          content: const Text(
              "Adopting a pet is a big responsibility and a long-term commitment. This furry friend will rely on you for love, care, and support for many years to come. Please confirm that you are ready to welcome this pet into your home and provide the necessary care and attention they deserve."),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("Yes"),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('request')
                    .where('petId', isEqualTo: widget.docId)
                    .where('status', isEqualTo: 'Pending')
                    .get()
                    .then((QuerySnapshot querySnapshot) {
                  if (querySnapshot.docs.isEmpty) {
                    FirebaseFirestore.instance.collection('request').add({
                      'petId': widget.docId,
                      'uid': user!.uid,
                      'fullname': fullname,
                      'status': 'Pending'
                    });

                    // Close the dialog
                    var snackBar = const SnackBar(
                      backgroundColor: Colors.green,
                      content:
                          Text('Success Request Adopt Waiting for approval'),
                    );
                    _globalKey.currentState?.showSnackBar(snackBar);
                  } else {
                    var snackBar = const SnackBar(
                      content: Text('Already Requested'),
                    );
                    _globalKey.currentState?.showSnackBar(snackBar);
                  }
                }).catchError((error) {
                  print("Error getting documents: $error");
                });

                showFormDialog(context, user);
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
          ],
        );
      },
    );
  }

  void showFormDialog(BuildContext context, User? user) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
        ),
        builder: (BuildContext context) {
          bool isChecked = false;
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              height: MediaQuery.of(context).size.height * 0.9,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with close button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 40),
                        const Expanded(
                          child: Center(
                            child: Text(
                              'Pet Adoption Form',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),

                    // Form content in scrollable area
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Banner/Header
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.shade50,
                                    Colors.blue.shade100
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.pets,
                                      size: 40, color: Colors.blue),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '🐾 New Pet Application',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Please complete this form to help us find the perfect pet for your home',
                                          style: TextStyle(fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Section Headers with nice styling
                            _buildSectionHeader('Applicant Information'),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _nameController,
                              label: 'Full Name',
                              isRequired: true,
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _dobController,
                              label: 'Date of Birth',
                              hintText: 'MM/DD/YYYY',
                              isRequired: true,
                              prefixIcon: Icons.calendar_today,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _addressController,
                              label: 'Address',
                              isRequired: true,
                              prefixIcon: Icons.home,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              isRequired: true,
                              prefixIcon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _emailController,
                              label: 'Email Address',
                              isRequired: true,
                              prefixIcon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),

                            // Household Information
                            _buildSectionHeader('Household Information'),
                            const SizedBox(height: 16),

                            _buildRadioQuestion(
                              question: 'Do you own or rent your home?',
                              groupValue: _ownership,
                              options: const ['Own', 'Rent'],
                              onChanged: (value) {
                                setModalState(() {
                                  _ownership = value!;
                                });
                              },
                            ),

                            if (_ownership == 'Rent')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildRadioQuestion(
                                    question:
                                        'If renting, does your landlord allow pets?',
                                    groupValue: _landlordAllowsPets,
                                    options: const ['Yes', 'No', 'Not Sure'],
                                    onChanged: (value) {
                                      setModalState(() {
                                        _landlordAllowsPets = value!;
                                      });
                                    },
                                  ),
                                ],
                              ),

                            const SizedBox(height: 16),
                            _buildRadioQuestion(
                              question: 'Type of residence:',
                              groupValue: _residenceType,
                              options: const ['House', 'Apartment', 'Condo'],
                              onChanged: (value) {
                                setModalState(() {
                                  _residenceType = value!;
                                });
                              },
                            ),

                            const SizedBox(height: 16),
                            _buildInputField(
                              controller: _adultsController,
                              label: 'How many adults live in your home?',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _childrenController,
                              label: 'How many children (and their ages)?',
                              hintText: 'e.g., 2 children (5 and 8 years old)',
                            ),
                            const SizedBox(height: 16),

                            _buildRadioQuestion(
                              question:
                                  'Is anyone in the household allergic to animals?',
                              groupValue: _allergies,
                              options: const ['Yes', 'No'],
                              onChanged: (value) {
                                setModalState(() {
                                  _allergies = value!;
                                });
                              },
                            ),

                            if (_allergies == 'Yes')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildInputField(
                                    controller: _allergiesExplanationController,
                                    label: 'Please explain:',
                                    isRequired: true,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),

                            // Pet Preferences
                            _buildSectionHeader('Pet Preferences'),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _petNameController,
                              label:
                                  'Which pet are you interested in adopting?',
                              hintText: 'Name/ID if available',
                              prefixIcon: Icons.favorite,
                            ),
                            const SizedBox(height: 16),

                            _buildRadioQuestion(
                              question: 'Preferred type of pet:',
                              groupValue: _petType,
                              options: const ['Dog', 'Cat', 'Other'],
                              onChanged: (value) {
                                setModalState(() {
                                  _petType = value!;
                                });
                              },
                            ),

                            const SizedBox(height: 16),
                            const Text('Preferred age of pet:',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16.0,
                              children: [
                                _buildRadioButton(
                                  label: 'Puppy/Kitten',
                                  groupValue: _petAge,
                                  value: 'Puppy/Kitten',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petAge = value!;
                                    });
                                  },
                                ),
                                _buildRadioButton(
                                  label: 'Young',
                                  groupValue: _petAge,
                                  value: 'Young',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petAge = value!;
                                    });
                                  },
                                ),
                                _buildRadioButton(
                                  label: 'Adult',
                                  groupValue: _petAge,
                                  value: 'Adult',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petAge = value!;
                                    });
                                  },
                                ),
                                _buildRadioButton(
                                  label: 'Senior',
                                  groupValue: _petAge,
                                  value: 'Senior',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petAge = value!;
                                    });
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),
                            _buildRadioQuestion(
                              question: 'Preferred size:',
                              groupValue: _petSize,
                              options: const ['Small', 'Medium', 'Large'],
                              onChanged: (value) {
                                setModalState(() {
                                  _petSize = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // Care & Commitment
                            _buildSectionHeader('Care & Commitment'),
                            const SizedBox(height: 16),

                            _buildRadioQuestion(
                              question: 'Do you currently have pets?',
                              groupValue: _currentPets,
                              options: const ['Yes', 'No'],
                              onChanged: (value) {
                                setModalState(() {
                                  _currentPets = value!;
                                });
                              },
                            ),

                            if (_currentPets == 'Yes')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildInputField(
                                    controller: _currentPetsDetailsController,
                                    label:
                                        'Please list their species, age, and if they are spayed/neutered:',
                                    isRequired: true,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),

                            _buildRadioQuestion(
                              question: 'Have you had pets in the past?',
                              groupValue: _pastPets,
                              options: const ['Yes', 'No'],
                              onChanged: (value) {
                                setModalState(() {
                                  _pastPets = value!;
                                });
                              },
                            ),

                            if (_pastPets == 'Yes')
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  _buildInputField(
                                    controller: _pastPetsDetailsController,
                                    label: 'If yes, what happened to them?',
                                    isRequired: true,
                                    maxLines: 2,
                                  ),
                                ],
                              ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _hoursAloneController,
                              label:
                                  'How many hours per day will the pet be left alone?',
                              isRequired: true,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 16),

                            const Text(
                                'Where will the pet stay when you are not at home?',
                                style: TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 16.0,
                              runSpacing: 8.0,
                              children: [
                                _buildRadioButton(
                                  label: 'Indoors',
                                  groupValue: _petStayWhenAway,
                                  value: 'Indoors',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petStayWhenAway = value!;
                                    });
                                  },
                                ),
                                _buildRadioButton(
                                  label: 'Outdoors',
                                  groupValue: _petStayWhenAway,
                                  value: 'Outdoors',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petStayWhenAway = value!;
                                    });
                                  },
                                ),
                                _buildRadioButton(
                                  label: 'Crated',
                                  groupValue: _petStayWhenAway,
                                  value: 'Crated',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petStayWhenAway = value!;
                                    });
                                  },
                                ),
                                _buildRadioButton(
                                  label: 'Other',
                                  groupValue: _petStayWhenAway,
                                  value: 'Other',
                                  onChanged: (value) {
                                    setModalState(() {
                                      _petStayWhenAway = value!;
                                    });
                                  },
                                ),
                                Container(
                                  child: _petStayWhenAway == 'Other'
                                      ? _buildInputField(
                                          controller: _otherStayController,
                                          label: 'Please specify where',
                                          isRequired: true,
                                        )
                                      : null,
                                ),
                              ],
                            ),

                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _petSleepLocationController,
                              label: 'Where will the pet sleep at night?',
                              isRequired: true,
                            ),
                            const SizedBox(height: 16),

                            _buildRadioQuestion(
                              question:
                                  'Are you prepared for the financial responsibility of pet ownership?',
                              groupValue: _financialResponsibility,
                              options: const ['Yes', 'No'],
                              onChanged: (value) {
                                setModalState(() {
                                  _financialResponsibility = value!;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // References
                            _buildSectionHeader('References'),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _vetNameController,
                              label: 'Veterinarian Name',
                              hintText: 'If applicable',
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _vetPhoneController,
                              label: 'Veterinarian Phone',
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _refNameController,
                              label: 'Personal Reference Name',
                              hintText: 'Non-family member',
                              isRequired: true,
                            ),
                            const SizedBox(height: 16),

                            _buildInputField(
                              controller: _refPhoneController,
                              label: 'Personal Reference Phone',
                              isRequired: true,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 24),

                            // Agreement
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: CheckboxListTile(
                                title: const Text(
                                    'I understand and agree that all information provided is true and accurate.'),
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setModalState(() {
                                    isChecked = value!;
                                  });
                                },
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      child: ElevatedButton(
                        onPressed: isChecked
                            ? () async {
                                if (_formKey.currentState!.validate()) {
                                  // Form Data
                                  Map<String, dynamic> formData = {
                                    'status': 'Pending',
                                    'name': _nameController.text,
                                    'dateofbirth': _dobController.text,
                                    'address': _addressController.text,
                                    'phone': _phoneController.text,
                                    'email': _emailController.text,
                                    'ownership': _ownership,
                                    'residence': _residenceType,
                                    'adults': _adultsController.text,
                                    'children': _childrenController.text,
                                    'allergies': _allergies,
                                    'explanationallergies':
                                        _allergiesExplanationController.text,
                                    'pet_interested': _petNameController.text,
                                    'pettype': _petType,
                                    'age': _petAge,
                                    'currentpets': _currentPets,
                                    'currentpetdetails':
                                        _currentPetsDetailsController.text,
                                    'pastpets': _pastPets,
                                    'pastpetdetails':
                                        _pastPetsDetailsController.text,
                                    'hoursalone': _hoursAloneController.text,
                                    'petstaywhenaway': _petStayWhenAway,
                                    'petOtherWhenAway':
                                        _otherStayController.text == ''
                                            ? "None"
                                            : _otherStayController.text,
                                    'financialresponsibility':
                                        _financialResponsibility,
                                    'petId': widget.docId,
                                    'pet_breed': Breed,
                                    'pet_color': color,
                                    'user_id':
                                        FirebaseAuth.instance.currentUser!.uid,
                                    'vetname': _vetNameController.text,
                                    'vetphone': _vetPhoneController.text,
                                    'personal_reference':
                                        _refNameController.text,
                                    'personal_refnumber':
                                        _refPhoneController.text,
                                    'pet_sleep_location':
                                        _petSleepLocationController.text,
                                    'pet_size': _petSize,
                                    'timestamp': FieldValue.serverTimestamp(),
                                  };

                                  await FirebaseFirestore.instance
                                      .collection('request_form')
                                      .add(formData);

                                  var snackBar = const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                        'Success Request Adopt Waiting for approval'),
                                  );

                                  _globalKey.currentState
                                      ?.showSnackBar(snackBar);

                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            disabledBackgroundColor: Colors.grey.shade300,
                            disabledForegroundColor: Colors.black),
                        child: const Text(
                          'Submit Application',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        });
  }

// Helper widgets for consistent styling
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.blue.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: isRequired ? '$label *' : label,
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: isRequired
          ? (value) {
              if (value == null || value.isEmpty) {
                return 'This field is required';
              }
              if (keyboardType == TextInputType.emailAddress &&
                  (!value.contains('@') || !value.contains('.'))) {
                return 'Please enter a valid email address';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildRadioQuestion({
    required String question,
    required String groupValue,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 16.0,
          children: options
              .map((option) => _buildRadioButton(
                    label: option,
                    groupValue: groupValue,
                    value: option,
                    onChanged: onChanged,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildRadioButton({
    required String label,
    required String groupValue,
    required String value,
    required Function(String?) onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Colors.blue,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }
}
