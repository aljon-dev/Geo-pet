import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/adminbottom.dart';
import '/bottom.dart';
import '/register.dart';
import '/services.dart';
import '/forgot_password.dart'; // Import the ForgotPasswordPage

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  late TextEditingController emailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _globalKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Image(image: AssetImage('assets/logo.png')),
                const SizedBox(height: 10),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Login!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(200, 31, 31, 31),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField('Email', emailController),
                const SizedBox(height: 30),
                _buildTextField('Password', passwordController,
                    obscureText: true),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ForgotPasswordPage()),
                      );
                    },
                    child: const Text('Forgot Password?',
                        style:
                            TextStyle(color: Color.fromARGB(255, 0, 63, 157))),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLoginButton(context),
                const SizedBox(height: 30),
                RichText(
                  text: TextSpan(
                    text: "You don't have an account? ",
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: 'Register',
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 63, 157),
                            fontWeight: FontWeight.w600),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool obscureText = false}) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(82, 228, 228, 228),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(labelText: label, border: InputBorder.none),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 63, 157),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton(
        onPressed: () {
          Services()
              .signIn(emailController.text, passwordController.text)
              .then((value) {
            FirebaseFirestore.instance
                .collection('users')
                .where('email', isEqualTo: emailController.text)
                .get()
                .then((QuerySnapshot querySnapshot) {
              for (QueryDocumentSnapshot doc in querySnapshot.docs) {
                String type = doc['type'];
                if (type == 'admin') {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => AdminBottomPage()),
                  );
                } else {
                  // Show Terms and Conditions dialog
                  _showTermsDialog(context);
                }
              }
            });
          }).catchError((error) {
            var snackBar = const SnackBar(content: Text('Invalid Credentials'));
            _globalKey.currentState?.showSnackBar(snackBar);
          });
        },
        child: const Text('Login',
            style: TextStyle(color: Colors.white, fontSize: 22)),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("GeoPaws Terms and Conditions"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Introduction: \nWelcome to GeoPaws, an animal rescue and pet adoption platform designed to connect pets in need of homes with potential adopters. By using our application, you agree to the following terms and conditions. Please read them carefully before proceeding.\n'),
                Text(
                    '1. No Cancellation of Adoption Process: Once you have committed to adopting a pet through GeoPaws, the adoption process cannot be canceled. Please be sure of your decision before proceeding.\n'),
                Text(
                    '2. Valid Identification Requirement: You will not be able to collect your pet without presenting valid identification. The information on your ID must match the details provided in the app. Please ensure you bring your valid IDs.\n'),
                Text(
                    '3. Age Requirement: You must be at least 18 years old to use our application and adopt a pet.\n'),
                Text(
                    '4. Responsible Pet Ownership: By adopting a pet through our platform, you commit to providing a safe, loving, and responsible home for the animal.\n'),
                Text(
                    '5. Adoption Process:\nApplication Submission: All prospective adopters must complete and submit an adoption application, which will be reviewed by our team.\n6. Adoption Approval: Approval of an adoption application is at the sole discretion of GeoPaws. We reserve the right to decline applications without providing specific reasons.\n'),
                Text(
                    'For any questions or concerns regarding these terms and conditions, please provide your feedback. Thank you.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('I Agree',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold)),
              onPressed: () {
                // Close the dialog and navigate to the BottomPage after the user agrees
                Navigator.of(context).pop();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => BottomPage()));
              },
            ),
          ],
        );
      },
    );
  }
}
