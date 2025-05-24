import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentTeacherChatScreen extends StatefulWidget {
  final String parentId;
  final String teacherId;
  final String parentName;
  final String teacherName;

  const ParentTeacherChatScreen({
    Key? key,
    required this.parentId,
    required this.teacherId,
    required this.parentName,
    required this.teacherName,
  }) : super(key: key);

  @override
  _ParentTeacherChatScreenState createState() => _ParentTeacherChatScreenState();
}

class _ParentTeacherChatScreenState extends State<ParentTeacherChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  Stream<List<Map<String, dynamic>>> getMessages() {
    return supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', widget.parentId)
        .eq('receiver_id', widget.teacherId)
        .order('created_at')
        .map((messages) => messages)
        .combineLatest(
      supabase
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('sender_id', widget.teacherId)
          .eq('receiver_id', widget.parentId)
          .order('created_at')
          .map((messages) => messages),
          (a, b) => [...a, ...b]..sort((x, y) => x['created_at'].compareTo(y['created_at'])),
    );
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    await supabase.from('messages').insert({
      'sender_id': widget.parentId,
      'receiver_id': widget.teacherId,
      'content': content,
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat avec ${widget.teacherName}'),
        backgroundColor: Colors.lightBlue[200],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getMessages(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                final messages = snapshot.data!;
                return ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByParent = message['sender_id'] == widget.parentId;

                    return Align(
                      alignment: isSentByParent ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                        decoration: BoxDecoration(
                          color: isSentByParent ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          message['content'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Écrire un message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: () => sendMessage(_messageController.text),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

extension on SupabaseStreamBuilder {
  eq(String s, String teacherId) {}
}
