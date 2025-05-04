import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/adminwelcome.dart';

class AdminViewRequestPage extends StatefulWidget {
  final petId;
  final uid;
  final docId;
  const AdminViewRequestPage(
      {super.key, required this.petId, required this.uid, required this.docId});

  @override
  _AdminViewRequestPage createState() => _AdminViewRequestPage();
}

class _AdminViewRequestPage extends State<AdminViewRequestPage> {
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
          userimages2 = userData['images2'] ?? '';
          userimages3 = userData['images3'] ?? '';
        });
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
                        builder: (context) => AdminWelcomePage(),
                      ),
                    );
                  },
                ),
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
              _buildUserInfoSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfoSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(15),
            ),
            child: Image.network(
              petimages,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: Colors.grey,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Type', type),
                _buildInfoRow('pet_name', pet_name),
                _buildInfoRow('Age', age),
                _buildInfoRow('Color', color),
                _buildInfoRow('Arrival Date', arrivaldate),
                _buildInfoRow('Size Weight', size),
                _buildInfoRow('Sex', sex),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Customer Information',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color.fromARGB(255, 0, 63, 157),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipOval(
                      child: userimages == ''
                          ? const FaIcon(
                              FontAwesomeIcons.userCircle,
                              size: 50,
                              color: Colors.grey,
                            )
                          : Image.network(
                              userimages,
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoRow('Name', '$firstname $lastname'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Contact', contact),
                _buildInfoRow('Email', email),
                _buildInfoRow('Address', address),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomLeft,
            margin: const EdgeInsets.only(left: 16, bottom: 8),
            child: const Text(
              "Valid ID's",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Color.fromARGB(255, 0, 63, 157),
              ),
            ),
          ),
          _buildValidIDSection(),
        ],
      ),
    );
  }

  Widget _buildValidIDSection() {
    return Column(
      children: [
        _buildIDImage(userimages2),
        _buildIDImage(userimages3),
      ],
    );
  }

  Widget _buildIDImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: imageUrl == ''
          ? const Text(
              'No Valid ID',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 150,
                fit: BoxFit.cover,
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
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildApproveButton(),
        _buildDeclineButton(),
      ],
    );
  }

  Widget _buildApproveButton() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 3),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(40),
        ),
        child: TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('request')
                .doc(widget.docId)
                .update({'status': 'Approved'}).then((_) {
              FirebaseFirestore.instance
                  .collection('pet')
                  .doc(widget.petId)
                  .update({'status': 'Not Available'}).then((_) {
                var snackBar = const SnackBar(
                  backgroundColor: Colors.green,
                  content: Text('Success Approved Request'),
                );
                _globalKey.currentState?.showSnackBar(snackBar);
              }).catchError((error) {
                print("Error updating status: $error");
              });
            }).catchError((error) {
              print("Error updating status: $error");
            });
          },
          child: const Text(
            'Approve',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeclineButton() {
    return Container(
      margin: const EdgeInsets.only(top: 50),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(40),
        ),
        child: TextButton(
          onPressed: () {
            FirebaseFirestore.instance
                .collection('request')
                .doc(widget.docId)
                .update({'status': 'Declined'}).then((_) {
              var snackBar = const SnackBar(
                backgroundColor: Colors.red,
                content: Text('Request has been Declined'),
              );
              _globalKey.currentState?.showSnackBar(snackBar);
            }).catchError((error) {
              print("Error updating status: $error");
            });
          },
          child: const Text(
            'Decline',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
