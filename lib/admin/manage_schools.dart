import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // Pour formater la date

class ManageSchoolsScreen extends StatefulWidget {
  static const String routeName = '/manageSchools';
  const ManageSchoolsScreen({super.key});

  @override
  _ManageSchoolsScreenState createState() => _ManageSchoolsScreenState();
}

class _ManageSchoolsScreenState extends State<ManageSchoolsScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> allSchools = [];
  List<Map<String, dynamic>> filteredSchools = [];

  @override
  void initState() {
    super.initState();
    fetchSchools();
  }

  Future<void> fetchSchools() async {
    try {
      final response = await supabase
          .from('school')
          .select()
          .order('name', ascending: true); // tri alphabétique

      if (response != null) {
        setState(() {
          allSchools = List<Map<String, dynamic>>.from(response);
          filteredSchools = allSchools;
        });
      }
    } catch (e) {
      print("Erreur fetchSchools : $e");
      // Tu peux ajouter un message d'erreur utilisateur ici si besoin
    }
  }

  void _searchSchools(String query) {
    final results =
        allSchools.where((school) {
          final name = (school['name'] ?? '').toString().toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();

    setState(() {
      filteredSchools = results;
    });
  }

  Future<void> _addSchool() async {
    String schoolName = '';
    String directorName = '';
    String schoolAddress = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '➕ Ajouter une école',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 71, 71, 73),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                  'Nom de l\'école',
                  
                  Icons.school,
                  (value) => schoolName = value,
                ),
                _buildInputField(
                  'Nom du directeur',
                  Icons.person,
                  (value) => directorName = value,
                ),
                _buildInputField(
                  'Adresse',
                  Icons.location_on,
                  (value) => schoolAddress = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
              onPressed: () async {
                if (schoolName.isNotEmpty &&
                    directorName.isNotEmpty &&
                    schoolAddress.isNotEmpty) {
                  try {
                    await supabase.from('school').insert({
                      'name': schoolName,
                      'director': directorName,
                      'address': schoolAddress,
                    });
                    await fetchSchools();
                    _searchController.clear();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Erreur ajout école : $e");
                  }
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editSchool(int index) async {
    // Récupérer les valeurs existantes
    String schoolName = filteredSchools[index]['name']?.toString() ?? '';
    String directorName = filteredSchools[index]['director']?.toString() ?? '';
    String schoolAddress = filteredSchools[index]['address']?.toString() ?? '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '✏️ Modifier l\'école',
            style: TextStyle(fontWeight: FontWeight.bold,fontFamily: 'Poppins',
fontSize: 16,
color: Color.fromARGB(179, 89, 87, 87), ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInputField(
                  'Nom de l\'école',
                  Icons.school,
                  (value) => schoolName = value,
                  initialValue: schoolName,
                ),
                _buildInputField(
                  'Nom du directeur',
                  Icons.person,
                  (value) => directorName = value,
                  initialValue: directorName,
                ),
                _buildInputField(
                  'Adresse',
                  Icons.location_on,
                  (value) => schoolAddress = value,
                  initialValue: schoolAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.grey),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E9EFB)),
              onPressed: () async {
                if (schoolName.isNotEmpty &&
                    directorName.isNotEmpty &&
                    schoolAddress.isNotEmpty) {
                  try {
                    await supabase
                        .from('school')
                        .update({
                          'name': schoolName,
                          'director': directorName,
                          'address': schoolAddress,
                        })
                        .eq('id', filteredSchools[index]['id']);
                    await fetchSchools();
                    _searchController.clear();
                    Navigator.pop(context);
                  } catch (e) {
                    print("Erreur modification école : $e");
                  }
                }
              },
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSchool(int index) async {
    try {
      await supabase
          .from('school')
          .delete()
          .eq('id', filteredSchools[index]['id']);
      await fetchSchools();
    } catch (e) {
      print("Erreur suppression école : $e");
    }
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('⚠️ Suppression'),
            content: const Text('Confirmer la suppression de cette école ?'),
            actions: [
              TextButton(
                child: const Text('Annuler'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () {
                  _deleteSchool(index);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }Widget _buildInputField(
  String label,
  IconData icon,
  Function(String) onChanged, {
  String? initialValue,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      style: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold, // texte saisi en gras
        fontFamily: 'Poppins',
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 83, 83, 87)),
        labelText: label,
        labelStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          color: Color.fromARGB(255, 83, 83, 87),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color.fromARGB(255, 83, 83, 87)),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}


  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🏫 Gestion des écoles"),
        backgroundColor: Color(0xFF8E9EFB),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addSchool,
            tooltip: "Ajouter une école",
          ),
        ],
      ),
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
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: _searchSchools,
                  style: const TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontFamily: 'Poppins',
    fontSize: 15,
  ),
                  decoration: InputDecoration(
                    hintText: '🔍 Rechercher une école',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Liste des écoles
              Expanded(
                child:
                    filteredSchools.isEmpty
                        ? const Center(
                          child: Text(
                            'Aucune école trouvée',
                            style: TextStyle(color: Color.fromARGB(255, 78, 75, 75), fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredSchools.length,
                          itemBuilder: (context, index) {
                            final school = filteredSchools[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              elevation: 4,
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.indigo,
                                  child: const Icon(
                                    Icons.school,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  school['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.indigo,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "🎓 Directeur: ${school['director'] ?? ''}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "📍 ${school['address'] ?? ''}",
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (school['created_at'] != null)
                                      Text(
                                        "🗓️ Ajouté le: ${_formatDate(school['created_at'])}",
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                                isThreeLine: true,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.orange,
                                      ),
                                      onPressed: () => _editSchool(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _showDeleteConfirmation(index),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
