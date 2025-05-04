import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/adminfeedback.dart';
import 'package:geopawsfinal/adminprofile.dart';
import 'package:geopawsfinal/adminwelcome.dart';
import 'package:geopawsfinal/login.dart';
import 'package:geopawsfinal/messages.dart';
import 'package:geopawsfinal/pet.dart';

void main() {
  runApp(AdminBottomPage());
}

// ignore: use_key_in_widget_constructors, must_be_immutable, camel_case_types
class AdminBottomPage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AdminBottomPage createState() => _AdminBottomPage();
}

// ignore: camel_case_types
class _AdminBottomPage extends State<AdminBottomPage> {
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

  static const List<Widget> widgetoption = [
    AdminWelcomePage(),
    AdminPetPage(),
    MessagesPage(),
    AdminFeedbackPage()
  ];

  void onitemtapped(int index) {
    if (index == 4) {
      // Adjusted index for Logout since Profile is removed
      _showLogoutDialog(context);
    } else {
      setState(() {
        selectedindex = index;
      });
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

            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 25,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.paw,
                  size: 25,
                ),
                label: 'Pet',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.sms,
                  size: 25,
                ),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: FaIcon(
                  FontAwesomeIcons.commentDots,
                  size: 25,
                ),
                label: 'Feedback',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.logout,
                  size: 25,
                ),
                label: 'Logout',
              ),
            ],
            currentIndex: selectedindex,
            type: BottomNavigationBarType.fixed,
            onTap: onitemtapped,
            backgroundColor: Colors
                .transparent, // Set to transparent to see the BottomAppBar color
            elevation: 0, // Remove top shadow color
          ),
        ),
      ),
    );
  }
}
