// TODO Implement this library.
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({Key? key}) : super(key: key);
  static String routeName = '/attendance';

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime? selectedDate;
  int? selectedCourseIndex;
  List<Map<String, dynamic>> courses = [];
  List<Map<String, dynamic>> displayedStudents = [];
  List<TextEditingController> commentControllers = [];

  // تحميل الكورسات حسب التاريخ
  Future<void> _fetchCoursesForDate(DateTime date) async {
    final supabase = Supabase.instance.client;
    String dateString =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      final response = await supabase
          .from('cours')
          .select('id, name')
          .eq('course_date', dateString);

      final List<dynamic> coursesFromDb = response;

      setState(() {
        courses = coursesFromDb.map<Map<String, dynamic>>((c) => {
          'id': c['id'],
          'name': c['name'],
        }).toList();

        selectedCourseIndex = null;
        displayedStudents = [];
        commentControllers = [];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load courses: $e')),
      );
    }
  }

  // اختيار التاريخ
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16),
              bodyMedium: TextStyle(fontSize: 14),
              bodySmall: TextStyle(fontSize: 12),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedCourseIndex = null;
        displayedStudents = [];
        commentControllers = [];
      });

      await _fetchCoursesForDate(picked);
    }
  }

  // اختيار كورس وتحميل أسماء الطلبة مع id فقط المرتبطين بالكورس
  Future<void> _selectCourse(int index) async {
    final supabase = Supabase.instance.client;
    final courseName = courses[index]['name'];

    try {
      final response = await supabase
          .from('students')
          .select('id, full_name')
          .eq('course_name', courseName);

      List<Map<String, dynamic>> students = (response as List).map((e) => {
        'id': e['id'],
        'name': e['full_name'],
        'present': false,
        'comment': '',
      }).toList();

      commentControllers = List.generate(
        students.length,
            (i) => TextEditingController(text: ''),
      );

      setState(() {
        selectedCourseIndex = index;
        displayedStudents = students;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load students: $e')),
      );
    }
  }

  // تبديل حالة الحضور
  void _togglePresence(int index, bool value) {
    setState(() {
      displayedStudents[index]['present'] = value;
    });
  }

  // تعيين تعليق للطالب
  void _setComment(int index, String comment) {
    setState(() {
      displayedStudents[index]['comment'] = comment;
    });
  }

  // حفظ الحضور في قاعدة البيانات مع اسم الطالب
  Future<void> _saveAttendance() async {
    if (selectedDate == null || selectedCourseIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and a course')),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    String courseName = courses[selectedCourseIndex!]['name'];
    String dateString =
        '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';

    // 1. حذف السجلات القديمة لنفس التاريخ واسم الكورس
    try {
      await supabase
          .from('attendance')
          .delete()
          .eq('date', dateString)
          .eq('course', courseName);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear old attendance: $error')),
      );
      return;
    }

    // 2. تجهيز بيانات الحضور الجديدة
    List<Map<String, dynamic>> attendanceRecords = List.generate(displayedStudents.length, (index) {
      return {
        'date': dateString,
        'course': courseName,
        'student_name': displayedStudents[index]['name'],
        'present': displayedStudents[index]['present'], // true/false أو 1/0 حسب جدولك
        'comment': commentControllers[index].text,
      };
    });

    // 3. إدخال السجلات الجديدة دفعة واحدة
    try {
      final response = await supabase.from('attendance').insert(attendanceRecords);
      print('Insert response: $response');

      if (response != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully!')),
        );
      } else {
        throw 'Insert returned null';
      }
    } catch (error) {
      print('Error saving attendance: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save attendance: $error')),
      );
    }
  }


  @override
  void dispose() {
    for (var controller in commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: const Color(0xFF8E9EFB),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.date_range, color: Colors.white),
                const SizedBox(width: 4),
                if (selectedDate != null)
                  Text(
                    '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Choose Date'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E9EFB),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedDate != null)
              courses.isNotEmpty
                  ? Wrap(
                spacing: 10,
                children: List.generate(courses.length, (index) {
                  return ChoiceChip(
                    label: Text(courses[index]['name']),
                    selected: selectedCourseIndex == index,
                    onSelected: (_) => _selectCourse(index),
                    selectedColor: Colors.white70,
                    backgroundColor: Colors.white24,
                    labelStyle: TextStyle(
                      color: selectedCourseIndex == index
                          ? const Color(0xFF8E9EFB)
                          : Colors.white,
                    ),
                  );
                }),
              )
                  : const Text(
                'No courses found for this date.',
                style: TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 20),
            if (selectedCourseIndex != null)
              Expanded(
                child: ListView.builder(
                  itemCount: displayedStudents.length,
                  itemBuilder: (context, index) {
                    final student = displayedStudents[index];
                    bool isPresent = student['present'];
                    return Card(
                      color: isPresent
                          ? const Color(0xFF8E9EFB)
                          : Colors.white.withOpacity(0.85),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${index + 1}. ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: isPresent ? Colors.white : Colors.black,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    student['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: isPresent ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ),
                                Checkbox(
                                  value: isPresent,
                                  onChanged: (value) {
                                    if (value != null) {
                                      _togglePresence(index, value);
                                    }
                                  },
                                  activeColor: Colors.white,
                                  checkColor: const Color(0xFF8E9EFB),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: commentControllers[index],
                              onChanged: (value) => _setComment(index, value),
                              decoration: InputDecoration(
                                hintText: 'Add comment (optional)',
                                hintStyle: TextStyle(
                                  color: isPresent ? Colors.white70 : Colors.black54,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor:
                                isPresent ? Colors.white24 : Colors.grey[200],
                              ),
                              style: TextStyle(
                                color: isPresent ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saveAttendance,
              icon: const Icon(Icons.save),
              label: const Text('Save Attendance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C7BFF),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
