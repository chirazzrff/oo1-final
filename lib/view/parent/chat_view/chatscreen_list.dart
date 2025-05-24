import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oo/view/screens/Signup_Screen/Signup_Screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatWithUserByIdScreen extends StatefulWidget {
  static const String routeName = '/ChatWithUserByIdScreen';
  const ChatWithUserByIdScreen({super.key, required this.userId});
  final String userId;

  @override
  State<ChatWithUserByIdScreen> createState() => _ChatWithUserByIdScreenState();
}

class _ChatWithUserByIdScreenState extends State<ChatWithUserByIdScreen> {
  final TextEditingController messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    final senderId = Supabase.instance.client.auth.currentUser?.id;
    final receiverId = widget.userId;

    if (senderId == null || receiverId.isEmpty) return;

    try {
      final response = await Supabase.instance.client
          .from('messages')
          .select()
          .or(
            'and(sender_id.eq.$senderId,receiver_id.eq.$receiverId),and(sender_id.eq.$receiverId,receiver_id.eq.$senderId)',
          )
          .order('created_at')
          .limit(100);

      // Reverse the messages to display the latest at the bottom
      setState(() {
        messages = List<Map<String, dynamic>>.from(response.reversed);
      });

      // Scroll to the bottom after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  Future<void> sendMessage(String receiverId) async {
    final senderId = Supabase.instance.client.auth.currentUser?.id;
    final content = messageController.text.trim();

    await Supabase.instance.client.from('messages').insert({
      'sender_id': senderId,
      'receiver_id': receiverId,
      'content': content,
    });

    try {
      await Supabase.instance.client.from('chat').upsert({
        'user1_id': senderId,
        'user2_id': receiverId,
        'last_message': content,
      });
    } catch (e) {
      print('Error updating chat: $e');
    }

    messageController.clear();
    fetchMessages();
  }

  String formatTimestamp(String timestamp) {
    final date = DateTime.tryParse(timestamp);
    return date != null ? DateFormat('hh:mm a').format(date) : '';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Color(0xFF8E9EFB),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: myColor),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSender = message['sender_id'] == currentUserId;
                  final alignment =
                      isSender ? Alignment.centerRight : Alignment.centerLeft;
                  final bubbleColor =
                      isSender ? Colors.blue.shade100 : Colors.grey.shade200;

                  return Align(
                    alignment: alignment,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      decoration: BoxDecoration(
                        color: bubbleColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message['content'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatTimestamp(message['created_at']),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            SafeArea(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(
                          color:
                              Colors
                                  .black87, // Set a clear readable color for the input text
                          fontSize: 16, // Optimal font size for readability
                          fontWeight:
                              FontWeight
                                  .w500, // Semi-bold text for better emphasis
                        ),
                        decoration: InputDecoration(
                          // Focused border style
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.blue,
                              width: 2,
                            ),
                          ),

                          // Default border style
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),

                          // Hint text
                          hintText: "Type a message...",
                          hintStyle: TextStyle(
                            color:
                                Colors
                                    .grey
                                    .shade500, // Subtle gray for hint text
                            fontSize: 16,
                          ),

                          // Label text
                          labelStyle: TextStyle(
                            color:
                                Colors.black54, // Darker shade for label text
                          ),

                          // Customizing text area appearance
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),

                          // Floating label when focused
                          floatingLabelBehavior: FloatingLabelBehavior.auto,

                          // Fill color for background
                          filled: true,
                          fillColor:
                              Colors
                                  .grey
                                  .shade100, // Soft background color for better contrast
                          // Remove the icon prefix style if it's not required
                          prefixStyle: TextStyle(color: Colors.transparent),

                          // Border radius for a smoother rounded look
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide:
                                BorderSide.none, // No border on the inside
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => sendMessage(widget.userId),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.shade700,
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
