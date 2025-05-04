import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/bottom.dart';
import 'package:geopawsfinal/welcome.dart';

class ViewRequestPage extends StatefulWidget {
  final String petId;
  final String uid;
  final String docId;
  const ViewRequestPage(
      {super.key, required this.petId, required this.uid, required this.docId});

  @override
  _ViewRequestPage createState() => _ViewRequestPage();
}

class _ViewRequestPage extends State<ViewRequestPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

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
  String petBreed = '';
  String skin = '';
  String appearance = '';
  String background = '';
  String petimages = "";

  String firstname = "";
  String lastname = "";
  String contact = "";
  String address = "";
  String email = "";
  String userimages = "";

  @override
  void initState() {
    super.initState();
    petData();
    userData();
  }

  Future<void> petData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('pet')
          .doc(widget.petId)
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
          petimages = userData['images'] ?? '';

          microchipped = userData['microchipped'] ?? '';
          rescue_story = userData['rescue_story'] ?? '';
          medical_conditions = userData['medical_conditions'] ?? '';
          temperament = userData['temperament'] ?? '';
          training_level = userData['training_level'] ?? '';
          vaccinated = userData['vaccinated'] ?? '';
          good_with = userData['good_with'][0] ?? '';
          dewormed = userData['dewormed'] ?? '';
          rescueStory = userData['rescue_story'] ?? 'None';
          neutered = userData['spayed_neutered'] ?? 'None';
          petBreed = userData['breed'] ?? 'None';
          background = userData['background'] ?? 'None';
          skin = userData['skin_condition'] ?? 'None';
          appearance = userData['appearance'] ?? 'No Data';
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document: $e');
    }
  }

  Future<void> userData() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();

      if (documentSnapshot.exists) {
        var userData = documentSnapshot.data() as Map<String, dynamic>;

        setState(() {
          firstname = userData['firstname'] ?? '';
          lastname = userData['lastname'] ?? '';
          contact = userData['contact'] ?? '';
          address = userData['address'] ?? '';
          email = userData['email'] ?? '';
          userimages = userData['images'] ?? '';
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching document: $e');
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
            leading: IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BottomPage()));
                },
                icon: Icon(Icons.arrow_back)),
            backgroundColor: const Color.fromARGB(255, 0, 63, 157),
            title: const Row(
              children: [
                const SizedBox(width: 10),
                const Text(
                  'Pet Request',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildPetInfoSection(),
              const SizedBox(height: 20),
              _buildCustomerInfoSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: petimages.isNotEmpty
                ? Image.network(
                    petimages,
                    height: 250,
                    fit: BoxFit.cover,
                  )
                : const Icon(
                    Icons.image_not_supported,
                    size: 100,
                    color: Colors.grey,
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _SectionHeader(Colors.green, Icons.library_books_outlined,
                    'Pet Information'),
                const SizedBox(height: 5),
                _buildInfoRow('Pet Name', pet_name),
                _buildInfoRow('Arrival Date', arrivaldate),
                _buildInfoRow('Breed', petBreed),
                _buildInfoRow('Weight', size),
                _buildInfoRow('Type', type),
                _buildInfoRow('Color', color),
                _buildInfoRow('Background', background),
                const SizedBox(height: 5),
                _SectionHeader(Colors.red, Icons.health_and_safety_sharp,
                    'Health Information'),
                const SizedBox(height: 5),
                _buildInfoRow('Vaccinated', vaccinated),
                _buildInfoRow('Skin Condition', skin),
                _buildInfoRow('Appearance', appearance),
                const SizedBox(height: 5),
                _SectionHeader(
                    Colors.blue, Icons.catching_pokemon, 'Personality'),
                _buildInfoRow('Temperament', temperament),
                const SizedBox(
                  height: 5,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Background:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      height: 80,
                      width: double.infinity,
                      child: Text(background),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Member Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage:
                      userimages.isNotEmpty ? NetworkImage(userimages) : null,
                  backgroundColor: Colors.grey.shade300,
                  child: userimages.isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Name', '$firstname $lastname'),
                      _buildInfoRow('Contact', contact),
                      _buildInfoRow('Email', email),
                      _buildInfoRow('Address', address),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    FirebaseFirestore.instance
                        .collection('request')
                        .doc(widget.docId)
                        .delete();

                    FirebaseFirestore.instance
                        .collection('request_form')
                        .where('petId', isEqualTo: widget.petId)
                        .get()
                        .then((snapshot) async {
                      for (DocumentSnapshot doc in snapshot.docs) {
                        await FirebaseFirestore.instance
                            .collection('pet')
                            .doc(widget.petId)
                            .update({'status': 'Available'});

                        doc.reference.delete();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BottomPage()));
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Successfully Cancelled',
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text('Cancel Request')),
            )
          ],
        ),
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
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
