import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminFeedbackPage extends StatefulWidget {
  const AdminFeedbackPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminFeedbackPage createState() => _AdminFeedbackPage();
}

class _AdminFeedbackPage extends State<AdminFeedbackPage> {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 63, 157),
        title: const Row(
          children: [
            Text(
              'Feedback',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        leading: null,
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('feedback')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('No data available'));
                  }
                  final alldata = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: alldata.length,
                    itemBuilder: (context, index) {
                      final data = alldata[index];

                      return Column(
                        children: [
                          GestureDetector(
                            child: Container(
                                padding: const EdgeInsets.all(7),
                                margin: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 194, 218, 255),
                                    borderRadius: BorderRadius.circular(20)),
                                child: Column(
                                  children: [
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        '${data['firstname']} ${data['lastname']}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    Container(
                                      alignment: Alignment.bottomLeft,
                                      padding: const EdgeInsets.all(5),
                                      child: Text(
                                        '${data['feedback']}',
                                      ),
                                    ),
                                  ],
                                )),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                ),
                                backgroundColor: const Color.fromARGB(255, 194, 218, 255),
                                builder: (BuildContext context) {
                                  return Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${data['firstname']} ${data['lastname']}',
                                          style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          '${data['feedback']}',
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 20),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: TextButton(
                                            child: const Text(
                                              'Close',
                                              style: TextStyle(
                                                color: Color.fromARGB(255, 0, 63, 157),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
