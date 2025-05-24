import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentProfileScreen extends StatefulWidget {
  static const routeName = '/student-profile';

  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  _StudentProfileScreenState createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? studentData;
  bool isEditing = false;

  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final gradeController = TextEditingController();
  String? selectedSchoolId;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      showSnackbar('Utilisateur non connecté', isError: true);
      return;
    }

    final response = await supabase
        .from('students')
        .select('*, school(name, id)')
        .eq('id', userId)
        .single();

    if (response == null) {
      showSnackbar('Aucune donnée trouvée pour cet utilisateur', isError: true);
      return;
    }

    setState(() {
      studentData = response;
      phoneController.text = studentData?['phone'] ?? '';
      emailController.text = studentData?['email'] ?? '';
      gradeController.text = studentData?['grade'] ?? '';
      selectedSchoolId = studentData?['school_id'];
    });
  }

  Future<void> updateStudentData() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      showSnackbar('Utilisateur non connecté', isError: true);
      return;
    }

    await supabase.from('students').update({
      'phone': phoneController.text,
      'email': emailController.text,
      'grade': gradeController.text,
      'school_id': selectedSchoolId,
    }).eq('id', userId);

    await fetchStudentData();
    setState(() {
      isEditing = false;
    });

    showSnackbar('Profil mis à jour avec succès');
  }

  void showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (studentData == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F6FF),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF345FB4)),
        ),
      );
    }

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
              // AppBar personnalisée
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/student-home');
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Profil Élève',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.save : Icons.edit,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (isEditing) {
                          updateStudentData();
                        } else {
                          setState(() {
                            isEditing = true;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Contenu du profil
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 161, 175, 252),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: ListView(
                    children: [
                      buildTextField('Téléphone', phoneController),
                      buildTextField('Email', emailController),
                      buildTextField('Niveau', gradeController),
                      const SizedBox(height: 20),
                      const Text(
                        'École',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isEditing)
                        DropdownButtonFormField<String>(
                          value: selectedSchoolId,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: const [
                            DropdownMenuItem(value: '1', child: Text('École A')),
                            DropdownMenuItem(value: '2', child: Text('École B')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedSchoolId = value;
                            });
                          },
                        )
                      else
                        Text(
                          studentData?['school']?['name'] ?? 'Aucune école',
                          style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: isEditing,
          decoration: InputDecoration(
            hintText: 'Entrez...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          style: const TextStyle(fontFamily: 'Poppins'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
