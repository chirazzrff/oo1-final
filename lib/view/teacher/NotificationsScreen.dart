import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notifications = [];
  bool _pushNotificationEnabled = true;
  bool _emailNotificationEnabled = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserNotifications();
  }

  Future<void> fetchUserNotifications() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final response = await supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .order('date', ascending: false);

    setState(() {
      notifications = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(notification['titre']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Contenu: ${notification['contenu']}"),
            SizedBox(height: 10),
            Text("Date: ${notification['date']}"),
            SizedBox(height: 10),
            Text("Statut: ${notification['status']}"),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await supabase.from('notifications').update({'status': 'Lu'}).eq('id', notification['id']);
              fetchUserNotifications();
              Navigator.pop(context);
            },
            child: Text("Marquer comme lu"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? Center(child: Text("Aucune notification"))
          : ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: notif['status'] == 'Lu'
                ? Colors.green.shade50
                : Colors.red.shade50,
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.all(12),
              leading: Icon(
                notif['category'] == 'Cours'
                    ? Icons.book
                    : notif['category'] == 'Examen'
                    ? Icons.event
                    : Icons.notifications,
                color: notif['status'] == 'Lu'
                    ? Colors.green
                    : Colors.red,
                size: 30,
              ),
              title: Text(
                notif['titre'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  notif['contenu'],
                  style: TextStyle(fontSize: 16),
                ),
              ),
              trailing: Text(
                notif['date'],
                style: TextStyle(color: Colors.grey),
              ),
              onTap: () => _showNotificationDetails(notif),
            ),
          );
        },
      ),
    );
  }
}
