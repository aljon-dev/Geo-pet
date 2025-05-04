import 'package:flutter/material.dart';
import '/login.dart';

// ignore: use_key_in_widget_constructors, must_be_immutable, camel_case_types
class HomePage extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _HomePage createState() => _HomePage();
}

// ignore: camel_case_types
class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            margin: const EdgeInsets.only(top: 20),
            child: ListView(
              children: [
                Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    alignment: Alignment.center,
                    child: const SizedBox(
                      child: Image(
                        image: AssetImage('assets/logo.png'),
                      ),
                    )),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Re-Home and',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      color: Color(0xdd2e3131),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Adopt a pet',
                    style: TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.w900,
                      color: Color(0xdd2e3131),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                ),
                Container(
                  alignment: Alignment.center,
                  child: const Text(
                    'Adopt me, we both need the love',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 0, 63, 157),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 30),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 90),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                          color: const Color(0xdd2e3131),
                          borderRadius: BorderRadius.circular(40)),
                      child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => const LoginPage())));
                          },
                          child: const Text(
                            'Get Started',
                            style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ))),
                ),
              ],
            ),
          ),
        ));
  }
}
