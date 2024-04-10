import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:messenger/pages/chat_screen.dart';
import 'package:messenger/services/custom_search.dart';

class AllChatsScreen extends StatefulWidget {
  @override
  _AllChatsScreenState createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  final _chatController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  Future<void> _createChat() async {
    final chatId = FirebaseFirestore.instance.collection('chats').doc().id;
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'title': _chatController.text,
      'id': chatId, // Добавляем ID чата в документ
    });
    _chatController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Create Chat'),
                  content: TextField(
                    controller: _chatController,
                    decoration: InputDecoration(hintText: 'Chat Title'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: _createChat,
                      child: Text('Create'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('title', isGreaterThanOrEqualTo: _searchQuery)
            .where('title', isLessThan: _searchQuery + 'z')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final chat = snapshot.data!.docs[index];
                return ListTile(
                  title: Text(chat['title']),
                  subtitle: Text('ID: ${chat['id']}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(chatId: chat.id),
                      ),
                    );
                  },
                );
              },
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
