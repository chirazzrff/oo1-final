import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentGradesScreen extends StatefulWidget {
  static const String routeName = '/studentGrades';
  const StudentGradesScreen({Key? key}) : super(key: key);

  @override
  _StudentGradesScreenState createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  final supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchGrades() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }

    final response = await supabase
        .from('grades')
        .select()
        .eq('student_id', userId)
        .order('subject', ascending: true);

    return response;
  }

  IconData getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathématiques':
        return Icons.calculate;
      case 'physique':
        return Icons.science;
      case 'français':
        return Icons.language;
      case 'histoire':
        return Icons.book;
      default:
        return Icons.school;
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
            // AppBar custom avec flèche retour
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  // 🔙 Icône de retour
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    onPressed: () {
                      Navigator.pop(context); 
                      // Ou pour aller à une page spécifique :
                      // Navigator.pushReplacementNamed(context, '/studentHome');
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Mes Notes',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.school, color: Colors.white, size: 26),
                ],
              ),
            ),

            // Body
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchGrades(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erreur : ${snapshot.error.toString()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune note disponible.',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else {
                    final grades = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: grades.length,
                      itemBuilder: (context, index) {
                        final grade = grades[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            leading: Icon(
                              getSubjectIcon(grade['subject']),
                              color: const Color(0xFF345FB4),
                              size: 30,
                            ),
                            title: Text(
                              grade['subject'],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF345FB4),
                              ),
                            ),
                            subtitle: Text(
                              '${grade['evaluation']} - ${grade['date'].toString().split("T").first}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            trailing: Text(
                              grade['grade'].toString(),
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
