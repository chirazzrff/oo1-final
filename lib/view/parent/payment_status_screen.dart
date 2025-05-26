import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ParentPaymentsScreen extends StatefulWidget {
  static const String routeName = '/parentPayments';
  const ParentPaymentsScreen({super.key});

  @override
  State<ParentPaymentsScreen> createState() => _ParentPaymentsScreenState();
}

class _ParentPaymentsScreenState extends State<ParentPaymentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> payments = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final students = await supabase
        .from('students')
        .select('id, full_name')
        .eq('parent_id', userId);

    final studentIds = students.map((e) => e['id']).toList();

    if (studentIds.isEmpty) return;

    final response = await supabase
        .from('pyment')
        .select('id, amount, status, pyment_date, student_id')
        .inFilter('student_id', studentIds)
        .order('pyment_date', ascending: false);

    final studentMap = {
      for (var s in students) s['id']: s['full_name']
    };

    setState(() {
      payments = List<Map<String, dynamic>>.from(response).map((p) {
        p['student_name'] = studentMap[p['student_id']] ?? 'Unknown';
        return p;
      }).toList();
    });
  }

  List<Map<String, dynamic>> _getPaymentsForDay(DateTime day) {
    return payments.where((payment) {
      final date = DateTime.tryParse(payment['pyment_date'] ?? '')?.toLocal();
      return date != null &&
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day;
    }).toList();
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupPaymentsByDay() {
    final Map<DateTime, List<Map<String, dynamic>>> data = {};
    for (var payment in payments) {
      final rawDate = payment['pyment_date'];
      if (rawDate == null) continue;

      final date = DateTime.tryParse(rawDate)?.toLocal();
      if (date != null) {
        final dayKey = DateTime(date.year, date.month, date.day);
        data.putIfAbsent(dayKey, () => []).add(payment);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final events = _groupPaymentsByDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text("💳 Paiements de mon enfant"),
        backgroundColor: const Color(0xFFF5F7FA),
      ),
      backgroundColor: const Color(0xFF8E9EFB),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return events[normalizedDay] ?? [];
              },
              calendarStyle: const CalendarStyle(
                markerDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isEmpty) return const SizedBox();
                  final hasPaid = events.any((e) => ['status'] == 'Paid');
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: hasPaid ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _getPaymentsForDay(_selectedDay).map((payment) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("👤 Élève : ${payment['student_name'] ?? 'Inconnu'}"),
                      subtitle: Text("💰 Montant : ${payment['amount']} DA\n📌 Statut : ${payment['status']}"),
                      trailing: Icon(
                        payment['status'] == 'Paid' ? Icons.check_circle : Icons.cancel,
                        color: payment['status'] == 'Paid' ? Colors.green : Colors.red,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
