import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

var myColor = LinearGradient(
  colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class SignUpScreen extends StatefulWidget {
  static String routeName = 'SignUpScreen';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  DateTime? _selectedDate;
  String? _gender;
  String? _userType;

  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1960),
      lastDate: DateTime(2024),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;
      if (user == null) return _showError("Échec d'inscription.");

      final userId = user.id;
      final fullName = _fullNameController.text.trim();
      final dob = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;

      final profileData = {
        'id': userId,
        'full_name': fullName,
        'gender': _gender,
        'date_of_birth': dob,
      };

      await supabase.from('${_userType!.toLowerCase()}s').insert(profileData);
      await supabase.from('profiles').insert({
        'id': userId,
        'full_name': fullName,
        'gender': _gender,
        'date_of_birth': dob,
        'user_type': _userType,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inscription réussie !')),
      );

      switch (_userType) {
        case 'Student':
          Navigator.pushReplacementNamed(context, '/studentHome');
          break;
        case 'Teacher':
          Navigator.pushReplacementNamed(context, '/teacherHome');
          break;
        case 'Parent':
          Navigator.pushReplacementNamed(context, '/parentProfile');
          break;
        case 'Admin':
          Navigator.pushReplacementNamed(context, '/adminDashboard');
          break;
        default:
          _showError('Type d\'utilisateur inconnu.');
      }
    } catch (e) {
      _showError('Erreur : ${e.toString()}');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  final TextStyle commonInputTextStyle = const TextStyle(
    color: Colors.white70,
    fontFamily: 'Poppins',
    fontSize: 12,
  );

  final TextStyle dropdownTextStyle = const TextStyle(
    color: Colors.white70,
    fontFamily: 'Poppins',
    fontSize: 12,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: myColor),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 100),
                  const SizedBox(height: 20),
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 30),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Adresse e-mail',
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _fullNameController,
                    hintText: 'Nom complet',
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Mot de passe',
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: TextEditingController(
                          text: _selectedDate == null
                              ? ''
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                        ),
                        hintText: 'Date de naissance',
                        icon: Icons.calendar_today,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _gender,
                    label: 'Genre',
                    items: ['Male', 'Female'],
                    
                    onChanged: (val) => setState(() => _gender = val),

                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    value: _userType,
                    label: 'Type d\'utilisateur',
                    items: ['Student', 'Teacher', 'Parent', 'Admin'],
                    onChanged: (val) => setState(() => _userType = val),
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : InkWell(
                          onTap: _signUp,
                          child: Container(
                            width: double.maxFinite,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Center(
                              child: const Text(
                                'sigup',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Retour à la connexion',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: commonInputTextStyle,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: commonInputTextStyle,
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue.shade800),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Champ requis' : null,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
      style: dropdownTextStyle,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: dropdownTextStyle,
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: dropdownTextStyle),
              ))
          .toList(),
      validator: (val) => val == null ? 'Champ requis' : null,
    );
  }
}
