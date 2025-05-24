import 'package:flutter/material.dart';

// Classe centrale des couleurs utilisées dans l'app
class AppColors {
  static const Color primaryBlue = Color(0xFF345FB4);
  static const Color backgroundGradientStart = Color(0xFF8E9EFB);
  static const Color backgroundGradientEnd = Color(0xFFB8C6DB);
}

class ViewDataScreen extends StatelessWidget {
  static const String routeName = '/viewData';
  const ViewDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Tu peux aussi mettre un dégradé si tu veux (comme AdminDashboard)
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor:Color(0xFF8E9EFB) ,
              elevation: 0,
              title: const Text(
                '📊 Statistiques',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              automaticallyImplyLeading: true,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatCard(
                      title: "Nombre d'élèves",
                      value: "42",
                      icon: Icons.school,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      title: "Présences ce mois",
                      value: "350",
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      title: "Paiements effectués",
                      value: "39",
                      icon: Icons.credit_score,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
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
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }
}
