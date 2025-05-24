import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageStudentsScreen extends StatefulWidget {
  static const String routeName = '/manageStudents';

  @override
  _ManageStudentsScreenState createState() => _ManageStudentsScreenState();
}

class _ManageStudentsScreenState extends State<ManageStudentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> students = [];
  List<Map<String, dynamic>> filteredStudents = [];
  Map<String, String> attendanceStatus = {};
  bool isLoading = false;
  String searchQuery = "";
  String selectedFilter = "Tous";

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('students')
          .select('''
            id,
            full_name,
            email,
            class,
            has_paid,
            school_year,
            parent:parents(full_name),
            student_courses(courses(name))
          ''');

      final List<Map<String, dynamic>> enrichedStudents = [];

      for (var student in response) {
        final courseList = student['student_courses'] as List<dynamic>?;

        enrichedStudents.add({
          'id': student['id'],
          'full_name': student['full_name'],
          'email': student['email'],
          'class': student['class'],
          'has_paid': student['has_paid'],
          'school_year': student['school_year'],
          'parent_name': student['parent']?['full_name'] ?? 'Parent inconnu',
          'courses': courseList?.map((c) => c['courses']['name']).toList() ?? [],
        });
      }

      setState(() {
        students = enrichedStudents;
        filteredStudents = students;
      });
    } catch (e) {
      print("Erreur lors de la récupération : $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  void filterStudents(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
      filteredStudents = students.where((student) {
        final name = (student['full_name'] ?? '').toLowerCase();
        return name.contains(searchQuery);
      }).toList();
    });
  }

  void filterByCategory(String category) {
    setState(() {
      selectedFilter = category;
      filteredStudents = category == "Tous"
          ? students
          : students.where((s) => s['class'] == category).toList();
    });
  }

  void markAttendance(String id, String status) {
    setState(() {
      attendanceStatus[id] = status;
    });
  }

  Widget buildCourseList(List<dynamic>? courses) {
    if (courses == null || courses.isEmpty) {
      return const Text(
        "Aucun cours",
        style: TextStyle(fontSize: 12, color: Colors.black54),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: courses
          .map((course) => Text(
                "• $course",
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Liste des étudiants",
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF345FB4)),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF345FB4)),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: filterStudents,
                          style: const TextStyle(color: Colors.black87,fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Rechercher un étudiant',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF345FB4)),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.9),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButton<String>(
                          value: selectedFilter,
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          style: const TextStyle(
                              color: Color(0xFF345FB4), fontWeight: FontWeight.w600),
                          onChanged: (value) => filterByCategory(value!),
                          items: ['Tous', 'Classe A', 'Classe B', 'Classe C']
                              .map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? const Center(
                            child: Text(
                              "Aucun étudiant trouvé.",
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              final presence = attendanceStatus[student['id']];
                              final paid = student['has_paid'] == true;
                              final courses = student['courses'] as List<dynamic>?;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          backgroundColor: Colors.blue.shade100,
                                          child: Text(
                                            (student['full_name']?[0] ?? '?').toUpperCase(),
                                            style: const TextStyle(
                                              color: Color(0xFF345FB4),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student['full_name'] ?? '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF345FB4),
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                "Classe : ${student['class']}",
                                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                                              ),
                                              Text(
                                                "Paiement : ${paid ? 'Payé ✅' : 'Non payé ❌'}",
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: paid ? Colors.green : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (presence == "present")
                                          const Icon(Icons.check_circle, color: Colors.green)
                                        else if (presence == "absent")
                                          const Icon(Icons.cancel, color: Colors.red)
                                        else
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.check, color: Colors.green),
                                                onPressed: () => markAttendance(student['id'], "present"),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.red),
                                                onPressed: () => markAttendance(student['id'], "absent"),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text("Email : ${student['email']}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                    Text("Année scolaire : ${student['school_year']}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                    Text("Parent : ${student['parent_name']}",
                                        style: const TextStyle(fontSize: 12, color: Colors.black87)),
                                    const SizedBox(height: 5),
                                    const Text("Cours :",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF345FB4))),
                                    buildCourseList(courses),
                                  ],
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
