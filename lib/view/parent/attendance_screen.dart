import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EcranPresenceParent extends StatefulWidget {
  const EcranPresenceParent({Key? key}) : super(key: key);

  @override
  _EcranPresenceParentState createState() => _EcranPresenceParentState();
}

class _EcranPresenceParentState extends State<EcranPresenceParent> {
  List<Map<String, dynamic>> presences = [];
  bool enChargement = true;

  Future<void> recupererPresencesPourParent() async {
    final supabase = Supabase.instance.client;
    final identifiantUtilisateur = supabase.auth.currentUser?.id;

    if (identifiantUtilisateur == null) return;

    try {
      final reponseEleves = await supabase
          .from('students')
          .select('id, full_name')
          .eq('parent_id', identifiantUtilisateur);

      final List<dynamic> eleves = reponseEleves;

      if (eleves.isEmpty) {
        setState(() {
          presences = [];
          enChargement = false;
        });
        return;
      }

      final nomsEleves = eleves.map((e) => e['full_name']).toList();

      final reponsePresences = await supabase
          .from('attendance')
          .select('student_name, date, course, present, comment')
          .inFilter('student_name', nomsEleves);

      setState(() {
        presences = List<Map<String, dynamic>>.from(reponsePresences);
        enChargement = false;
      });
    } catch (e) {
      print('Erreur lors de la récupération des présences : $e');
      setState(() {
        enChargement = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    recupererPresencesPourParent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  "Présence de mon enfant",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
              ),
              Expanded(
                child: enChargement
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : presences.isEmpty
                    ? const Center(
                  child: Text(
                    'Aucun enregistrement de présence trouvé.',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: presences.length,
                  itemBuilder: (context, index) {
                    final presence = presences[index];
                    final estPresent = presence['present'] == true;
                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor:
                            estPresent ? Colors.green[100] : Colors.red[100],
                            child: Icon(
                              estPresent ? Icons.check : Icons.close,
                              color: estPresent ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${presence['student_name']} - ${presence['course']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Date : ${presence['date']}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black),
                                ),
                                if (presence['comment'] != null &&
                                    presence['comment'].toString().isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      'Commentaire : ${presence['comment']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        ],
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
