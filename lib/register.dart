import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/bottom.dart';
import '/login.dart';
import '/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPage createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();

  late TextEditingController firstnameController = TextEditingController();
  late TextEditingController lastnameController = TextEditingController();
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
                  Container(
                    margin: const EdgeInsets.only(top: 0),
                  ),
                  const Image(
                    image: AssetImage('assets/logo.png'),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    alignment: Alignment.bottomLeft,
                    child: const Text(
                      'Register!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(200, 31, 31, 31),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: RichText(
                      text: TextSpan(
                        text: "You already have an account? ",
                        style: const TextStyle(color: Colors.black),
                        children: [
                          TextSpan(
                            text: 'Login',
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 63, 157),
                                fontWeight: FontWeight.w600),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: ((context) =>
                                            const LoginPage())));
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: firstnameController,
                        decoration: const InputDecoration(
                            labelText: 'Firstname',
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: lastnameController,
                        decoration: const InputDecoration(
                            labelText: 'Lastname',
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            labelText: 'Email',
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Container(
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(82, 228, 228, 228),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: 'Password',
                            border: InputBorder.none,
                            labelStyle: TextStyle(color: Colors.black)),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 0, 63, 157),
                            borderRadius: BorderRadius.circular(30)),
                        child: TextButton(
                            onPressed: () {
                              Services()
                                  .signUp(
                                      firstnameController.text,
                                      lastnameController.text,
                                      emailController.text,
                                      passwordController.text)
                                  .then((value) {
                                var snackBar = const SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text('Success Create Account'));
                                _globalKey.currentState?.showSnackBar(snackBar);

                                Services()
                                    .signIn(emailController.text,
                                        passwordController.text)
                                    .then((value) {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => BottomPage()));
                                }).catchError((error) {
                                  var snackBar = const SnackBar(
                                      content: Text('Invalid Credentials'));
                                  _globalKey.currentState
                                      ?.showSnackBar(snackBar);
                                });
                              }).catchError((error) {
                                var snackBar = const SnackBar(
                                    content: Text('Invalid Credentials'));
                                _globalKey.currentState?.showSnackBar(snackBar);
                              });
                            },
                            child: const Text(
                              'Register',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 22),
                            ))),
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
