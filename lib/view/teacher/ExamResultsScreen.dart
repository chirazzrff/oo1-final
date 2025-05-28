import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Pour formater les dates
import 'package:supabase_flutter/supabase_flutter.dart';  // Pour interagir avec Supabase

class AddStudentGradeScreen extends StatefulWidget {
  static const String routeName = '/addStudentGrade';
  const AddStudentGradeScreen({Key? key}) : super(key: key);

  @override
  _AddStudentGradeScreenState createState() => _AddStudentGradeScreenState();
}

// Variable globale pour gérer l’état de chargement (affichage du loader)
bool isLoading = false;

class _AddStudentGradeScreenState extends State<AddStudentGradeScreen> {
  // Clé pour le formulaire, permet de valider
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour récupérer le texte saisi
  final _subjectController = TextEditingController();
  final _gradeController = TextEditingController();
  final _evaluationController = TextEditingController();

  DateTime? _selectedDate;  // Date de l’évaluation sélectionnée

  List<Map<String, dynamic>> _students = [];  // Liste des étudiants récupérés de Supabase
  String? _selectedStudentId;  // ID de l’étudiant sélectionné

  // Dégradé de couleurs pour le fond de l’écran
  final LinearGradient myColor = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _loadStudents();  // Charger la liste des étudiants au démarrage
  }

  // Fonction qui récupère les étudiants depuis la table 'students' dans Supabase
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
        SnackBar(content: Text('Erreur lors du chargement des étudiants : $e')),
      );
    }
  }

  // Fonction qui soumet la note dans la table 'grades'
  Future<void> _submitGrade() async {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedStudentId != null) {

      final subject = _subjectController.text.trim();
      final grade = double.tryParse(_gradeController.text.trim());
      final evaluation = _evaluationController.text.trim();
      final date = _selectedDate!.toIso8601String();

      // Vérification que la note est bien comprise entre 0 et 20
      if (grade == null || grade < 0 || grade > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer une note valide entre 0 et 20.')),
        );
        return;
      }

      try {
        // Insertion dans la base Supabase
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

        // Réinitialisation des champs
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
        const SnackBar(content: Text('Veuillez sélectionner une date.')),
      );
    }
  }

  // Fonction qui affiche un sélecteur de date
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

  // Libération des contrôleurs quand l’écran est détruit
  @override
  void dispose() {
    _subjectController.dispose();
    _gradeController.dispose();
    _evaluationController.dispose();
    super.dispose();
  }

  // Construction de l’interface utilisateur
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter une note',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
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
                _buildCard(child: _buildStudentDropdown()),  // Dropdown pour choisir l’étudiant
                const SizedBox(height: 20),

                // Champ pour la matière
                _buildTextField(
                  controller: _subjectController,
                  hintText: 'Matière',
                  obscureText: false,
                  icon: Icons.book_outlined,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),

                const SizedBox(height: 20),

                // Champ pour la note
                _buildTextField(
                  controller: _gradeController,
                  hintText: 'Note (/20)',
                  obscureText: false,
                  icon: Icons.grade_outlined,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                  keyboardType: TextInputType.number,
                ),

                const SizedBox(height: 20),

                // Champ pour le type d’évaluation
                _buildTextField(
                  controller: _evaluationController,
                  hintText: 'Type d\'évaluation',
                  obscureText: false,
                  icon: Icons.assignment_outlined,
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),

                const SizedBox(height: 16),

                // Champ pour la date d’évaluation (avec sélecteur)
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: _buildTextField(
                      controller: TextEditingController(
                        text: _selectedDate == null
                            ? ''
                            : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                      ),
                      hintText: 'Date d\'évaluation',
                      icon: Icons.calendar_today,
                      obscureText: false,
                      validator: (value) => value!.isEmpty ? 'Date requise' : null,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Bouton de soumission
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

  // Widget pour encadrer un widget enfant dans une carte avec ombre et bord arrondi
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

  // Widget pour construire un champ texte personnalisé
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
            prefixIcon: Icon(icon, color: Colors.blue),  // couleur principale remplacée par Colors.blue ici
            border: InputBorder.none,
          ),
          validator: validator,
        ),
      ),
    );
  }

  // Dropdown pour sélectionner un étudiant parmi la liste chargée
  Widget _buildStudentDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedStudentId,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 16,
        color: Colors.black,
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
        labelText: 'Sélectionner un étudiant',
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16,
          color: Color.fromARGB(255, 57, 56, 56),
        ),
        border: InputBorder.none,
      ),
      validator: (value) => value == null ? 'Veuillez sélectionner un étudiant' : null,
    );
  }
}
