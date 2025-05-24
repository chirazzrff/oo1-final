import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TeacherGroupsScreen extends StatefulWidget {
  static var routeName;

  const TeacherGroupsScreen({super.key});

  @override
  State<TeacherGroupsScreen> createState() => _TeacherGroupsScreenState();
}

class _TeacherGroupsScreenState extends State<TeacherGroupsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> groups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherGroups();
  }

  Future<void> _fetchTeacherGroups() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final res = await supabase
        .from('course_groups')
        .select()
        .eq('teacher_id', user.id);

    setState(() {
      groups = List<Map<String, dynamic>>.from(res);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF2FF),
      appBar: AppBar(
        title: const Text('Groups'),
        centerTitle: true,
        backgroundColor: const Color(0xFF345FB4),
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : groups.isEmpty
          ? const Center(
        child: Text(
          'NO Group',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final module = group['course_name'] ?? 'course inconnu';
          final students = List<String>.from(group['student_names'] ?? []);

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.group, color: Color(0xFF345FB4)),
              title: Text(
                module,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF345FB4),
                ),

              ),
              subtitle: Text(
                'Student:\n${students.join(', ')}',
                style: const TextStyle(fontSize: 14),
              ),
            ),
          );
        },
      ),
    );
  }
}
