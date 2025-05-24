import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageUsersScreen extends StatefulWidget {
  static const String routeName = '/manageusers';

  @override
  _ManageUsersScreenState createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> users = [];
  bool isLoading = false;

  String selectedRole = 'Parents';
  final List<String> roles = ['Parents', 'Students', 'Teachers'];

  @override
  void initState() {
    super.initState();
    fetchUsersByRole(selectedRole);
  }

  Future<void> fetchUsersByRole(String role) async {
    setState(() {
      isLoading = true;
      users = [];
    });

    final table = role.toLowerCase();
    final response = await supabase.from(table).select();
    setState(() {
      users = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
  }

  Future<void> deleteUser(String table, String id) async {
    await supabase.from(table).delete().eq('id', id);
    fetchUsersByRole(selectedRole);
  }

  Future<String?> fetchParentName(String parentId) async {
    final response = await supabase
        .from('parents')
        .select('full_name')
        .eq('id', parentId)
        .maybeSingle();
    return response?['full_name'];
  }

  Future<String?> fetchChildName(String childId) async {
    final response = await supabase
        .from('students')
        .select('full_name')
        .eq('id', childId)
        .maybeSingle();
    return response?['full_name'];
  }

  void showEditDialog(Map<String, dynamic> user) {
    String fullName = user['full_name'] ?? '';
    String email = user['email'] ?? '';
    String phone = user['phone'] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Wrap(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Modifier l'utilisateur",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: fullName,
                    style: const TextStyle(color: Color.fromARGB(255, 62, 61, 61)),
                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person, color: Colors.grey),
                    ),
                    onChanged: (value) => fullName = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: email,
                    style: const TextStyle(color: Color.fromARGB(255, 62, 61, 61)),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email, color: Colors.grey),
                    ),
                    onChanged: (value) => email = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: phone,
                    style: const TextStyle(color: Color.fromARGB(255, 62, 61, 61)),
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      labelStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone, color: Colors.grey),
                    ),
                    onChanged: (value) => phone = value,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.cancel, color: Colors.grey),
                        label: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8E9EFB),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () async {
                          final table = selectedRole.toLowerCase();
                          await supabase.from(table).update({
                            'full_name': fullName,
                            'email': email,
                            'phone': phone,
                          }).eq('id', user['id']);
                          Navigator.pop(context);
                          fetchUsersByRole(selectedRole);
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Enregistrer"),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [Color(0xFF8E9EFB), Color(0xFF8E9EFB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Gérer les utilisateurs", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: gradient),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: const Color(0xFF8E9EFB),
                ),
                child: DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF8E9EFB),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF8E9EFB),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => selectedRole = value);
                      fetchUsersByRole(value);
                    }
                  },
                  items: roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role, style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.white))
                  : users.isEmpty
                      ? const Center(
                          child: Text(
                            "Aucun utilisateur trouvé.",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users[index];
                            return FutureBuilder<String?>(
                              future: selectedRole == 'Students' && user['parent_id'] != null
                                  ? fetchParentName(user['parent_id'])
                                  : selectedRole == 'Parents' && user['child_id'] != null
                                      ? fetchChildName(user['child_id'])
                                      : Future.value(null),
                              builder: (context, snapshot) {
                                final relation = snapshot.data;
                                return Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.person, color: Color(0xFF345FB4), size: 30),
                                    title: Text(
                                      user['full_name'] ?? 'Nom inconnu',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF345FB4),
                                      ),
                                    ),
                                    subtitle: relation != null
                                        ? Text(
                                            selectedRole == 'Students'
                                                ? "Parent : $relation"
                                                : "Enfant : $relation",
                                          )
                                        : null,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.orange),
                                          onPressed: () => showEditDialog(user),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () => deleteUser(selectedRole.toLowerCase(), user['id']),
                                        ),
                                      ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          switch (selectedRole) {
            case 'Parents':
              Navigator.pushNamed(context, '/addParent');
              break;
            case 'Students':
              Navigator.pushNamed(context, '/addStudent');
              break;
            case 'Teachers':
              Navigator.pushNamed(context, '/addTeacher');
              break;
          }
        },
        backgroundColor: const Color(0xFF8E9EFB),
        child: const Icon(Icons.add),
        tooltip: "Ajouter un $selectedRole",
      ),
    );
  }
}
