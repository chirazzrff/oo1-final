import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../chat_view/list_user.dart';
import '../screens/login_screen/login_screen.dart';
import 'student_support_screen.dart';

import 'student_homework_screen.dart';
import 'student_grades_screen.dart';
import 'student_details_screen.dart';
import 'student_contact_screen.dart';
import 'student_attendance_screen.dart';
import 'notifications_screen.dart';
import 'edit_student_profile_screen.dart';
import 'student_profile_screen.dart';
import '../chat_view/chatscreen_list.dart'; // Assure-toi que ce chemin est correct

class StudentHomeScreen extends StatefulWidget {
  static const String routeName = 'StudentHomeScreen';

  const StudentHomeScreen({Key? key}) : super(key: key);

  @override
  _StudentHomeScreenState createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  String studentName = "Élève";
  String school = "École";
  String photoUrl = 'https://via.placeholder.com/150';

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('students')
          .select()
          .eq('id', userId)
          .single();

      if (mounted && response != null) {
        setState(() {
          studentName = response['full_name'] ?? "Élève";
          school = response['school'] ?? "École";
          photoUrl = response['photo_url'] ?? 'https://via.placeholder.com/150';
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des données étudiant : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // EN-TÊTE
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
                        "Tableau de bord Élève",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Bienvenue, $studentName 👋",
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

            // GRID DE CARTES
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  StudentCard(
                    icon: Icons.assignment,
                    title: "Devoirs",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentHomeworkScreen(homeworkList: [],)),
                    ),
                  ),
                  StudentCard(
                    icon: Icons.grade,
                    title: "Notes",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentGradesScreen()),
                    ),
                  ),
                  StudentCard(
                    icon: Icons.check_circle,
                    title: "Assiduité",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentAttendanceScreen()),
                    ),
                  ),
                  StudentCard(
                    icon: Icons.support_agent,
                    title: "Support",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentSupportScreen()),
                    ),
                  ),
                  StudentCard(
                    icon: Icons.message,
                    title: "Chats",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserListScreen()),
                    ),
                  ),
                  StudentCard(
                    icon: Icons.person,
                    title: "Profil",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => StudentProfileScreen()),
                    ),
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

class StudentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const StudentCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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