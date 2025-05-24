import 'package:flutter/material.dart';

class HomeworkScreen extends StatelessWidget {
  const HomeworkScreen({super.key});

  // Liste des devoirs (exemple statique pour le moment)
  final List<Map<String, String>> homeworkList = const [
    {"subject": "Maths", "task": "Exercice 5 page 23"},
    {"subject": "Physique", "task": "Rédiger un rapport sur l’énergie"},
    {"subject": "Français", "task": "Lecture chapitre 2 + résumé"},
    {"subject": "Histoire", "task": "Réviser la Révolution Française"},
  ];

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
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Row(
                  children: const [
                    Text(
                      'Suivi des devoirs',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              // CONTENU
              homeworkList.isEmpty
                  ? const Center(
                      child: Text(
                        "Aucun devoir pour le moment.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: homeworkList.length,
                        itemBuilder: (context, index) {
                          final item = homeworkList[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.assignment,
                                    color: Color(0xFF345FB4)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item["subject"] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Color(0xFF345FB4),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item["task"] ?? '',
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
