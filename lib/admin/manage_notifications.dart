import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

var myColor = LinearGradient(
  colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class ManageNotificationsScreen extends StatefulWidget {
  static const String routeName = '/manageNotifications';

  @override
  _ManageNotificationsScreenState createState() => _ManageNotificationsScreenState();
}

class _ManageNotificationsScreenState extends State<ManageNotificationsScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  String _selectedUserType = 'All'; // Parent, Teacher, Student, All
  final List<String> _userTypes = ['All', 'Parent', 'Teacher', 'Student'];

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final message = _messageController.text.trim();
    final source = 'Admin';

    if (title.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final supabase = Supabase.instance.client;
      var query = supabase.from('profiles').select('id');

      if (_selectedUserType != 'All') {
        query = query.eq('user_type', _selectedUserType);
      }

      final users = await query;

      for (final user in users) {
        await supabase.from('notifications').insert({
          'user_id': user['id'],
          'title': title,
          'message': message,
          'source': source,
          'created_at': DateTime.now().toIso8601String(),
          'status': 'Non lu',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifications sent to $_selectedUserType')),
      );

      _titleController.clear();
      _messageController.clear();
    } catch (e) {
      print('Error sending notifications: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending notifications')),
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF8E9EFB),
        title: Text("Manage Notifications"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/adminDashboard');
            // ou Navigator.pop(context); si tu veux juste revenir à l'écran précédent
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8E9EFB),
              Color(0xFFB8C6DB),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    "Send notifications to users",
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.all(7),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _selectedUserType,
                          items: _userTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type, style: TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUserType = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Select user type",
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: "Notification Title",
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            labelText: "Message",
                            labelStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSending ? null : _sendNotification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF8E9EFB),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isSending
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    "Send Notification",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
