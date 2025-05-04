import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/pet.dart';

class AdminPetProfilePage extends StatefulWidget {
  final String docId;
  const AdminPetProfilePage({super.key, required this.docId});

  @override
  _AdminPetProfilePage createState() => _AdminPetProfilePage();
}

class _AdminPetProfilePage extends State<AdminPetProfilePage> {
  String type = "";
  String pet_name = "";
  String age = "";
  String color = "";
  String arrivaldate = "";
  String size = "";
  String sex = "";
  String images = "";
  String rescueLocation = "";
  String firstOwner = "";
  String healthIssues = "";
  String additionalDetails = "";

  @override
  void initState() {
    super.initState();
    fetchData();
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
          type = userData['type'] ?? 'Not specified';
          pet_name = userData['pet_name'] ?? 'Not specified';
          age = userData['age'] ?? 'Not specified';
          color = userData['color'] ?? 'Not specified';
          arrivaldate = userData['arrivaldate'] ?? 'Not specified';
          size = userData['size'] ?? 'Not specified';
          sex = userData['sex'] ?? 'Not specified';
          images = userData['images'] ?? '';
          rescueLocation = userData['rescue_location'] ?? 'Not specified';
          firstOwner = userData['first_owner'] ?? 'Not specified';
          healthIssues = userData['health_issues'] ?? 'No health issues';
          additionalDetails = userData['additional_details'] ?? 'No additional details';
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
    return Scaffold(
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
                    builder: (context) => const AdminPetPage(),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            const Text(
              'Pet Profile',
              style: TextStyle(color: Colors.white),
            ),
          ],
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
                  child: images.isNotEmpty
                      ? Image.network(
                    images,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        size: 100,
                        color: Colors.grey,
                      );
                    },
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildInfoCard(Icons.cake, 'Age', age),
                          _buildInfoCard(Icons.monitor_weight, 'Weight', size),
                          _buildInfoCard(Icons.male, 'Sex', sex),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.pets, 'Type', type),
                      _buildInfoRow(Icons.category, 'pet_name', pet_name),
                      _buildInfoRow(Icons.color_lens, 'Color', color),
                      _buildInfoRow(Icons.calendar_today, 'Arrival Date', arrivaldate),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.place, 'Rescue Location', rescueLocation),
                      _buildInfoRow(Icons.person, 'First Owner', firstOwner),
                      _buildInfoRow(Icons.local_hospital, 'Health Issues', healthIssues),
                      _buildInfoRow(Icons.notes, 'Additional Details', additionalDetails),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 10),
          Expanded(
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
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.blue),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
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
}
