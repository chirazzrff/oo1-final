import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentResultsScreen extends StatefulWidget {
  static const String routeName = 'StudentResultsScreen';
  final String studentId;

  const StudentResultsScreen({super.key, required this.studentId});

  @override
  State<StudentResultsScreen> createState() => _StudentResultsScreenState();
}

class _StudentResultsScreenState extends State<StudentResultsScreen> {
  late final Stream<List<Map<String, dynamic>>> _resultsStream;

  @override
  void initState() {
    super.initState();
    _resultsStream = Supabase.instance.client
        .from('student_results')
        .stream(primaryKey: ['id'])
        .eq('student_id', widget.studentId);
  }

  double calculateAverage(List<Map<String, dynamic>> results) {
    if (results.isEmpty) return 0.0;
    double total = 0;
    for (var row in results) {
      total += (row['grade'] as num).toDouble();
    }
    return total / results.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Résultats de l'élève")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _resultsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucun résultat trouvé"));
          } else {
            final results = snapshot.data!;
            final average = calculateAverage(results);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Moyenne générale : ${average.toStringAsFixed(2)} / 20",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: results.length,
                      itemBuilder: (context, index) {
                        final row = results[index];
                        final subject = row['subject'] as String;
                        final grade = (row['grade'] as num).toDouble();

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          child: ListTile(
                            leading: const Icon(Icons.book, color: Colors.blue),
                            title: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Note : ${grade.toStringAsFixed(2)} / 20"),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
