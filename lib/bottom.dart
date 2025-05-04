import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/feedback.dart';
import 'package:geopawsfinal/messages_view.dart';
import 'package:geopawsfinal/pet2.dart';
import '/login.dart';
import '/profile.dart';
import '/welcome.dart';
import '/report.dart';  // Import ReportPage

void main() {
  runApp(BottomPage());
}

// ignore: use_key_in_widget_constructors, must_be_immutable, camel_case_types
class BottomPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _BottomPage createState() => _BottomPage();
}

// ignore: camel_case_types
class _BottomPage extends State<BottomPage> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: MainAppwidget());
  }
}

// ignore: camel_case_types
class MainAppwidget extends StatefulWidget {
  const MainAppwidget({super.key});

  @override
  MainAppwidgetfooter createState() => MainAppwidgetfooter();
}

class MainAppwidgetfooter extends State<MainAppwidget> {
  int selectedindex = 0;

  static List<Widget> widgetoption = [
    const WelcomePage(),
    const PetPage(),
    const MessageViewPage(),
    const ProfilePage(),
    const FeedbackPage(),
    ReportFormPage(),  // ReportPage added here (without const)
  ];

  void onitemtapped(int index) {
    if (index == 6) {  // Updated index for Logout since Report is added
      _showLogoutDialog(context);
    } else {
      setState(() {
        selectedindex = index;
      });

      if (selectedindex == 1) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => const PetPage())));
      } else if (selectedindex == 2) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => const MessageViewPage())));
      } else if (selectedindex == 5) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: ((context) => ReportFormPage())));  // Navigate to ReportPage (without const)
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              child: const Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                Navigator.of(context).pop();
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: ((context) => const LoginPage())));
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade200,
      body: Center(
        child: widgetoption.elementAt(selectedindex),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SizedBox(
          child: BottomNavigationBar(
            unselectedItemColor: const Color.fromARGB(255, 0, 63, 157),
            selectedItemColor: const Color.fromARGB(255, 0, 63, 157),
            selectedFontSize: 13,
            unselectedFontSize: 13,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.home,
                  size: 25,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(
                  FontAwesomeIcons.paw,
                  size: 25,
                ),
                label: 'Pet',
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.sms,
                  size: 25,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.person,
                  size: 25,
                ),
                label: 'Profile',
              ),
              BottomNavigationBarItem(
                icon: const FaIcon(
                  FontAwesomeIcons.commentDots,
                  size: 25,
                ),
                label: 'Feedback',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  clipBehavior: Clip.none, // Allows the badge to overflow the icon
                  children: [
                    FaIcon(
                      FontAwesomeIcons.fileAlt,
                      size: 25,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pet_reports')
                          .where('status', isNotEqualTo: 'In Progress') // Exclude "In Progress"
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const SizedBox(); // Show nothing while loading
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const SizedBox(); // Show nothing if no reports
                        }

                        final count = snapshot.data!.docs.length;

                        return Positioned(
                          top: -5, // Adjust position to tightly fit the icon
                          right: -5,
                          child: Container(
                            padding: const EdgeInsets.all(4), // Inner padding for the badge
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$count', // Dynamic count from the database
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10, // Small font for the count
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                label: 'Report',
              ),
              BottomNavigationBarItem(
                icon: const Icon(
                  Icons.logout,
                  size: 25,
                ),
                label: 'Logout',
              ),
            ],
            currentIndex: selectedindex,
            type: BottomNavigationBarType.fixed,
            onTap: onitemtapped,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),

        ),
      ),
    );
  }
}
