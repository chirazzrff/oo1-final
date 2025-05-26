import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentAttendanceScreen extends StatefulWidget {
  static const String routeName = 'StudentAttendanceScreen';

  const StudentAttendanceScreen({super.key});

  @override
  _StudentAttendanceScreenState createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> attendanceList = [];
  bool isLoading = true;

  final TextEditingController studentCodeController = TextEditingController();
  Map<String, dynamic>? studentDetails;
  bool? isPresent;

  @override
  void dispose() {
    studentCodeController.dispose();
    super.dispose();
  }

  Future<void> fetchAttendanceByStudentCode(String code) async {
    setState(() {
      isLoading = true;
      studentDetails = null;
      isPresent = null;
    });

    final response = await supabase
        .from('attendance')
        .select('student_code, student_name, date, present, course')
        .eq('student_code', code)
        .order('date', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      setState(() {
        studentDetails = response;
        isPresent = response['present'] as bool?;
        isLoading = false;
      });
    } else {
      setState(() {
        studentDetails = null;
        isPresent = null;
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code étudiant introuvable')),
      );
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
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
      appBar: AppBar(
        title: const Text(
          "Vérifier Présence Étudiant",
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
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        child: Column(
          children: [
            // 🔹 Nouveau TextField modifié ici :
            TextField(
              controller: studentCodeController,
              decoration: InputDecoration(
                labelText: 'Entrez le code étudiant',
                labelStyle: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                ),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    final code = studentCodeController.text.trim();
                    if (code.isNotEmpty) {
                      fetchAttendanceByStudentCode(code);
                    }
                  },
                ),
              ),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  fetchAttendanceByStudentCode(value.trim());
                }
              },
            ),
            const SizedBox(height: 24),
            if (isLoading)
              const CircularProgressIndicator(color: Colors.white),
            if (!isLoading && studentDetails != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nom: ${studentDetails!['student_name'] ?? 'Inconnu'}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E3A59),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${formatDate(studentDetails!['date'] ?? '')}',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cours: ${studentDetails!['course'] ?? 'Inconnu'}',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Présence: ${isPresent == true ? "Présent" : "Absent"}',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isPresent == true ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isLoading && studentDetails == null)
              Text(
                "Aucun étudiant trouvé avec ce code.",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
