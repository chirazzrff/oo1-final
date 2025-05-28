import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChildRegistrationPage extends StatefulWidget {
  @override
  State<ChildRegistrationPage> createState() => _ChildRegistrationPageState();
}

class _ChildRegistrationPageState extends State<ChildRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final amountController = TextEditingController();
  final cardholderController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  String? _selectedLevel;
  String? _selectedClass;
  String? _selectedCourse;
  String? _paymentMethod;

  List<String> courses = [];
  bool isLoadingCourses = true;

  final List<String> paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer'];

  final Map<String, List<String>> levelToClasses = {
    'Primary': ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'],
    'Middle': ['1st Year', '2nd Year', '3rd Year', '4th Year'],
    'High School': ['1st Year', '2nd Year', '3rd Year'],
  };

  bool get isCardPayment => _paymentMethod == 'Credit Card';

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  Future<void> fetchCourses() async {
    try {
      final response = await supabase.from('cours').select('name');
      setState(() {
        courses = List<String>.from(response.map((e) => e['name'].toString()));
        isLoadingCourses = false;
      });
    } catch (e) {
      setState(() => isLoadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to load courses: $e')),
      );
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    amountController.dispose();
    cardholderController.dispose();
    cardNumberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  Future<void> registerChildAndPayment() async {
    final parentId = supabase.auth.currentUser?.id;

    if (parentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Parent not logged in.")),
      );
      return;
    }

    try {
      final childInsert = await supabase.from('students').insert({
        'full_name': fullNameController.text,
        'date_of_birth': dobController.text,
        'grade': _selectedClass,
        'course_name': _selectedCourse,
        'parent_id': parentId,
      }).select().single();

      final childId = childInsert['id'];

      await supabase.from('pyment').insert({
        'pyment_date': DateTime.now().toIso8601String(),
        'student_id': childId,
        'amount': double.parse(amountController.text),
        'method': _paymentMethod,
        'status': 'Pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Registration successful')),
      );
      _formKey.currentState?.reset();
      setState(() {
        _selectedLevel = null;
        _selectedClass = null;
        _selectedCourse = null;
        _paymentMethod = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Registration failed: $e')),
      );
    }
  }

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Child Registration',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('👶 Child Info'),
                  _buildField(Icons.person, 'Full Name', controller: fullNameController),
                  _buildDateField(Icons.calendar_today, 'Date of Birth', dobController),
                  _buildDropdown(Icons.school, 'Select Level', levelToClasses.keys.toList(), onChanged: (val) {
                    setState(() {
                      _selectedLevel = val;
                      _selectedClass = null;
                    });
                  }),
                  if (_selectedLevel != null)
                    _buildDropdown(Icons.class_, 'Select Class', levelToClasses[_selectedLevel]!, onChanged: (val) {
                      setState(() => _selectedClass = val);
                    }),
                  isLoadingCourses
                      ? const Center(child: CircularProgressIndicator(color: Colors.white))
                      : _buildDropdown(Icons.book, 'Select Course', courses,
                      currentValue: _selectedCourse,
                      onChanged: (val) => setState(() => _selectedCourse = val)),
                  const SizedBox(height: 24),
                  _buildSectionTitle('💳 Payment Info'),
                  _buildDropdown(Icons.payment, 'Payment Method', paymentMethods, onChanged: (val) {
                    setState(() => _paymentMethod = val);
                  }),
                  _buildField(Icons.money, 'Amount (DA)', controller: amountController, keyboardType: TextInputType.number),
                  if (isCardPayment) ...[
                    _buildField(Icons.credit_card, 'Cardholder Name', controller: cardholderController),
                    _buildField(Icons.credit_card, 'Card Number', controller: cardNumberController, keyboardType: TextInputType.number),
                    _buildField(Icons.date_range, 'Expiry Date (MM/YY)', controller: expiryController),
                    _buildField(Icons.lock, 'CVV', controller: cvvController, keyboardType: TextInputType.number),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Submit Registration'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF345FB4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 50),
                      textStyle: const TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerChildAndPayment();
                      }
                    },
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String label,
      {TextInputType keyboardType = TextInputType.text, TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF345FB4)),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF345FB4), width: 2),
          ),
        ),
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDateField(IconData icon, String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF345FB4)),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF345FB4), width: 2),
          ),
          suffixIcon: const Icon(Icons.calendar_today, color: Color(0xFF345FB4)),
        ),
        onTap: () async {
          DateTime? picked = await showDatePicker(
            context: context,
            initialDate: DateTime(2015, 1, 1),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          }
        },
        validator: (value) => value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildDropdown(IconData icon, String label, List<String> options,
      {required ValueChanged<String?> onChanged, String? currentValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF345FB4)),
        ),
        child: DropdownButtonFormField<String>(
          value: currentValue,
          iconEnabledColor: const Color(0xFF345FB4),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
            border: InputBorder.none,
          ),
          items: options
              .map((option) => DropdownMenuItem(
            value: option,
            child: Text(option, style: const TextStyle(fontFamily: 'Poppins')),
          ))
              .toList(),
          onChanged: onChanged,
          validator: (value) => value == null ? 'Please select $label' : null,
          dropdownColor: Colors.white,
          style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 5, color: Colors.black26, offset: Offset(1, 1))],
        ),
      ),
    );
  }
}
