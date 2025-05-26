import 'package:flutter/material.dart';
import 'package:oo/view/screens/datesheet_screen/data/datesheet_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChildRegistrationPage extends StatefulWidget {
  @override
  State<ChildRegistrationPage> createState() => _ChildRegistrationPageState();
}

class _ChildRegistrationPageState extends State<ChildRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  // Text controllers
  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final parentNameController = TextEditingController();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final cardholderController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  String? _selectedLevel;
  String? _selectedClass;
  String? _selectedCourse;
  String? _paymentMethod;

  final List<String> courses = ['Math', 'Arabic', 'Science', 'French', 'History', 'Islamic Ed'];
  final List<String> paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer'];

  final Map<String, List<String>> levelToClasses = {
    'Primary': ['1st Year', '2nd Year', '3rd Year'],
    'Middle': ['4th Year', '5th Year'],
    'High School': ['6th Year', '7th Year'],
  };

  bool get isCardPayment => _paymentMethod == 'Credit Card';

  @override
  void dispose() {
    fullNameController.dispose();
    dobController.dispose();
    parentNameController.dispose();
    phoneController.dispose();
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
        SnackBar(content: Text("❌ Parent non connecté.")),
      );
      return;
    }

    try {
      final childInsert = await supabase.from('children').insert({
        'name': fullNameController.text,
        'date_of_birth': dobController.text,
        'class': _selectedClass,
        'course': _selectedCourse,
        'parent_id': parentId,
      }).select().single();

      final childId = childInsert['id'];

      final paymentInsert = await supabase.from('pyment').insert({
        'pyment_date': dateSheet,
        'child_id': childId,
        'amount': double.parse(amountController.text),
        'method': _paymentMethod,
        'status': 'Pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      if (paymentInsert.error != null) {
        print('Erreur insertion paiement: ${paymentInsert.error!.message}');
        throw Exception(paymentInsert.error!.message);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Enregistrement réussi')),
      );
      _formKey.currentState?.reset();
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Échec de l’enregistrement: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Child Registration'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
                  setState(() {
                    _selectedClass = val;
                  });
                }),
              _buildDropdown(Icons.book, 'Select Course', courses, onChanged: (val) => _selectedCourse = val),

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

              SizedBox(height: 24),
              ElevatedButton.icon(
                icon: Icon(Icons.check_circle_outline),
                label: Text('Submit Registration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  minimumSize: Size(double.infinity, 50),
                  textStyle: TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    registerChildAndPayment();
                  }
                },
              )
            ],
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
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onTap: () async {
          final pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2015),
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            controller.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
          }
        },
        validator: (value) => value == null || value.isEmpty ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildDropdown(IconData icon, String label, List<String> items, {Function(String?)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          labelText: label,
          labelStyle: TextStyle(color: Colors.black),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.only(top: 24, bottom: 12),
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
