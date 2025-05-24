import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Pour Poppins

class ChildRegistrationPage extends StatefulWidget {
  @override
  State<ChildRegistrationPage> createState() => _ChildRegistrationPageState();
}

class _ChildRegistrationPageState extends State<ChildRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final dobController = TextEditingController();
  final parentNameController = TextEditingController();
  final phoneController = TextEditingController();
  final amountController = TextEditingController();
  final cardholderController = TextEditingController();
  final cardNumberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  String? _selectedClass;
  String? _selectedCourse;
  String? _paymentMethod;

  final List<String> classes = ['1st Year', '2nd Year', '3rd Year', '4th Year', '5th Year'];
  final List<String> courses = ['Math', 'Arabic', 'Science', 'French', 'History', 'Islamic Ed'];
  final List<String> paymentMethods = ['Cash', 'Credit Card', 'Bank Transfer'];

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

  @override
  Widget build(BuildContext context) {
    final Gradient backgroundGradient = LinearGradient(
      colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Child Registration",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 24),

                _buildSectionTitle('👶 Child Info'),
                _buildField(Icons.person, 'Full Name', controller: fullNameController),
                _buildField(Icons.calendar_today, 'Date of Birth', controller: dobController),
                _buildDropdown(Icons.school, 'Select Class', classes, onChanged: (val) => setState(() => _selectedClass = val)),
                _buildDropdown(Icons.book, 'Select Course', courses, onChanged: (val) => setState(() => _selectedCourse = val)),

                _buildSectionTitle('👨‍👩‍👧 Parent Info'),
                _buildField(Icons.person_outline, 'Parent Name', controller: parentNameController),
                _buildField(Icons.phone, 'Phone Number', controller: phoneController, keyboardType: TextInputType.phone),

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

                SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.check_circle_outline, size: 24),
                    label: Text(
                      'Submit Registration',
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 215, 225, 245), // bleu foncé
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 5,
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: registerChildAndPayment();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('✅ Registration submitted!')),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
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
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
        ),
        keyboardType: keyboardType,
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }

  Widget _buildDropdown(IconData icon, String label, List<String> items, {Function(String?)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.white70),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white54),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.15),
        ),
        dropdownColor: Color(0xFF345FB4),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: GoogleFonts.poppins(color: Colors.white)),
                ))
            .toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? 'Please select $label' : null,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.only(top: 28, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(1, 1))],
        ),
      ),
    );
  }
}
