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
      appBar: AppBar(
        title: const Text('My Child\'s Attendance'),
        backgroundColor: const Color(0xFF6C7BFF),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : attendanceRecords.isEmpty
          ? const Center(child: Text('No attendance records found.'))
          : ListView.builder(
        itemCount: attendanceRecords.length,
        itemBuilder: (context, index) {
          final record = attendanceRecords[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Icon(
                record['present'] ? Icons.check_circle : Icons.cancel,
                color: record['present'] ? Colors.green : Colors.red,
              ),
              title: Text('${record['student_name']} - ${record['course']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Date: ${record['date']}'),
                  if (record['comment'] != null && record['comment'].toString().isNotEmpty)
                    Text('Comment: ${record['comment']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
