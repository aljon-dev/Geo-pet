import 'dart:io';

import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geopawsfinal/adminbottom.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class AdminMessageViewPage extends StatefulWidget {
  final String senderUid;
  final String receiverUid;
  const AdminMessageViewPage(
      {super.key, required this.senderUid, required this.receiverUid});

  @override
  // ignore: library_private_types_in_public_api
  _AdminMessageViewPage createState() => _AdminMessageViewPage();
}

class _AdminMessageViewPage extends State<AdminMessageViewPage> {
  final user = FirebaseAuth.instance.currentUser!;

  final messagesController = TextEditingController();
  final receiverController = TextEditingController();

  String images = "";

  XFile? image;

  String downloadURL = "";

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
        // Schedule the dialog to close after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pop(true);
        });

        return const AlertDialog(
          title: Text('Waiting...'),
          content: Text("Waiting to Upload Image to firebase"),
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
        setState(() {});
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final sortid = [widget.senderUid, widget.receiverUid];
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
                          builder: (context) => AdminBottomPage(),
                        ));
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

                        messages.sort((a, b) {
                          DateTime timestampA = a['timestamp'].toDate();
                          DateTime timestampB = b['timestamp'].toDate();
                          return timestampA.compareTo(timestampB);
                        });
                        return ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final senderUid = message['sender_uid'];
                            DateTime messageTimestamp =
                                message['timestamp'].toDate();

                            bool sender = user.uid == senderUid ? true : false;

                            final colors = user.uid == senderUid
                                ? Colors.blue
                                : Colors.black;

                            final showimage = user.uid == senderUid
                                ? Container(
                                    alignment: Alignment.bottomRight,
                                    margin: const EdgeInsets.only(right: 10),
                                    child: message['images'] != ''
                                        ? Image.network(
                                            message['images'],
                                            width: 100,
                                            height: 100,
                                          )
                                        : const Text(''),
                                  )
                                : Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    alignment: Alignment.bottomLeft,
                                    child: message['images'] != ''
                                        ? Image.network(
                                            message['images'],
                                            width: 100,
                                            height: 100,
                                          )
                                        : const Text(''),
                                  );

                            return Column(
                              children: [
                                DateChip(
                                    date:
                                        messageTimestamp), // Assuming messageTimestamp is a DateTime
                                BubbleSpecialThree(
                                  text: message['text'],
                                  color: colors,
                                  tail: true,
                                  isSender: sender,
                                  textStyle: const TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                                showimage
                              ],
                            );
                          },
                        );
                      } else {
                        return const Text('NO MESSAGES');
                      }
                    }),
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
                      child: const FaIcon(
                        FontAwesomeIcons.upload,
                        color: Color.fromARGB(255, 0, 63, 157),
                      ),
                    ),
                    if (user.uid == widget.senderUid ||
                        user.uid == widget.receiverUid)
                      Expanded(
                        child: TextField(
                          controller: messagesController,
                          decoration: const InputDecoration(
                              labelText: 'Send...', border: InputBorder.none),
                        ),
                      ),
                    if (user.uid == widget.senderUid ||
                        user.uid == widget.receiverUid)
                      SizedBox(
                        width: 50,
                        child: TextButton(
                          onPressed: () async {
                            final sortid = [
                              widget.senderUid,
                              widget.receiverUid
                            ];
                            sortid.sort();
                            String chatroomID = sortid.join("_");

                            final refcolmessages = FirebaseFirestore.instance
                                .collection('messages');

                            refcolmessages.add({
                              'text': messagesController.text,
                              'code': chatroomID,
                              'sender_uid': widget.senderUid,
                              'receiver_uid': widget.receiverUid,
                              'timestamp': Timestamp.now(),
                              'images': downloadURL
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
        ));
  }
}
