import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geopawsfinal/admin_messages_view.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MessagesPage createState() => _MessagesPage();
}

class _MessagesPage extends State<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 63, 157),
        title: const Row(
          children: [
            Text(
              'Messages',
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
                      .collection('users')
                      .where('type', isEqualTo: 'customer')
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
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 0, 63, 157),
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    '${data['firstname']} ${data['lastname']}',
                                  ),
                                  tileColor: Colors.blue,
                                ),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: ((context) => AdminMessageViewPage(
                                          senderUid: user!.uid,
                                          receiverUid: data['uid'],
                                        ))),
                              ),
                            ),
                            const Divider(height: 0),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          )),
    );
  }
}
