import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddStudentGradeScreen extends StatefulWidget {
  static const String routeName = '/addStudentGrade';
  const AddStudentGradeScreen({Key? key}) : super(key: key);

  @override
  _AddStudentGradeScreenState createState() => _AddStudentGradeScreenState();
}

class _AddStudentGradeScreenState extends State<AddStudentGradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _evaluationController = TextEditingController();
  DateTime? _selectedDate;

  List<Map<String, dynamic>> _students = [];
  String? _selectedStudentId;
  bool isLoading = false;

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
      final response = await Supabase.instance.client
          .from('students')
          .select('id, full_name');
      setState(() {
        _students = List<Map<String, dynamic>>.from(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de chargement : $e')),
      );
    }
  }

  Future<void> _submitGrade() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedStudentId != null) {
      final subject = _subjectController.text.trim();
      final grade = double.tryParse(_gradeController.text.trim());
      final evaluation = _evaluationController.text.trim();
      final date = _selectedDate!.toIso8601String();

      if (grade == null || grade < 0 || grade > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note invalide entre 0 et 20.')),
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
          const SnackBar(content: Text('Note ajoutée avec succès.')),
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
        const SnackBar(content: Text('Veuillez choisir une date.')),
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
        title: const Text('Ajouter une note'),
        backgroundColor: const Color(0xFF8E9EFB),
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
                _buildTextField(
                  controller: _subjectController,
                  hintText: 'Matière',
                  icon: Icons.book_outlined,
                ),
                _buildTextField(
                  controller: _gradeController,
                  hintText: 'Note (/20)',
                  icon: Icons.grade_outlined,
                  keyboardType: TextInputType.number,
                ),
                _buildTextField(
                  controller: _evaluationController,
                  hintText: 'Type d\'évaluation',
                  icon: Icons.assignment_outlined,
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('yyyy-MM-dd')
                                .format(_selectedDate!),
                      ),
                      hintText: 'Date d\'évaluation',
                      icon: Icons.calendar_today,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E9EFB),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          setState(() => isLoading = true);
                          await _submitGrade();
                          setState(() => isLoading = false);
                        },
                        child: const Text(
                          'Enregistrer la note',
                          style: TextStyle(fontSize: 16),
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
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return _buildCard(
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(icon, color: Colors.grey),
          border: InputBorder.none,
        ),
        validator: (value) => value == null || value.isEmpty
            ? 'Ce champ est requis'
            : null,
      ),
    );
  }

  Widget _buildStudentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStudentId,
      items: _students.map((student) {
        return DropdownMenuItem<String>(
          value: student['id'],
          child: Text(student['full_name']),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedStudentId = value),
      decoration: const InputDecoration(
        labelText: 'Sélectionnez un étudiant',
        border: InputBorder.none,
      ),
      validator: (value) =>
          value == null ? 'Veuillez sélectionner un étudiant' : null,
    );
  }
}
