import 'package:flutter/material.dart';

class LessonCompensationScreen extends StatefulWidget {
  static String routeName = 'LessonCompensationScreen';

  const LessonCompensationScreen({super.key});

  @override
  _LessonCompensationScreenState createState() =>
      _LessonCompensationScreenState();
}

class _LessonCompensationScreenState extends State<LessonCompensationScreen> {
  TextEditingController searchController = TextEditingController();

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  List<Map<String, dynamic>> lessons = [
    {"name": "Maths", "isCompensated": true},
    {"name": "Physique", "isCompensated": false},
    {"name": "Informatique", "isCompensated": true},
    {"name": "Chimie", "isCompensated": false},
  ];
  List<Map<String, dynamic>> filteredLessons = [];

  @override
  void initState() {
    super.initState();
    filteredLessons = lessons;
  }

  void filterLessons(String query) {
    setState(() {
      filteredLessons = lessons
          .where((lesson) =>
              lesson["name"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Pas d'appBar, on affiche titre custom en haut
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            const Text(
              "Compensation des leçons",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Rechercher une leçon",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 10),

            // SEARCH BAR
            TextField(
              controller: searchController,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.black87,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Color(0xFF345FB4)),
                hintText: "Tapez le nom d'une leçon",
                hintStyle: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: filterLessons,
            ),
            const SizedBox(height: 20),

            // LESSON LIST
            Expanded(
              child: filteredLessons.isEmpty
                  ? Center(
                      child: Text(
                        "Aucune leçon trouvée.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredLessons.length,
                      itemBuilder: (context, index) {
                        bool isCompensated =
                            filteredLessons[index]["isCompensated"];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 5),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 20),
                            title: Text(
                              filteredLessons[index]["name"],
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Color(0xFF345FB4),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCompensated
                                    ? Colors.green[100]
                                    : Colors.red[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isCompensated ? Icons.check : Icons.close,
                                color:
                                    isCompensated ? Colors.green : Colors.red,
                                size: 32,
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
