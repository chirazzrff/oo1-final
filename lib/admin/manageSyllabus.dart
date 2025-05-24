import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'select_teacher_screen.dart';
import 'select_students_screen.dart';

class ManageSyllabusScreen extends StatefulWidget {
  static const String routeName = '/manageSyllabus';
  const ManageSyllabusScreen({super.key});

  @override
  State<ManageSyllabusScreen> createState() => _ManageSyllabusScreenState();
}

class _ManageSyllabusScreenState extends State<ManageSyllabusScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> modules = [
    {'name': 'Mathématiques', 'groups': []},
    {'name': 'Sciences Physiques', 'groups': []},
    {'name': 'Sciences de la Vie et de la Terre (SVT)', 'groups': []},
    {'name': 'Langue Arabe', 'groups': []},
    {'name': 'Langue Française', 'groups': []},
    {'name': 'Langue Anglaise', 'groups': []},
    {'name': 'Philosophie', 'groups': []},
    {'name': 'Histoire-Géographie', 'groups': []},
    {'name': 'Éducation Islamique', 'groups': []},
    {'name': 'Éducation Civique', 'groups': []},
    {'name': 'Informatique', 'groups': []},
    {'name': 'Technologie', 'groups': []},
    {'name': 'Sciences de l’Ingénieur', 'groups': []},
    {'name': 'Économie et Gestion', 'groups': []},
    {'name': 'Langue Espagnole', 'groups': []},
    {'name': 'Langue Allemande', 'groups': []},
    {'name': 'Éducation Physique et Sportive', 'groups': []},
  ];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups() async {
    final groups = await supabase.from('course_groups').select();
    for (var module in modules) {
      final moduleGroups = groups.where((g) => g['course_name'] == module['name']).toList();

      final detailedGroups = await Future.wait(moduleGroups.map((group) async {
        // Obtenir le nom de l’enseignant
        final teacherRes = await supabase
            .from('teachers')
            .select('full_name')
            .eq('id', group['teacher_id'])
            .single();

        // Obtenir les noms des élèves
        final studentIds = List<String>.from(group['student_ids'] ?? []);
        final studentsRes = studentIds.isEmpty
            ? []
            : await supabase
            .from('students')
            .select('full_name')
            .inFilter('id', studentIds);

        return {
          'id': group['id'],
          'teacher': teacherRes['full_name'],
          'students': studentsRes.map((s) => s['full_name'] as String).toList(),
        };
      }));

      setState(() {
        module['groups'] = detailedGroups;
      });
    }
  }

  Future<void> _createNewGroup(int mIndex) async {
    final teacher = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(builder: (_) => const SelectTeacherScreen()),
    );
    if (teacher == null) return;

    final students = await Navigator.push<List<Map<String, dynamic>>?>(
      context,
      MaterialPageRoute(builder: (_) => const SelectStudentsScreen()),
    );
    if (students == null || students.isEmpty) return;

    final studentIds = students.map((s) => s['id'] as String).toList();
    final studentNames = students.map((s) => s['name'] as String).toList();

    try {
      final response = await supabase
          .from('course_groups')
          .insert({
        'course_name': modules[mIndex]['name'],
        'teacher_id': teacher['id'],
        'student_ids': studentIds,
      })
          .select();

      if (response.isNotEmpty) {
        final newGroup = response.first;
        setState(() {
          modules[mIndex]['groups'].add({
            'id': newGroup['id'],
            'teacher': teacher['name'],
            'students': studentNames,
          });
        });
      }
    } catch (e) {
      debugPrint('Erreur insertion: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'insertion : $e")),
      );
    }
  }

  Future<void> _addStudentsToGroup(int mIndex, Map<String, dynamic> group) async {
    final newStudents = await Navigator.push<List<Map<String, dynamic>>?>(
      context,
      MaterialPageRoute(builder: (_) => const SelectStudentsScreen()),
    );
    if (newStudents == null || newStudents.isEmpty) return;

    final newStudentIds = newStudents.map((s) => s['id'] as String).toList();
    final newStudentNames = newStudents.map((s) => s['name'] as String).toList();

    // Récupération de tous les anciens ID
    final groupIndex = modules[mIndex]['groups'].indexOf(group);
    final currentIds = await supabase
        .from('course_groups')
        .select('student_ids')
        .eq('id', group['id'])
        .single();

    final updatedIds = List<String>.from(currentIds['student_ids'] ?? [])..addAll(newStudentIds.toSet());

    await supabase.from('course_groups').update({
      'student_ids': updatedIds,
    }).eq('id', group['id']);

    setState(() {
      modules[mIndex]['groups'][groupIndex]['students'].addAll(newStudentNames);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
      appBar: AppBar(
        title: const Text("📚 Gérer les cours"),
        backgroundColor: const Color(0xFF8E9EFB),
        centerTitle: true,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: modules.length,
        itemBuilder: (context, mIndex) {
          final module = modules[mIndex];
          final groups = module['groups'] as List;

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              title: Text(
                "📘 ${module['name']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              children: [
                if (groups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("Aucun groupe disponible",
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  )
                else
                  ...groups.map((g) {
                    return ListTile(
                      leading: const Icon(Icons.group, color: Color(0xFF345FB4)),
                      title: Text("Prof : ${g['teacher']}"),
                      subtitle: Text("Élèves : ${(g['students'] as List).join(', ')}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.person_add, color: Color(0xFF345FB4)),
                        onPressed: () => _addStudentsToGroup(mIndex, g),
                      ),
                    );
                  }).toList(),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Créer un nouveau groupe"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB8C6DB),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => _createNewGroup(mIndex),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
