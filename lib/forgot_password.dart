import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '/services.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _globalKey = GlobalKey<ScaffoldMessengerState>();
  late TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return ScaffoldMessenger(
      key: _globalKey,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          padding: const EdgeInsets.all(30),
          height: screenSize.height,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20),
                ),
                const Image(
                  image: AssetImage('assets/logo.png'),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.bottomLeft,
                  child: const Text(
                    'Forgot Password!',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Color.fromARGB(200, 31, 31, 31),
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
                          labelText: 'Email', border: InputBorder.none),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 0, 63, 157),
                          borderRadius: BorderRadius.circular(30)),
                      child: TextButton(
                        onPressed: () async {
                          bool emailExists = await Services().checkEmailExists(emailController.text);
                          if (emailExists) {
                            await Services().resetPassword(emailController.text);
                            var snackBar = const SnackBar(
                              content: Text('Password reset email sent'),
                            );
                            _globalKey.currentState?.showSnackBar(snackBar);
                          } else {
                            var snackBar = const SnackBar(
                              content: Text('Email does not exist'),
                            );
                            _globalKey.currentState?.showSnackBar(snackBar);
                          }
                        },
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      )),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: RichText(
                    text: TextSpan(
                      text: "Remember your password? ",
                      style: const TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Login',
                          style: const TextStyle(
                              color: Color.fromARGB(255, 0, 63, 157),
                              fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pop(context);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
