import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'parent_home_screen.dart'; // Update path if needed

class SelectChildScreen extends StatefulWidget {
  static const routeName = '/selectChild';

  const SelectChildScreen({Key? key}) : super(key: key);

  @override
  _SelectChildScreenState createState() => _SelectChildScreenState();
}

class _SelectChildScreenState extends State<SelectChildScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> students = [];
  bool isLoading = false;
  bool showResults = false;

  final Gradient myColor = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<void> fetchStudents(String searchQuery) async {
    setState(() {
      isLoading = true;
      showResults = true;
    });

    try {
      final response = await supabase
          .from('students')
          .select()
          .filter('parent_id', 'is', null)
          .ilike('full_name', '%$searchQuery%');

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

    try {
      await supabase.from('students').update({
        'parent_id': user.id,
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
      body: Container(
        decoration: BoxDecoration(gradient: myColor),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Add Your Child',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Search Field
                Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search student name',
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search, color: Color(0xFF5C6BC0)),
                        onPressed: () {
                          if (_searchController.text.trim().isNotEmpty) {
                            fetchStudents(_searchController.text.trim());
                          }
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        fetchStudents(value.trim());
                      }
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: skipSelection,
                    icon: const Icon(Icons.skip_next, color: Colors.white70),
                    label: const Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                if (isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (showResults)
                  Expanded(
                    child: students.isEmpty
                        ? const Center(
                      child: Text("No matching students found.",
                          style: TextStyle(color: Colors.white)),
                    )
                        : ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            title: Text(
                              student['full_name'] ?? 'Unknown Name',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text("ID: ${student['id']}"),
                            trailing: ElevatedButton(
                              onPressed: () =>
                                  linkStudentToParent(student['id']),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5C6BC0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Select'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
