import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/bottom.dart';
import 'package:image_picker/image_picker.dart';

class MessageViewPage extends StatefulWidget {
  const MessageViewPage({super.key});

  @override
  _MessageViewPage createState() => _MessageViewPage();
}

class _MessageViewPage extends State<MessageViewPage> {
  final user = FirebaseAuth.instance.currentUser!;

  final messagesController = TextEditingController();
  String downloadURL = "";

  XFile? image;

  Future<void> showImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    setState(() {
      image = img;
    });
    if (img != null) {
      await uploadFirebase(File(img.path));
    }
  }

  Future<void> uploadFirebase(File imageFile) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });
        return const AlertDialog(
          title: Text('Waiting...'),
          content: Text("Waiting to upload image to Firebase"),
        );
      },
    );

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().toIso8601String()}.png');
      final uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        downloadURL = await storageRef.getDownloadURL();
        setState(() {
          print("Download URL: $downloadURL");
        });
      });
    } catch (e) {
      print("Error during upload: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortid = [user.uid, 'S4BeTEeomAVNJTPuzZb60r9ISbm2'];
    sortid.sort();
    String chatroomID = sortid.join("_");

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 63, 157),
          title: Row(
            children: [
              GestureDetector(
                child: const Icon(
                  Icons.arrow_left,
                  size: 40,
                  color: Colors.white,
                ),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BottomPage(),
                    ),
                  );
                },
              ),
              const Text(
                'Messages',
                style: TextStyle(color: Colors.white),
              )
            ],
          ),
        ),
        body: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              height: MediaQuery.of(context).size.height / 1.23,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where("code", isEqualTo: chatroomID)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final messages = snapshot.data!.docs;

                    // Sort messages by timestamp
                    messages.sort((a, b) {
                      DateTime timestampA = a['timestamp'].toDate();
                      DateTime timestampB = b['timestamp'].toDate();
                      return timestampA.compareTo(timestampB);
                    });

                    // Update unread messages to read
                    for (var message in messages) {
                      if (message['receiver_uid'] == user.uid &&
                          message['status'] == 'unread') {
                        FirebaseFirestore.instance
                            .collection('messages')
                            .doc(message.id)
                            .update({'status': 'read'});
                      }
                    }

                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final senderUid = message['sender_uid'];
                        DateTime messageTimestamp = message['timestamp'].toDate();

                        bool sender = user.uid == senderUid;

                        final colors = sender ? Colors.blue : Colors.black;

                        // Determine if the date should be displayed
                        bool showDate = true;
                        if (index > 0) {
                          final prevMessageTimestamp = messages[index - 1]['timestamp'].toDate();
                          showDate = messageTimestamp.day != prevMessageTimestamp.day ||
                              messageTimestamp.month != prevMessageTimestamp.month ||
                              messageTimestamp.year != prevMessageTimestamp.year;
                        }

                        // Format the date
                        String formattedDate;
                        final now = DateTime.now();
                        if (messageTimestamp.year == now.year &&
                            messageTimestamp.month == now.month &&
                            messageTimestamp.day == now.day) {
                          formattedDate = "Today";
                        } else if (messageTimestamp.year == now.year &&
                            messageTimestamp.month == now.month &&
                            messageTimestamp.day == now.day - 1) {
                          formattedDate = "Yesterday";
                        } else {
                          formattedDate = "${messageTimestamp.day}/${messageTimestamp.month}/${messageTimestamp.year}";
                        }

                        // Handle image field safely
                        final showImage = sender
                            ? Container(
                                alignment: Alignment.bottomRight,
                                margin: const EdgeInsets.only(right: 10),
                                child: (message.data().containsKey('image') &&
                                        message['image'] != null &&
                                        message['image'] != '')
                                    ? Image.network(
                                        message['image'],
                                        width: 100,
                                        height: 100,
                                      )
                                    : const SizedBox.shrink(),
                              )
                            : Container(
                                margin: const EdgeInsets.only(left: 10),
                                alignment: Alignment.bottomLeft,
                                child: (message.data().containsKey('image') &&
                                        message['image'] != null &&
                                        message['image'] != '')
                                    ? Image.network(
                                        message['image'],
                                        width: 100,
                                        height: 100,
                                      )
                                    : const SizedBox.shrink(),
                              );

                        return Column(
                          children: [
                            if (showDate)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Center(
                                  child: Text(
                                    formattedDate,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            BubbleSpecialThree(
                              text: message['text'] ?? '',
                              color: colors,
                              tail: true,
                              isSender: sender,
                              textStyle: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            showImage,
                          ],
                        );
                      },
                    );

                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading messages.'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: const BoxDecoration(
                color: Color.fromARGB(82, 216, 216, 216),
              ),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      showImage(ImageSource.gallery).then((value) {});
                    },
                    child: FaIcon(
                      FontAwesomeIcons.upload,
                      color: const Color.fromARGB(255, 0, 63, 157),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: messagesController,
                      decoration: const InputDecoration(
                          labelText: 'Send...', border: InputBorder.none),
                    ),
                  ),
                  SizedBox(
                    width: 50,
                    child: TextButton(
                      onPressed: () async {
                        final refcolmessages = FirebaseFirestore.instance
                            .collection('messages');

                        refcolmessages.add({
                          'text': messagesController.text,
                          'code': chatroomID,
                          'sender_uid': user.uid,
                          'receiver_uid': 'S4BeTEeomAVNJTPuzZb60r9ISbm2',
                          'timestamp': Timestamp.now(),
                          'image': downloadURL,
                          'status': 'unread', // Set status as unread
                        });

                        messagesController.clear();
                      },
                      child: const Icon(
                        Icons.send,
                        color: Color.fromARGB(255, 0, 63, 157),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
