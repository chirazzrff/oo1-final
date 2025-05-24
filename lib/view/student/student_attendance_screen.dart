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

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    final response = await supabase
        .from('attendance')
        .select('date, present')
        .order('date', ascending: false);

    if (response.error == null) {
      setState(() {
        attendanceList = List<Map<String, dynamic>>.from(response.data as List);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du chargement des présences')),
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
      extendBodyBehindAppBar: true, // 👈 Pour que le dégradé passe derrière l’AppBar
      appBar: AppBar(
        title: const Text(
          "Présence des étudiants",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent, // 👈 Enlève le bleu
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : attendanceList.isEmpty
                ? Center(
                    child: Text(
                      "Aucune donnée de présence trouvée.",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final item = attendanceList[index];
                      final bool present = item['present'] ?? false;
                      final String date = item['date'] ?? '';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          leading: Icon(
                            present ? Icons.check_circle : Icons.cancel,
                            color: present ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          title: Text(
                            formatDate(date),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2E3A59),
                            ),
                          ),
                          subtitle: Text(
                            present ? "Présent" : "Absent",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: present ? Colors.green.shade700 : Colors.red.shade700,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

extension on PostgrestList {
  get error => null;
  get data => null;
}
