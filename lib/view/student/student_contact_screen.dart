import 'package:flutter/material.dart';

class StudentContactScreen extends StatefulWidget {
  static const String routeName = '/studentContact';

  final String? contactType; // optionnel, pour pré-selection

  const StudentContactScreen({Key? key, this.contactType}) : super(key: key);

  @override
  _StudentContactScreenState createState() => _StudentContactScreenState();
}

class _StudentContactScreenState extends State<StudentContactScreen> {
  final _formKey = GlobalKey<FormState>();
  String _recipient = 'admin';
  String _subject = '';
  String _message = '';

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    if (widget.contactType != null) {
      _recipient = widget.contactType!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              height: 140,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              alignment: Alignment.bottomLeft,
              child: Text(
                'Contacter ${_recipient == 'teacher' ? 'un enseignant' : 'l\'administration'}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: _recipient,
                            decoration: InputDecoration(
                              labelText: 'Destinataire',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'admin', child: Text('Administration')),
                              DropdownMenuItem(value: 'teacher', child: Text('Enseignant')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _recipient = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Sujet',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un sujet';
                              }
                              return null;
                            },
                            onSaved: (value) => _subject = value!,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Message',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            maxLines: 6,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Veuillez entrer un message';
                              }
                              return null;
                            },
                            onSaved: (value) => _message = value!,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.send),
                            label: const Text('Envoyer'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: const Color.fromARGB(255, 215, 223, 239),
                              textStyle: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      print('Destinataire : $_recipient');
      print('Sujet : $_subject');
      print('Message : $_message');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Message envoyé à $_recipient avec succès !')),
      );

      // Optionnel : fermer l'écran après envoi
      // Navigator.pop(context);
    }
  }
}
