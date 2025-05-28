import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentGradesScreen extends StatefulWidget {
  const ParentGradesScreen({Key? key}) : super(key: key);

  @override
  State<ParentGradesScreen> createState() => _ParentGradesScreenState();
}

class _ParentGradesScreenState extends State<ParentGradesScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> students = [];
  String? selectedStudentId;
  List<Map<String, dynamic>> grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadStudents();
  }

  Future<void> loadStudents() async {
    final parentId = supabase.auth.currentUser?.id;
    if (parentId == null) return;

    final response = await supabase
        .from('students')
        .select('id, full_name')
        .eq('parent_id', parentId);

    setState(() {
      students = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> loadGradesForStudent(String studentId) async {
    setState(() {
      isLoading = true;
    });

    final response = await supabase
        .from('grades')
        .select('subject, grade, evaluation, date')
        .eq('student_id', studentId)
        .order('date', ascending: false);

    setState(() {
      grades = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  IconData getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
        return Icons.calculate;
      case 'physics':
        return Icons.science;
      case 'french':
        return Icons.language;
      case 'history':
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    'La note de mon enfant',
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

            // Dropdown to select child
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<String>(
                value: selectedStudentId,
                style: const TextStyle(color: Colors.black), // Selected text color
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Selection un etudiant',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: students.map((student) {
                  return DropdownMenuItem<String>(
                    value: student['id'],
                    child: Text(
                      student['full_name'],
                      style: const TextStyle(color: Colors.black), // Dropdown list text color
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedStudentId = value;
                    });
                    loadGradesForStudent(value);
                  }
                },
              ),
            ),

            const SizedBox(height: 10),

            // Grades List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : grades.isEmpty
                  ? const Center(
                child: Text(
                  'l\'etudiant n\'existe pas.',
                  style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                ),
              )
                  : ListView.builder(
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
                        '${grade['subject']} - ${grade['note']}/20',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF345FB4),
                        ),
                      ),
                      subtitle: Text(
                        '${grade['evaluation']} • $date',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
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
