import 'package:flutter/material.dart';
import 'package:oo/admin/manage_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatefulWidget {
  static const String routeName = 'NotificationsScreen';

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> notifications = [];
  bool isLoading = true;

  final bool isAdmin = true; // À remplacer par une vraie vérification

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await supabase
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        notifications = response;
        isLoading = false;
      });
    } catch (error) {
      print('Erreur lors de la récupération: $error');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des notifications')),
      );
    }
  }

  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notif) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(notif['title'] ?? ''),
          content: Text(notif['message'] ?? 'Aucun message'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  void _goToManageNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManageNotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : notifications.isEmpty
                ? Center(
                    child: Text(
                      'Aucune notification trouvée.',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE0E7FF),
                            child: const Icon(Icons.notifications, color: Color(0xFF5A66F1)),
                          ),
                          title: Text(
                            notif['title'] ?? '',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E3A59),
                            ),
                          ),
                          subtitle: Text(
                            'Par : ${notif['source'] ?? 'Inconnu'}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                          onTap: () => _showNotificationDetails(context, notif),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: _goToManageNotifications,
              backgroundColor: const Color(0xFF5A66F1),
              child: const Icon(Icons.add),
              tooltip: 'Ajouter une notification',
            )
          : null,
    );
  }
}
