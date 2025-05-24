import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EmploiDuTempsScreen extends StatefulWidget {
  @override
  _EmploiDuTempsScreenState createState() => _EmploiDuTempsScreenState();
}

class _EmploiDuTempsScreenState extends State<EmploiDuTempsScreen> {
  DateTime _selectedDay = DateTime.now();
  final Gradient appBarGradient = const LinearGradient(
    colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Future<List<Map<String, dynamic>>> getCoursForDay(DateTime day) async {
    final String key = DateFormat('yyyy-MM-dd').format(day);
    final response = await Supabase.instance.client
        .from('emploi_du_temps')
        .select()
        .eq('date', key);
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: appBarGradient),
          ),
          title: Text(
            'Emploi du Temps',
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Container(
        color: Color(0xFFF0F3FF),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: getCoursForDay(day),
                    builder: (context, snapshot) {
                      final hasCours = snapshot.hasData && snapshot.data!.isNotEmpty;
                      final isSelected = isSameDay(day, _selectedDay);
                      return Container(
                        margin: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Color(0xFF6D7DE3)
                              : hasCours
                              ? Colors.green.withOpacity(0.2)
                              : Colors.transparent,
                          border: hasCours
                              ? Border.all(color: Colors.green, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orangeAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF6D7DE3),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(color: Colors.white),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(
                  color: Color(0xFF345FB4),
                  fontFamily: 'Poppins',
                ),
                weekdayStyle: TextStyle(
                  fontFamily: 'Poppins',
                ),
              ),
              headerStyle: HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF345FB4),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Cours pour le ${DateFormat('dd MMMM yyyy', 'fr_FR').format(_selectedDay)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: Color(0xFF345FB4),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getCoursForDay(_selectedDay),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'Aucun cours ce jour.',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    );
                  }

                  final cours = snapshot.data!;
                  return ListView.builder(
                    itemCount: cours.length,
                    itemBuilder: (context, index) {
                      final item = cours[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        elevation: 6,
                        color: Colors.white,
                        shadowColor: Colors.grey.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.book_rounded, color: Color(0xFF6D7DE3), size: 28),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${item['matiere']}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF345FB4),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(Icons.schedule, color: Colors.grey[600], size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    '${item['horaire']}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.class_, color: Colors.grey[600], size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    '${item['classe']}',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 15,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ],
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
    );
  }
}
