import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oo/view/screens/password/Reset%20Password.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentGradeScreen extends StatefulWidget {
  static const String routeName = '/addStudentGrade';
  const AddStudentGradeScreen({Key? key}) : super(key: key);

  @override
  _AddStudentGradeScreenState createState() => _AddStudentGradeScreenState();
}
bool isLoading = false;

class _AddStudentGradeScreenState extends State<AddStudentGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _evaluationController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> _students = [];
  String? _selectedStudentId;


  final LinearGradient myColor = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }


  Future<void> _loadStudents() async {
    try {
      final response = await Supabase.instance.client.from('students').select('id, full_name');
      setState(() {
        _students = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student loading error: $e')),
      );
    }
  }

  Future<void> _submitGrade() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedStudentId != null) {
      final subject = _subjectController.text.trim();
      final grade = double.tryParse(_gradeController.text.trim());
      final evaluation = _evaluationController.text.trim();
      final date = _selectedDate!.toIso8601String();

      if (grade == null || grade < 0 || grade > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid rating between 0 and 20.')),
        );
        return;
      }

      try {
        await Supabase.instance.client.from('grades').insert({
          'student_id': _selectedStudentId,
          'subject': subject,
          'grade': grade,
          'evaluation': evaluation,
          'date': date,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note added successfully.')),
        );

        _formKey.currentState!.reset();
        _subjectController.clear();
        _gradeController.clear();
        _evaluationController.clear();
        setState(() {
          _selectedDate = null;
          _selectedStudentId = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    } else if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _evaluationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a note',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF8E9EFB),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: myColor),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _buildCard(child: _buildStudentDropdown()),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _subjectController,
                  hintText: 'Matter',
                  obscureText: false,
                  icon: Icons.book_outlined,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _gradeController,
                  hintText: 'Note (/20)',
                  obscureText: false,
                  icon: Icons.grade_outlined,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _evaluationController,
                  hintText: 'Type of assessment',
                  obscureText: false,
                  icon: Icons.assignment_outlined,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _pickDate(),
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                      hintText: 'Assessment date',
                      icon: Icons.calendar_today,
                      obscureText: false,
                      validator: (value) => value!.isEmpty ? 'Date requise' : null,


                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const SizedBox(height: 30),
                isLoading
                    ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
                    : InkWell(
                  onTap: () async {
                    setState(() => isLoading = true);
                    await _submitGrade();
                    setState(() => isLoading = false);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(34, 245, 244, 244),
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      border: Border.all(color: Colors.white),
                    ),
                    child: const Center(
                      child: Text(
                        'Enregistrer la note',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
        child: child,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: Colors.black,

          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
            prefixIcon: Icon(icon, color: primaryColor),
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildStudentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStudentId,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: Colors.black, // 👈 ceci force le texte sélectionné à rester noir
      ),

      items: _students.map((student) {
        return DropdownMenuItem<String>(
          value: student['id'],
          child: Text(
            student['full_name'],
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStudentId = value;

        });
      },
      decoration: const InputDecoration(
        labelText: 'Select a student',
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Color.fromARGB(255, 57, 56, 56),
        ),
        border: InputBorder.none,
      ),
      validator: (value) => value == null ? 'Please select a student' : null,
    );
  }
}





// TODO Implement this library.