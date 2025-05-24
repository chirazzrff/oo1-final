// payment_status_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({Key? key}) : super(key: key);

  @override
  _PaymentStatusScreenState createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> children = [];
  Map<int, bool> paymentStatus = {};
  Map<int, List<Map<String, dynamic>>> paymentHistory = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchChildrenAndPayments();
  }

  Future<void> fetchChildrenAndPayments() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final childrenData = await supabase
        .from('children')
        .select('id, name')
        .eq('parent_id', userId);

    if (childrenData == null || childrenData.isEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    for (var child in childrenData) {
      final childId = child['id'];

      final latest = await supabase
          .from('payments')
          .select('is_paid')
          .eq('child_id', childId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      final history = await supabase
          .from('payments')
          .select()
          .eq('child_id', childId)
          .order('created_at', ascending: false);

      setState(() {
        children = List<Map<String, dynamic>>.from(childrenData);
        paymentStatus[childId] = latest?['is_paid'] ?? false;
        paymentHistory[childId] = List<Map<String, dynamic>>.from(history);
        isLoading = false;
      });
    }
  }

  void showHistoryDialog(String childName, List<Map<String, dynamic>> history) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Historique des paiements - $childName'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: history.length,
            itemBuilder: (context, index) {
              final entry = history[index];
              final isPaid = entry['is_paid'] == true;
              final date = entry['created_at'];
              final montant = entry['amount'] ?? '---';
              return ListTile(
                title: Text("Montant : $montant DA"),
                subtitle: Text("Date : ${date.toString().split('T')[0]}"),
                trailing: Text(isPaid ? "✅" : "❌"),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statut du paiement"),
        backgroundColor: const Color(0xFF345FB4),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : children.isEmpty
          ? const Center(child: Text("Aucun enfant trouvé pour ce parent."))
          : ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final name = child['name'] ?? 'Enfant';
          final id = child['id'];
          final isPaid = paymentStatus[id] == true;
          final history = paymentHistory[id] ?? [];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const Icon(Icons.child_care,
                  color: Color(0xFF345FB4)),
              title: Text(name),
              subtitle: Text(isPaid
                  ? '✅ Paiement effectué'
                  : '❌ Paiement non effectué'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'historique') {
                    showHistoryDialog(name, history);
                  }
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'historique',
                    child: Row(
                      children: [
                        Icon(Icons.history, color: Colors.black54),
                        SizedBox(width: 8),
                        Text("Voir l'historique"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
