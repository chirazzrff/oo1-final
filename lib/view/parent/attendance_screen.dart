import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentAttendanceScreen extends StatefulWidget {
  const ParentAttendanceScreen({Key? key}) : super(key: key);

  @override
  _ParentAttendanceScreenState createState() => _ParentAttendanceScreenState();
}

class _ParentAttendanceScreenState extends State<ParentAttendanceScreen> {
  List<Map<String, dynamic>> attendanceRecords = [];
  bool isLoading = true;

  Future<void> fetchAttendanceForParent() async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) return;

    try {
      final studentsResponse = await supabase
          .from('students')
          .select('id, full_name')
          .eq('parent_id', userId);

      final List<dynamic> students = studentsResponse;

      if (students.isEmpty) {
        setState(() {
          attendanceRecords = [];
          isLoading = false;
        });
        return;
      }

      final studentNames = students.map((s) => s['full_name']).toList();

      final attendanceResponse = await supabase
          .from('attendance')
          .select('student_name, date, course, present, comment')
          .inFilter('student_name', studentNames);

      setState(() {
        attendanceRecords = List<Map<String, dynamic>>.from(attendanceResponse);
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching attendance: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAttendanceForParent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  "My Child's Attendance",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : attendanceRecords.isEmpty
                    ? const Center(
                  child: Text(
                    'No attendance records found.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final record = attendanceRecords[index];
                    final present = record['present'] == true;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor:
                            present ? Colors.green[100] : Colors.red[100],
                            child: Icon(
                              present ? Icons.check : Icons.close,
                              color: present ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${record['student_name']} - ${record['course']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.black
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date: ${record['date']}',
                                  style: const TextStyle(fontSize: 14,   color: Colors.black),

                                ),
                                if (record['comment'] != null &&
                                    record['comment'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Comment: ${record['comment']}',
                                      style: const TextStyle(color: Colors.black,
                                        fontSize: 14,


                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
