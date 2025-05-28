import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:oo/view/student/notifications_screen.dart';
import 'package:oo/view/teacher/CahierDeTexteScreen.dart';
import 'package:oo/view/teacher/ChangePasswordScreen.dart';
import 'package:oo/view/teacher/EmploiDuTempsScreen.dart';
import 'package:oo/view/teacher/ExamResultsScreen.dart';
import 'package:oo/view/teacher/SyllabusScreen.dart';
import 'package:oo/view/screens/login_screen/login_screen.dart';

import '../../teacher/attendance_screen.dart';
import '../../teacher/MesCoursScreen.dart';
import '../../teacher/StudentsListScreen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({Key? key}) : super(key: key);
  static String routeName = 'TeacherHomeScreen';

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  String teacherName = 'Professeur';

  @override
  void initState() {
    super.initState();
    fetchTeacherName();
  }

  Future<void> fetchTeacherName() async {
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
            teacherName = response['full_name']?.toString().trim().isNotEmpty == true
                ? response['full_name']
                : 'Professeur';
          });
        } else {
          print('⚠️ Aucun profil trouvé pour l\'utilisateur : ${user.id}');
        }
      } catch (e) {
        print('❌ Erreur lors de la récupération du nom du professeur : $e');
      }
    } else {
      print('⚠️ Aucun utilisateur connecté');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond dégradé sur tout le body
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER avec background transparent (donc dégradé visible)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Espace Professeur",
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
                      "Bienvenue, $teacherName 👋",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Container avec coins arrondis MAIS sans fond blanc (transparent)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    // Plus de couleur blanche ici, juste coins arrondis
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.95,
                    children: [
                      TeacherCard(
                        icon: Icons.group_add,
                        title: " ajouté un Coure",
                        onTap: () {
                          final teacherId = Supabase.instance.client.auth.currentUser?.id;
                          if (teacherId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddCourseMaterialScreen(teacherId: teacherId),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vous devez être connecté.')),
                            );
                          }
                        },
                      ),
                      TeacherCard(icon: Icons.assignment, title: "Cahier de texte", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CahierDeTexteScreen()))),
                      TeacherCard(icon: Icons.schedule, title: "Emploi du temps", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  EmploiDuTempsScreen()))),
                      TeacherCard(icon: Icons.notifications, title: "Notifications", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  NotificationsScreen()))),
                      TeacherCard(icon: Icons.lock, title: "Mot de passe", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  ChangePasswordScreen()))),
                      TeacherCard(icon: Icons.people, title: "Liste des élèves", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  StudentListPage()))),
                      TeacherCard(icon: Icons.assignment_turned_in, title: "Résultats examens", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) =>  AddStudentGradeScreen()))),
                      TeacherCard(icon: Icons.book, title: "programme", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyllabusScreen()))),
                      TeacherCard(icon: Icons.check_circle, title: "la présence", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen()))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const TeacherCard({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Gardé blanc ici pour les boutons, sinon lisibilité faible
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFF345FB4)),
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
