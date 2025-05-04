import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDetailsPage extends StatelessWidget {
  final dynamic data;

  const ReportDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? documentData =
        data.data() as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 63, 157),
        title: const Text("Report Details"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 5,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Circular Pet Image
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: documentData != null &&
                            documentData.containsKey('image') &&
                            documentData['image'] != null
                        ? NetworkImage(documentData['image'])
                        : AssetImage('assets/default_pet_image.png')
                            as ImageProvider, // Fallback image if image is missing
                  ),
                  const SizedBox(height: 20),

                  // Pet Name Section
                  Text(
                    documentData != null && documentData.containsKey('pet_name')
                        ? documentData['pet_name']
                        : 'Unnamed Pet',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Appearance Section
                  _buildDetailItem(
                    context: context,
                    icon: Icons.pets,
                    title: 'Appearance',
                    subtitle: documentData != null &&
                            documentData.containsKey('appearance') &&
                            documentData['appearance'] != null
                        ? documentData['appearance']
                        : 'Not specified',
                  ),
                  const Divider(),

                  // Date Lost Section
                  _buildDetailItem(
                    context: context,
                    icon: Icons.calendar_today,
                    title: 'Date Lost',
                    subtitle: documentData != null &&
                            documentData.containsKey('date_lost') &&
                            documentData['date_lost'] != null
                        ? documentData['date_lost']
                        : 'Not specified',
                  ),
                  const Divider(),

                  // Location Lost Section
                  _buildDetailItem(
                    context: context,
                    icon: Icons.location_on,
                    title: 'Location Lost',
                    subtitle: documentData != null &&
                            documentData.containsKey('location_lost') &&
                            documentData['location_lost'] != null
                        ? documentData['location_lost']
                        : 'Not specified',
                  ),
                  const Divider(),

                  // Additional Information Section
                  _buildDetailItem(
                    context: context,
                    icon: Icons.info_outline,
                    title: 'Additional Info',
                    subtitle: documentData != null &&
                            documentData.containsKey('additional_info') &&
                            documentData['additional_info'] != null
                        ? documentData['additional_info']
                        : 'No additional information',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color.fromARGB(255, 0, 63, 157)),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
