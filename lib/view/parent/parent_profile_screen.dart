import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'parent_home_screen.dart'; // Replace this with the correct path to the Parent Home screen file

class SelectChildScreen extends StatefulWidget {
  static const routeName = '/selectChild';

  const SelectChildScreen({Key? key}) : super(key: key);

  @override
  _SelectChildScreenState createState() => _SelectChildScreenState();
}

class _SelectChildScreenState extends State<SelectChildScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final response = await supabase
          .from('students')
          .select()
          .filter('parent_id', 'is', null);

      setState(() {
        students = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading students: $e')),
      );
    }
  }

  Future<void> linkStudentToParent(String studentId) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in.')),
      );
      return;
    }

    final parentId = user.id;

    try {
      await supabase.from('students').update({
        'parent_id': parentId,
      }).eq('id', studentId);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error linking student: $e')),
      );
    }
  }

  void skipSelection() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ParentHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Child')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: students.isEmpty
                ? const Center(child: Text("No students available."))
                : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                return ListTile(
                  title: Text(student['full_name'] ?? 'Unknown Name'),
                  subtitle: Text("ID: ${student['id']}"),
                  trailing: ElevatedButton(
                    onPressed: () => linkStudentToParent(student['id']),
                    child: const Text('Select'),
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: skipSelection,
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip for now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
