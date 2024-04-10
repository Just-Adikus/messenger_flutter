import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;

  ChatScreen({required this.chatId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats/${widget.chatId}/messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final messages = snapshot.data!.docs.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final messageText = message['text'] != null ? message['text'] : '';
                      final sender = message['sender'] != null ? message['sender'] : 'Unknown Sender';
                      final timestamp = message['timestamp'] != null
                          ? message['timestamp'].toDate()
                          : DateTime.now();
                      final formattedTime = DateFormat.Hm().format(timestamp);

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sender,
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(messageText),
                                ],
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(formattedTime),
                          ],
                        ),
                      );
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final messageText = _messageController.text.trim();
                    if (messageText.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('chats/${widget.chatId}/messages')
                          .add({
                        'text': messageText,
                        'sender': FirebaseAuth.instance.currentUser!.email,
                        'timestamp': FieldValue.serverTimestamp(),
                        'chatId': widget.chatId,
                      });
                      _messageController.clear();
                      _scrollController.animateTo(
                        0.0,
                        curve: Curves.easeOut,
                        duration: const Duration(milliseconds: 300),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}