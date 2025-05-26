import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentGradesScreen extends StatefulWidget {

  const ParentGradesScreen({Key? key}) : super(key: key);

  @override
  State<ParentGradesScreen> createState() => _ParentGradesScreenState();
}

class _ParentGradesScreenState extends State<ParentGradesScreen> {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchChildGrades() async {
    final parentId = supabase.auth.currentUser?.id;
    if (parentId == null) {
      throw Exception("Parent non connecté.");
    }

    // Étape 1: Trouver les enfants de ce parent
    final students = await supabase
        .from('students')
        .select('id, full_name')
        .eq('parent_id', parentId);

    if (students == null || students.isEmpty) {
      return [];
    }

    final studentIds = students.map((s) => s['id']).toList();

    // Étape 2: Récupérer les notes
    final grades = await supabase
        .from('grades')
        .select('student_id, subject, grade, evaluation, date')
        .inFilter('student_id', studentIds)
        .order('date', ascending: false);

    // Ajouter le nom de l’élève à chaque note
    final gradesWithNames = grades.map<Map<String, dynamic>>((grade) {
      final student = students.firstWhere((s) => s['id'] == grade['student_id']);
      return {
        ...grade,
        'student_name': student['full_name'],
      };
    }).toList();

    return gradesWithNames;
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
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notes de mes enfants',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.family_restroom, color: Colors.white, size: 26),
                ],
              ),
            ),

            // Grades List
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchChildGrades(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erreur : ${snapshot.error}',
                        style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    );
                  } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune note trouvée.',
                        style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    );
                  }

                  final grades = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: grades.length,
                    itemBuilder: (context, index) {
                      final grade = grades[index];
                      final date = grade['date'].toString().split('T').first;
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
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
                            '${grade['subject']} - ${grade['grade']}/20',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF345FB4),
                            ),
                          ),
                          subtitle: Text(
                            '${grade['student_name']} • ${grade['evaluation']} • $date',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
