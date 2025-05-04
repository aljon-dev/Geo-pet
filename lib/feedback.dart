import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/services.dart';

void main() {
  runApp(const FeedbackPage());
}

// ignore: camel_case_types
class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FeedbackPage createState() => _FeedbackPage();
}

// ignore: camel_case_types
class _FeedbackPage extends State<FeedbackPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  final user = FirebaseAuth.instance.currentUser;
  String uidController = "";
  String firstnameController = "";
  String lastnameController = "";
  final TextEditingController feedbackController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch data based on the provided UID when the widget initializes
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      var user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: user.uid)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          var userData =
              querySnapshot.docs.first.data() as Map<String, dynamic>?;

          if (userData != null) {
            setState(() {
              uidController = userData['uid'] ?? '';
              firstnameController = userData['firstname'] ?? '';
              lastnameController = userData['lastname'] ?? '';
            });
          } else {}
        } else {}
      } else {}
      // ignore: empty_catches
    } catch (e) {}
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
            title: const Text(
              'Feedback',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 30),
                      child: Container(
                        height: 300,
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextFormField(
                          controller: feedbackController,
                          maxLines:
                              null, // Allows the TextFormField to expand vertically
                          decoration: const InputDecoration(
                            labelText: 'Give us your feedback about your experience for our application',
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        margin: const EdgeInsets.only(top: 30),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 63, 157),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: SizedBox(
                          child: TextButton(
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('feedback')
                                  .doc()
                                  .set({
                                'uid': uidController,
                                'firstname': firstnameController,
                                'lastname': lastnameController,
                                'feedback': feedbackController.text,
                              }).then((value) {
                                var snackBar = const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('Success Submit Feedback'));
                                _globalKey.currentState?.showSnackBar(snackBar);
                              });
                            },
                            child: const Text(
                              'Submit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          ),
                        )),
                    Container(margin: const EdgeInsets.only(bottom: 20))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
