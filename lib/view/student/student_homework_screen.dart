import 'package:flutter/material.dart';

class StudentHomeworkScreen extends StatelessWidget {
  const StudentHomeworkScreen({super.key, required List homeworkList});

  // Liste des devoirs (exemple statique pour le moment)
  final List<Map<String, String>> homeworkList = const [
    {"subject": "Maths", "task": "Faire les exercices 1 à 3 page 45"},
    {"subject": "SVT", "task": "Préparer le schéma du chapitre 4"},
    {"subject": "Anglais", "task": "Apprendre le vocabulaire unité 5"},
    {"subject": "Technologie", "task": "Compléter le projet de maquette"},
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
              // HEADER avec flèche retour
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context); // Retour à la page précédente
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Devoirs de l’élève',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
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
