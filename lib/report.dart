import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/Reports/ReportMissing.dart';
import 'package:geopawsfinal/Reports/ReportStray.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BottomPage()));
          },
        ),
        title: const Text('Reports'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Choose a Report Type',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ReportOptionCard(
              title: 'Report Stray Animal',
              icon: FontAwesomeIcons.dog,
              color: Colors.orange,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StrayAnimalReportForm()));
              },
            ),
            const SizedBox(height: 20),
            ReportOptionCard(
              title: 'Report Missing Pet',
              icon: FontAwesomeIcons.search,
              color: Colors.red,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MissingPetReportForm()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ReportOptionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const ReportOptionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onPressed,
      ),
    );
  }
}
