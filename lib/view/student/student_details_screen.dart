import 'package:flutter/material.dart';

class StudentDetailsScreen extends StatelessWidget {
  static const String routeName = 'StudentDetailsScreen';

  final String email;
  final String phone;
  final String birthDate;
  final String academicLevel;
  final List<String> courses;
  final double average;
  final int absences;

  const StudentDetailsScreen({
    Key? key,
    required this.email,
    required this.phone,
    required this.birthDate,
    required this.academicLevel,
    required this.courses,
    required this.average,
    required this.absences,
  }) : super(key: key);

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final Color mainBlue = const Color(0xFF345FB4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond dégradé sur tout l'écran
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER custom comme dans StudentSupportScreen
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    const Text(
                      "Détails Étudiant",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Liste des détails dans des cartes blanches arrondies avec ombre
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildDetailCard('Email', email, Icons.email_outlined),
                      _buildDetailCard('Téléphone', phone, Icons.phone_outlined),
                      _buildDetailCard('Date de naissance', birthDate, Icons.cake_outlined),
                      _buildDetailCard('Niveau scolaire', academicLevel, Icons.school_outlined),
                      _buildDetailCard('Cours suivis', courses.join(', '), Icons.book_outlined),
                      _buildDetailCard('Moyenne générale', '$average / 20', Icons.score_outlined),
                      _buildDetailCard('Nombre d\'absences', '$absences', Icons.event_busy_outlined),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
        children: [
          Icon(icon, color: mainBlue, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label : $value',
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
