import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../parent/chat_with_school_screen.dart';
import '../parent/grades_screen.dart';
import '../parent/homework_screen.dart';
import 'student_profile_screen.dart';
import 'student_support_screen.dart';
import 'student_results_screen.dart';
import 'student_homework_screen.dart';
import 'student_grades_screen.dart';
import 'student_details_screen.dart';
import 'student_contact_screen.dart';
import 'student_attendance_screen.dart';
import 'notifications_screen.dart';
import 'edit_student_profile_screen.dart';

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
    final response = await supabase
        .from('students')
        .select()
        .eq('id', supabase.auth.currentUser!.id)
        .single();

    if (response != null) {
      setState(() {
        studentName = response['full_name'] ?? "Élève";
        school = response['school'] ?? "École";
        photoUrl = response['photo_url'] ?? 'https://via.placeholder.com/150';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER BLEU AVEC PHOTO
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Color(0xFF345FB4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Texte de bienvenue
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 30),
                    Text(
                      "Tableau de bord Élève",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Bienvenue, $studentName 👋",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    SizedBox(height: 5),
                    Text(
                      school,
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  ],
                ),

                // Photo de profil
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, StudentProfileScreen.routeName);
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(photoUrl),
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // GRID DE CARTES
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.symmetric(horizontal: 20),
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                StudentCard(
                  icon: Icons.book,
                  title: "Mes Cours",
                  onTap: () {},
                ),
                StudentCard(
                  icon: Icons.assignment,
                  title: "Devoirs",
                  onTap: () => Navigator.pushNamed(context, StudentHomeworkScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.grade,
                  title: "Notes",
                  onTap: () => Navigator.pushNamed(context, StudentGradesScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.chat,
                  title: "Discussion",
                  onTap: () => Navigator.pushNamed(context, ChatWithSchoolScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.support,
                  title: "Support",
                  onTap: () => Navigator.pushNamed(context, StudentSupportScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.receipt,
                  title: "Résultats",
                  onTap: () => Navigator.pushNamed(context, StudentResultsScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.details,
                  title: "Détails",
                  onTap: () => Navigator.pushNamed(context, StudentDetailsScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.contact_phone,
                  title: "Contact",
                  onTap: () => Navigator.pushNamed(context, StudentContactScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.access_alarm,
                  title: "Présence",
                  onTap: () => Navigator.pushNamed(context, StudentAttendanceScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.notifications,
                  title: "Notifications",
                  onTap: () => Navigator.pushNamed(context, NotificationsScreen.routeName),
                ),
                StudentCard(
                  icon: Icons.edit,
                  title: "Modifier Profil",
                  onTap: () => Navigator.pushNamed(context, EditStudentProfileScreen.routeName),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// WIDGET DE CARTE STYLE ÉLÈVE
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Color(0xFF345FB4)),
            SizedBox(height: 15),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF345FB4)),
            ),
          ],
        ),
      ),
    );
  }
}
