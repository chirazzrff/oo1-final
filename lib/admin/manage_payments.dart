import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManagePaymentsScreen extends StatefulWidget {
  static const String routeName = '/managePayments';
  const ManagePaymentsScreen({super.key});

  @override
  State<ManagePaymentsScreen> createState() => _ManagePaymentsScreenState();
}

class _ManagePaymentsScreenState extends State<ManagePaymentsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> payments = [];
  List<Map<String, dynamic>> students = [];
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchPayments();
    _fetchStudents();
  }

  Future<void> _fetchPayments() async {
    final response = await supabase
        .from('pyment')
        .select('id, amount, status, pyment_date, students(full_name)')
        .order('pyment_date', ascending: false);
    setState(() {
      payments = List<Map<String, dynamic>>.from(response);
    });
  }

  Future<void> _fetchStudents() async {
    final response = await supabase.from('students').select('id, full_name');
    setState(() {
      students = List<Map<String, dynamic>>.from(response);
    });
  }

  List<Map<String, dynamic>> _getPaymentsForDay(DateTime day) {
    return payments.where((payment) {
      final date = DateTime.tryParse(payment['pyment_date'] ?? '')?.toLocal();
      return date != null &&
          date.year == day.year &&
          date.month == day.month &&
          date.day == day.day ;
    }).toList();
  }

  Future<void> _deletePayment(String id) async {
    await supabase.from('pyment').delete().eq('id', id);
    _fetchPayments();
  }

  void _showAddPaymentDialog() {
    String? selectedStudentId;
    final amountController = TextEditingController();
    String status = 'No Paid';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          title: const Text("➕ Ajouter un paiement",
              style: TextStyle(fontFamily: 'Poppins',color: Color.fromARGB(255, 146, 142, 142), fontSize: 18)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Élève",
                    
                    border: OutlineInputBorder(),
                  ),
                  items: students.map((student) {
                    return DropdownMenuItem(
                      value: student['id'].toString(),
                      child: Text(student['full_name'],
                          style: const TextStyle(color: Color.fromARGB(255, 106, 103, 103),fontFamily: 'Poppins')),
                    );
                  }).toList(),
                  onChanged: (val) => selectedStudentId = val,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Montant (DA)",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: "Statut",
                    border: OutlineInputBorder(),
                  ),
                  items: ['Paid', 'No Paid'].map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value,
                          style: const TextStyle(color: Color.fromARGB(255, 106, 103, 103),fontFamily: 'Poppins')),
                    );
                  }).toList(),
                  onChanged: (val) => status = val ?? 'No Paid',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Annuler",
                  style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 228, 236, 243)),
              child: const Text("Ajouter",
                  style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () async {
                if (selectedStudentId != null &&
                    amountController.text.isNotEmpty) {
                  await supabase.from('pyment').insert({
                    'student_id': selectedStudentId,
                    'amount': double.parse(amountController.text),
                    'status': status,
                    'pyment_date': DateTime.now().toIso8601String(),
                  });
                  Navigator.of(context).pop();
                  _fetchPayments();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("❌ Remplissez tous les champs.",
                            style: TextStyle(fontFamily: 'Poppins'))),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Map<DateTime, List<Map<String, dynamic>>> _groupPaymentsByDay() {
    final Map<DateTime, List<Map<String, dynamic>>> data = {};
    for (var payment in payments) {
      final date = DateTime.tryParse(payment['pyment_date'] ?? '')?.toLocal();
      if (date != null) {
        final day = DateTime(date.year, date.month, date.day);
        data.putIfAbsent(day, () => []).add(payment);
      }
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final events = _groupPaymentsByDay();

    return Scaffold(
      appBar: AppBar(
        title: const Text("💳 Paiements",
            style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF8E9EFB),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Ajouter un paiement",
            onPressed: _showAddPaymentDialog,
          )
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
        child: Column(
          children: [
            TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime(2023, 1, 1),
              lastDay: DateTime(2030, 12, 31),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) =>
                  events[DateTime(day.year, day.month, day.day)] ?? [],
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, eventsList) {
                  if (eventsList.isEmpty) return null;
                  final hasPaid = eventsList.any((e) => ['status'] == 'Paid');
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
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle:
                    TextStyle(fontFamily: 'Poppins', color: Colors.white),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle:
                    TextStyle(color: Colors.white, fontSize: 14,fontFamily: 'Poppins'),
                weekendStyle:
                    TextStyle(color: Colors.white, fontSize: 14,fontFamily: 'Poppins'),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: Colors.orange, shape: BoxShape.circle),
                selectedDecoration: BoxDecoration(
                    color: Colors.green, shape: BoxShape.circle),
                defaultTextStyle:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                weekendTextStyle:
                    TextStyle(color: Colors.white, fontFamily: 'Poppins'),
                outsideTextStyle:
                    TextStyle(color: Colors.white60, fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _getPaymentsForDay(_selectedDay).isEmpty
                  ? const Center(
                      child: Text("Aucun paiement trouvé.",
                          style: TextStyle(
                              fontFamily: 'Poppins', color: Colors.white)))
                  : ListView.builder(
                      itemCount: _getPaymentsForDay(_selectedDay).length,
                      itemBuilder: (context, index) {
                        final payment =
                            _getPaymentsForDay(_selectedDay)[index];
                        final studentName =
                            payment['students']?['full_name'] ?? "Inconnu";
                        final statusColor = payment['status'] == 'Paid'
                            ? Colors.green
                            : Colors.red;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: statusColor,
                              child: Icon(
                                  payment['status'] == 'Paid'
                                      ? Icons.check
                                      : Icons.close,
                                  color: Colors.white),
                            ),
                            title: Text(studentName,
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.black)),
                            subtitle: Text("💰 ${payment['amount']} DA",
                                style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.black87)),
                            trailing: IconButton(
                              icon:
                                  const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deletePayment(payment['id'].toString()),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
