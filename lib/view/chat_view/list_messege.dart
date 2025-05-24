import 'package:flutter/material.dart';
import 'package:oo/view/chat_view/chatscreen_list.dart'
    show ChatWithUserByIdScreen;
import 'package:supabase_flutter/supabase_flutter.dart';

class MessageListScreen extends StatefulWidget {
  @override
  _MessageListScreenState createState() => _MessageListScreenState();
}

class _MessageListScreenState extends State<MessageListScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<dynamic> allUsers = [];
  List<dynamic> filteredUsers = [];
  String selectedType = 'All';

  final List<String> userTypes = [
    'All',
    'Student',
    'Teacher',
    'Admin',
    'Parent',
  ];

  @override
  void initState() {
    super.initState();
    _fetchAllChats();
  }

  Future<void> _fetchAllChats() async {
    try {
      final response = await supabase
          .from('chat')
          .select()
          .order('create_at', ascending: false); // الأقدم أولاً

      setState(() {
        allUsers = response;
        filteredUsers = response;
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers(String type) {
    setState(() {
      selectedType = type;
      filteredUsers =
          type == 'All'
              ? allUsers
              : allUsers.where((user) => user['user_type'] == type).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chat List'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child:
                filteredUsers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ChatWithUserByIdScreen(
                                        name: "",
                                        userId:
                                            Supabase
                                                        .instance
                                                        .client
                                                        .auth
                                                        .currentUser
                                                        ?.id ==
                                                    user['user1_id']
                                                ? user['user2_id']
                                                : user['user1_id'],
                                      ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.indigo.shade200,
                                  child: Text(
                                    (user['full_name'] ?? '?')
                                        .toString()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  user['name1'] ?? 'No Name',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      'Type: ${user['user_type'] ?? 'N/A'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                    Text(
                                      '${user['last_message'] ?? 'Unknown'}',
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
