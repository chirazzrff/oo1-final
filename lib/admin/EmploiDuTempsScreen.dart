import 'package:flutter/material.dart';
import 'package:oo/admin/view_data.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_colors.dart';

class AjouterEmploiDuTempsScreen extends StatefulWidget {
  static const routeName = '/ajouter-emploi-du-temps';

  @override
  _AjouterEmploiDuTempsScreenState createState() =>
      _AjouterEmploiDuTempsScreenState();
}

class _AjouterEmploiDuTempsScreenState extends State<AjouterEmploiDuTempsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _matiereController = TextEditingController();
  final TextEditingController _horaireController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();

  Future<void> _ajouterCours() async {
    if (_formKey.currentState!.validate()) {
      await Supabase.instance.client.from('emploi_du_temps').insert({
        'date': _dateController.text,
        'matiere': _matiereController.text,
        'horaire': _horaireController.text,
        'classe': _classeController.text,
      });
      _dateController.clear();
      _matiereController.clear();
      _horaireController.clear();
      _classeController.clear();
      setState(() {});
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCours() async {
    final response = await Supabase.instance.client
        .from('emploi_du_temps')
        .select()
        .order('date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> _supprimerCours(int id) async {
    await Supabase.instance.client.from('emploi_du_temps').delete().eq('id', id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundGradientStart,
              AppColors.backgroundGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text("🕒 Ajouter Emploi du Temps"),
              backgroundColor: AppColors.backgroundGradientStart,
              elevation: 0,
              centerTitle: true,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildTextField(_dateController, 'Date (ex: 2025-05-20)'),
                          _buildTextField(_matiereController, 'Matière'),
                          _buildTextField(_horaireController, 'Horaire (ex: 08:00 - 09:30)'),
                          _buildTextField(_classeController, 'Classe'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _ajouterCours,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                            child: const Text(
                              "Ajouter Cours",
                              style: TextStyle(fontFamily: 'Poppins'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchCours(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final cours = snapshot.data!;
                          if (cours.isEmpty) {
                            return const Center(
                              child: Text(
                                "Aucun cours trouvé.",
                                style: TextStyle(fontSize: 16, color: Colors.white),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: cours.length,
                            itemBuilder: (context, index) {
                              final item = cours[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  title: Text(
                                    "${item['date']} - ${item['matiere']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      "Horaire: ${item['horaire']}\nClasse: ${item['classe']}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _supprimerCours(item['id']),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        style: const TextStyle(color: Colors.black, fontFamily: 'Poppins'),
        validator: (value) =>
        value == null || value.isEmpty ? 'Ce champ est requis' : null,
      ),
    );
  }
}
