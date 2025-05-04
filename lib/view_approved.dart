import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/adminbottom.dart';
import 'package:geopawsfinal/adminwelcome.dart';
import 'package:geopawsfinal/bottom.dart';
import 'package:geopawsfinal/welcome.dart';

class ViewApprovedPage extends StatefulWidget {
  final String petId;
  final String uid;
  final String docId;
  const ViewApprovedPage(
      {super.key, required this.petId, required this.uid, required this.docId});

  @override
  _ViewApprovedPage createState() => _ViewApprovedPage();
}

class _ViewApprovedPage extends State<ViewApprovedPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  String type = "";
  String pet_name = "";
  String age = "";
  String color = "";
  String arrivaldate = "";
  String size = "";
  String sex = "";
  String petimages = "";

  String firstname = "";
  String lastname = "";
  String contact = "";
  String address = "";
  String email = "";
  String userimages = "";
  String userimages2 = "";
  String userimages3 = "";

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
        });
      }
    } catch (e) {
      print('Error fetching pet data: $e');
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
          userimages2 = userData['images2'] ?? '';
          userimages3 = userData['images3'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
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
                    size: 30,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BottomPage(),
                        ));
                  },
                ),
                const SizedBox(width: 10),
                const Text(
                  'Pet Approved',
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildPetInfoSection(),
              const SizedBox(height: 20),
              _buildCustomerInfoSection(),
              const SizedBox(height: 20),
              _buildValidIDSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfoSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: petimages.isNotEmpty
                ? Image.network(
                    petimages,
                    height: 300,
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
                _buildInfoRow('Type', type),
                _buildInfoRow('pet_name', pet_name),
                _buildInfoRow('Age', age),
                _buildInfoRow('Color', color),
                _buildInfoRow('Arrival Date', arrivaldate),
                _buildInfoRow('Weight', size),
                _buildInfoRow('Sex', sex),
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
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Customer Information',
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
          ],
        ),
      ),
    );
  }

  Widget _buildValidIDSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Valid ID's",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 20),
            userimages2.isNotEmpty
                ? Image.network(userimages2)
                : const Text(
                    'No Valid ID',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
            const SizedBox(height: 20),
            userimages3.isNotEmpty
                ? Image.network(userimages3)
                : const Text(
                    'No Valid ID',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
          ],
        ),
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
            ),
          ),
          Text(
            value.isNotEmpty ? value : 'Not specified',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
