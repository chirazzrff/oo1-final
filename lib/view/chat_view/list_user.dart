import 'package:flutter/material.dart';
import 'package:oo/view/chat_view/chatscreen_list.dart'
    show ChatWithUserByIdScreen;
import 'package:oo/view/chat_view/list_messege.dart' show MessageListScreen;
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListScreen extends StatefulWidget {
  static const String routeName = '/UserListScreen';

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
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
    _fetchAllUsers();
  }

  Future<void> _fetchAllUsers() async {
    try {
      final response = await supabase.from('profiles').select();
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
        title: const Text('User List'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MessageListScreen()),
              );
            },
            icon: Icon(Icons.message),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // Professional Filter Chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: userTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final type = userTypes[index];
                final isSelected = selectedType == type;

                return ChoiceChip(
                  label: Text(type),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  selected: isSelected,
                  selectedColor: Colors.indigo,
                  backgroundColor: Colors.grey[200],
                  onSelected: (_) => _filterUsers(type),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // User List
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
                                        userId: user['id'],
                                        name: user["full_name"],
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
                                  user['full_name'] ?? 'No Name',
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
                                      'Gender: ${user['gender'] ?? 'Unknown'}',
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
