import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectTeacherScreen extends StatelessWidget {
  const SelectTeacherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
      appBar: AppBar(
        title: const Text("Choisir un enseignant"),
        backgroundColor: const Color(0xFF345FB4),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Supabase.instance.client.from('teachers').select(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Erreur de chargement"));
          }

          final teachers = snapshot.data!;

          return ListView.builder(
            itemCount: teachers.length,
            itemBuilder: (context, index) {
              final teacher = teachers[index];
              return ListTile(
                title: Text(teacher['full_name'] ?? 'Inconnu'),
                onTap: () {
                  Navigator.pop(context, {
                    'id': teacher['id'],
                    'name': teacher['full_name'],
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
