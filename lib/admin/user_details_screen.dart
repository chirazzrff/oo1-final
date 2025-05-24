import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String role;

  const UserDetailsScreen({super.key, required this.user, required this.role});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  late TextEditingController nameController;
  late TextEditingController emailController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user['full_name'] ?? '');
    emailController = TextEditingController(text: widget.user['email'] ?? '');
  }

  Future<void> updateUser() async {
    setState(() => isLoading = true);

    await supabase
        .from(widget.role.toLowerCase())
        .update({
          'full_name': nameController.text,
          'email': emailController.text,
        })
        .eq('id', widget.user['id']);

    setState(() => isLoading = false);
    Navigator.pop(context, 'updated');
  }

  Future<void> deleteUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cet utilisateur ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      await supabase
          .from(widget.role.toLowerCase())
          .delete()
          .eq('id', widget.user['id']);

      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final Gradient backgroundGradient = const LinearGradient(
      colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détails de l'utilisateur", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            const Text("Nom complet", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 5),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Email", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 5),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading ? null : updateUser,
                  icon: const Icon(Icons.save),
                  label: const Text("Modifier"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : deleteUser,
                  icon: const Icon(Icons.delete),
                  label: const Text("Supprimer"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
