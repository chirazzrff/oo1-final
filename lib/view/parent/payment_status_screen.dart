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
      backgroundColor: const Color(0xFFB8C6DB),
      appBar: AppBar(
        title: const Text("Child Payment Calendar"),
        backgroundColor: const Color(0xFF8E9EFB),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2023, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              rowHeight: 50,
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                weekendStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF007BFF),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.orange.shade400,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
              ),
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return events[normalizedDay] ?? [];
              },
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
              child: payments.isEmpty
                  ? const Center(child: Text("No payments found.", style: TextStyle(color: Colors.black87)))
                  : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _getPaymentsForDay(_selectedDay).map((payment) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text("👦 Student: ${payment['student_name']}"),
                      subtitle: Text(
                        "💰 Amount: ${payment['amount']} DA\n📌 Status: ${payment['status']}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      trailing: Icon(
                        payment['status'] == 'Paid' ? Icons.check_circle : Icons.cancel,
                        color: payment['status'] == 'Paid' ? Colors.green : Colors.red,
                        size: 28,
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
