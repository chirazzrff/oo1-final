import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oo/admin/ManageStudentsScreen.dart';
import 'package:oo/view/screens/login_screen/login_screen.dart';

import '../view/chat_view/list_user.dart';
import 'EmploiDuTempsScreen.dart';
import 'manageSyllabus.dart';
import 'manage_users.dart';
import 'manage_schools.dart';
import 'manage_payments.dart';
import 'view_data.dart';
import 'manage_notifications.dart';

class AdminDashboard extends StatefulWidget {
  static const String routeName = '/adminDashboard';

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String adminName = 'Admin';

  @override
  void initState() {
    super.initState();
    fetchAdminName();
  }

  Future<void> fetchAdminName() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null) {
      try {
        final response = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();

        if (response != null) {
          setState(() {
            adminName = response['full_name']?.toString().trim().isNotEmpty == true
                ? response['full_name']
                : 'Admin';
          });
        } else {
          print('⚠️ Aucun profil trouvé pour l\'utilisateur : ${user.id}');
        }
      } catch (e) {
        print('❌ Erreur lors de la récupération du nom admin : $e');
      }
    } else {
      print('⚠️ Aucun utilisateur connecté');
    }
  }

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              height: 160,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Text(
                        "tableau de bord ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "bienvenue, $adminName 👋",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // CARDS
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
                children: [
                  AdminCard(icon: Icons.group, title: "gérer les utilisateurs", route: ManageUsersScreen.routeName),
                  AdminCard(icon: Icons.school, title: "gérer les ecoles", route: ManageSchoolsScreen.routeName),
                  AdminCard(icon: Icons.payment, title: "gérer payment", route: ManagePaymentsScreen.routeName),
                  AdminCard(icon: Icons.bar_chart, title: "data", route: ViewDataScreen.routeName),
                  AdminCard(icon: Icons.notifications, title: "gérer notifications", route: ManageNotificationsScreen.routeName),
                  AdminCard(icon: Icons.people, title: "la liste d'etudients", route: ManageStudentsScreen.routeName),
                  AdminCard(icon: Icons.book, title: "programme", route: ManageSyllabusScreen.routeName),
                  AdminCard(icon: Icons.chat, title: "discution", route: UserListScreen.routeName),
                  AdminCard(icon: Icons.calendar_today, title: "Emploi du Temps", route: AjouterEmploiDuTempsScreen.routeName,
                  ),

                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;

  const AdminCard({
    required this.icon,
    required this.title,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Color(0xFF345FB4)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF345FB4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
