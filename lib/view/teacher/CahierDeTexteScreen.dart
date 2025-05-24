import 'package:flutter/material.dart';

class CahierDeTexteScreen extends StatefulWidget {
  @override
  _CahierDeTexteScreenState createState() => _CahierDeTexteScreenState();
}

class _CahierDeTexteScreenState extends State<CahierDeTexteScreen> {
  List<Map<String, String>> entries = [
    {
      'title': 'Chapitre 1 : Addition',
      'content': 'Contenu : Addition des nombres entiers',
    },
    {
      'title': 'Chapitre 2 : Multiplication',
      'content': 'Contenu : Multiplication des nombres entiers',
    },
  ];

  final Gradient backgroundGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  void _addEntry() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une entrée',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Titre'),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(hintText: 'Contenu'),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  entries.add({
                    'title': titleController.text,
                    'content': contentController.text,
                  });
                });
                Navigator.pop(context);
              },
              child: const Text('Ajouter',
                  style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF345FB4))),
            ),
          ],
        );
      },
    );
  }

  void _editEntry(int index) {
    final titleController = TextEditingController(text: entries[index]['title']);
    final contentController = TextEditingController(text: entries[index]['content']);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier l\'entrée',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Titre'),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(hintText: 'Contenu'),
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler', style: TextStyle(fontFamily: 'Poppins')),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  entries[index] = {
                    'title': titleController.text,
                    'content': contentController.text,
                  };
                });
                Navigator.pop(context);
              },
              child: const Text('Modifier',
                  style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF345FB4))),
            ),
          ],
        );
      },
    );
  }

  void _deleteEntry(int index) {
    setState(() {
      entries.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Row(
                  children: [
                    const Text(
                      'Cahier de texte',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addEntry,
                    ),
                  ],
                ),
              ),
              // ENTRIES
              Expanded(
                child: ListView.builder(
                  itemCount: entries.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.book, color: Color(0xFF345FB4)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry['title'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF345FB4),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  entry['content'] ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'Modifier') _editEntry(index);
                              if (value == 'Supprimer') _deleteEntry(index);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'Modifier',
                                child: Text('Modifier',
                                    style: TextStyle(fontFamily: 'Poppins')),
                              ),
                              const PopupMenuItem(
                                value: 'Supprimer',
                                child: Text('Supprimer',
                                    style: TextStyle(fontFamily: 'Poppins')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
