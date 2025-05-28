import 'package:flutter/material.dart';
import 'package:oo/admin/manage_payments.dart';
import 'package:oo/view/parent/child_regestration_screen.dart';
import 'package:oo/view/parent/parent_profile_screen.dart';
import 'package:oo/view/parent/payment_status_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../chat_view/chatscreen_list.dart';
import '../screens/login_screen/login_screen.dart';
import 'attendance_screen.dart';
import 'lesson_compensation_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  static String routeName = 'ParentHomeScreen';
  const ParentHomeScreen({Key? key}) : super(key: key);

  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  String parentName = "";
  String photoUrl = 'https://via.placeholder.com/150';
  List<Map<String, dynamic>> studentsData = [];

  @override
  void initState() {
    super.initState();
    fetchParentData();
  }

  Future<void> fetchParentData() async {
    try {
      final parentId = supabase.auth.currentUser!.id;

      final parentResponse = await supabase
          .from('Profiles')
          .select('name, photo_url')
          .eq('id', parentId)
          .maybeSingle();

      if (parentResponse != null) {
        setState(() {
          parentName = parentResponse['name'] ?? "Parent";
          photoUrl = parentResponse['photo_url'] ?? 'https://via.placeholder.com/150';
        });

        final studentsResponse = await supabase
            .from('students')
            .select()
            .eq('parent_id', parentId);

        setState(() {
          studentsData = List<Map<String, dynamic>>.from(studentsResponse);
        });
      }
    } catch (error) {
      print("Erreur lors de la récupération des données du parent: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Gradient backgroundGradient = const LinearGradient(
      colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          children: [
            // EN-TÊTE
            Container(
              width: double.infinity,
              height: 180,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Text(
                        "Tableau de bord Parent",
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
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.logout, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Bienvenue, $parentName 👋",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (studentsData.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Vos enfants :",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...studentsData.map((student) => Text(
                          "- ${student['name']}",
                          style: const TextStyle(color: Colors.white70),
                        )),
                      ],
                    ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // VUE EN GRILLE
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  ParentCard(
                    icon: Icons.payment,
                    title: "Paiements",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ParentPaymentsScreen()),
                    ),
                  ),
                  ParentCard(
                    icon: Icons.app_registration,
                    title: "Inscription Enfant",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ChildRegistrationPage()),
                    ),
                  ),
                  ParentCard(
                    icon: Icons.book_online,
                    title: "Rattrapage de Cours",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LessonCompensationScreen()),
                    ),
                  ),
                  ParentCard(
                    icon: Icons.check_circle,
                    title: "Présence",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EcranPresenceParent()),
                    ),
                  ),
                  ParentCard(
                    icon: Icons.message,
                    title: "Messages",
                    onTap: () => Navigator.pushNamed(context, '/UserListScreen'),
                  ),
                  ParentCard(
                    icon: Icons.assignment,
                    title: "Devoirs",
                    onTap: () => Navigator.pushNamed(context, 'HomeworkScreen'),
                  ),
                  ParentCard(
                    icon: Icons.grade,
                    title: "Notes",
                    onTap: () => Navigator.pushNamed(context, 'GradesScreen'),
                  ),
                  ParentCard(
                    icon: Icons.support_agent,
                    title: "Assistance",
                    onTap: () => Navigator.pushNamed(context, 'TechnicalSupportScreen'),
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

class ParentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ParentCard({
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
