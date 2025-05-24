import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pour Poppins (ajoute google_fonts dans pubspec.yaml)
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class SyllabusScreen extends StatefulWidget {
  const SyllabusScreen({super.key});

  @override
  State<SyllabusScreen> createState() => _SyllabusScreenState();
}

class _SyllabusScreenState extends State<SyllabusScreen> {
  String subjects =
      "- Introduction à la matière\n- Chapitres principaux\n- Travaux pratiques";
  String dates =
      "- Début du cours : 10 Septembre\n- Examen partiel : 5 Novembre\n- Examen final : 20 Décembre";
  String objectives =
      "- Comprendre les concepts de base\n- Appliquer les notions en contexte réel\n- Développer l’esprit critique";
  String evaluation =
      "- 30% contrôle continu\n- 30% projet\n- 40% examen final";

  final Color mainBlue = const Color(0xFF345FB4);
  final Color mainOrange = const Color(0xFFFF8C42);

  Future<void> _downloadSyllabus() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '📘 Sujets abordés',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(subjects),
              pw.SizedBox(height: 20),
              pw.Text(
                '📅 Dates importantes',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(dates),
              pw.SizedBox(height: 20),
              pw.Text(
                '🎯 Objectifs du cours',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(objectives),
              pw.SizedBox(height: 20),
              pw.Text(
                '📝 Modalités d’évaluation',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(evaluation),
            ],
          );
        },
      ),
    );

    final output = await getExternalStorageDirectory();
    final file = File('${output!.path}/syllabus.pdf');
    await file.writeAsBytes(await pdf.save());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Syllabus téléchargé à ${file.path}')),
    );
  }

  Future<void> _shareSyllabus() async {
    String syllabusContent = '''
📘 Sujets abordés:
$subjects

📅 Dates importantes:
$dates

🎯 Objectifs du cours:
$objectives

📝 Modalités d’évaluation:
$evaluation
''';

    await Share.share(syllabusContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dégradé de fond doux comme dans AdminDashboard
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Syllabus du cours",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                section("📘 Sujets abordés", subjects),
                section("📅 Dates importantes", dates),
                section("🎯 Objectifs du cours", objectives),
                section("📝 Modalités d'évaluation", evaluation),
                const SizedBox(height: 30),
                _buildButton(
                  "Gérer le syllabus",
                  Icons.edit,
                  mainOrange,
                  () async {
                    // ici tu gardes ton code de navigation vers SyllabusEditScreen
                  },
                ),
                const SizedBox(height: 20),
                _buildButton(
                  "Télécharger le syllabus",
                  Icons.download,
                  mainBlue,
                  _downloadSyllabus,
                ),
                const SizedBox(height: 20),
                _buildButton(
                  "Partager le syllabus",
                  Icons.share,
                  Colors.green,
                  _shareSyllabus,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget section(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: mainBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: Colors.grey[800],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
