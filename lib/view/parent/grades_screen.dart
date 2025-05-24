import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradesScreen extends StatefulWidget {
  static const String routeName = '/grades';
  const GradesScreen({Key? key}) : super(key: key);

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  List<Map<String, dynamic>> _grades = [];
  bool _isLoading = true;

  final LinearGradient myGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    try {
      final response = await Supabase.instance.client
          .from('grades')
          .select('subject, grade, evaluation, date, students(full_name)')
          .order('date', ascending: false);

      setState(() {
        _grades = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement des notes : $e')),
      );
    }
  }

  IconData _getSubjectIcon(String subject) {
    switch (subject.toLowerCase()) {
      case 'math':
      case 'mathématiques':
        return Icons.calculate;
      case 'physique':
        return Icons.science;
      case 'informatique':
        return Icons.computer;
      case 'français':
        return Icons.menu_book;
      case 'histoire':
        return Icons.account_balance;
      case 'anglais':
        return Icons.language;
      default:
        return Icons.school;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ' Notes',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF8E9EFB),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: myGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _grades.isEmpty
                ? const Center(
                    child: Text(
                      'Aucune note disponible.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _grades.length,
                    itemBuilder: (context, index) {
                      final grade = _grades[index];
                      final studentName = grade['students']?['full_name'] ?? 'Inconnu';
                      final subject = grade['subject'] ?? 'Inconnu';
                      final score = grade['grade']?.toString() ?? '--';
                      final evaluation = grade['evaluation'] ?? 'Non spécifié';
                      final dateStr = grade['date'] ?? '';
                      final date = dateStr.isNotEmpty
                          ? DateFormat('dd/MM/yyyy').format(DateTime.parse(dateStr))
                          : 'N/A';

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 6,
                        shadowColor: Colors.black26,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF345FB4).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  _getSubjectIcon(subject),
                                  size: 40,
                                  color: const Color(0xFF345FB4),
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      subject,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Color(0xFF345FB4),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Élève : $studentName',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Note : $score / 20',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 15,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Évaluation : $evaluation',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Date : $date',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
