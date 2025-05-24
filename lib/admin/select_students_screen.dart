import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectStudentsScreen extends StatefulWidget {
  const SelectStudentsScreen({super.key});

  @override
  State<SelectStudentsScreen> createState() => _SelectStudentsScreenState();
}

class _SelectStudentsScreenState extends State<SelectStudentsScreen> {
  List<Map<String, dynamic>> selectedStudents = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
      appBar: AppBar(
        title: const Text("Sélectionner les élèves"),
        backgroundColor: const Color(0xFF345FB4),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, selectedStudents),
            child: const Text('Terminé', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('students').select(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erreur de chargement des élèves"));
          }

          final students = snapshot.data!;
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final name = student['full_name'] ?? 'Inconnu';
              final id = student['id'];
              final isSelected = selectedStudents.any((s) => s['id'] == id);

              return CheckboxListTile(
                secondary: const Icon(Icons.person, color: Color(0xFF345FB4)),
                title: Text(name),
                value: isSelected,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      selectedStudents.add({'id': id, 'name': name});
                    } else {
                      selectedStudents.removeWhere((s) => s['id'] == id);
                    }
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
