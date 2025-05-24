import 'package:flutter/material.dart';

class SyllabusEditScreen extends StatefulWidget {
  final String initialSubjects;
  final String initialDates;
  final String initialObjectives;
  final String initialEvaluation;

  const SyllabusEditScreen({
    super.key,
    required this.initialSubjects,
    required this.initialDates,
    required this.initialObjectives,
    required this.initialEvaluation,
  });

  @override
  State<SyllabusEditScreen> createState() => _SyllabusEditScreenState();
}

class _SyllabusEditScreenState extends State<SyllabusEditScreen> {
  late TextEditingController _subjectsController;
  late TextEditingController _importantDatesController;
  late TextEditingController _courseObjectivesController;
  late TextEditingController _evaluationMethodsController;

  @override
  void initState() {
    super.initState();
    _subjectsController = TextEditingController(text: widget.initialSubjects);
    _importantDatesController = TextEditingController(text: widget.initialDates);
    _courseObjectivesController = TextEditingController(text: widget.initialObjectives);
    _evaluationMethodsController = TextEditingController(text: widget.initialEvaluation);
  }

  @override
  void dispose() {
    _subjectsController.dispose();
    _importantDatesController.dispose();
    _courseObjectivesController.dispose();
    _evaluationMethodsController.dispose();
    super.dispose();
  }

  void _saveAndReturn() {
    Navigator.pop(context, {
      'subjects': _subjectsController.text,
      'dates': _importantDatesController.text,
      'objectives': _courseObjectivesController.text,
      'evaluation': _evaluationMethodsController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le syllabus', style: TextStyle(fontSize: 18)),
        backgroundColor: Color(0xFF345FB4),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),  // Réduit l'espacement global
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sujets abordés
            Text("📘 Sujets abordés", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(
              controller: _subjectsController,
              decoration: InputDecoration(hintText: 'Ex: Chapitres, Travaux pratiques'),
              style: TextStyle(fontSize: 14),  // Taille du texte entrée
            ),
            SizedBox(height: 15),  // Espacement plus petit

            // Dates importantes
            Text("📅 Dates importantes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(
              controller: _importantDatesController,
              decoration: InputDecoration(hintText: 'Ex: Examens, Remises de travaux'),
              style: TextStyle(fontSize: 14),  // Taille du texte entrée
            ),
            SizedBox(height: 15),  // Espacement plus petit

            // Objectifs du cours
            Text("🎯 Objectifs du cours", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(
              controller: _courseObjectivesController,
              decoration: InputDecoration(hintText: 'Ex: Comprendre les bases'),
              style: TextStyle(fontSize: 14),  // Taille du texte entrée
            ),
            SizedBox(height: 15),  // Espacement plus petit

            // Modalités d’évaluation
            Text("📝 Modalités d’évaluation", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            TextField(
              controller: _evaluationMethodsController,
              decoration: InputDecoration(hintText: 'Ex: 30% contrôle continu, 40% examen final'),
              style: TextStyle(fontSize: 14),  // Taille du texte entrée
            ),
            SizedBox(height: 20),  // Espacement plus petit

            // Bouton d'enregistrement
            Center(
              child: ElevatedButton.icon(
                onPressed: _saveAndReturn,
                icon: Icon(Icons.save, color: Colors.white),
                label: Text("Enregistrer", style: TextStyle(color: Colors.white, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),  // Taille du bouton plus petite
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
