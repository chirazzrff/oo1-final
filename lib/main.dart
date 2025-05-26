import 'package:oo/admin/ManageStudentsScreen.dart';
import 'package:oo/my_profile_screen.dart';
import 'package:oo/routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:oo/view/teacher/attendance_screen.dart';
import 'admin/EmploiDuTempsScreen.dart';
import 'admin/Emploi_Du_TempsScreen.dart';
import 'chemin/vers/ajouter_emploi_du_temps_screen.dart';
import 'package:oo/theme.dart';
import 'package:flutter/material.dart';
import 'package:oo/view/chat_view/chatscreen_list.dart';
import 'package:oo/view/chat_view/list_user.dart';
import 'package:oo/view/parent/attendance_screen.dart';
import 'attendance_screen.dart';

import 'package:oo/view/parent/grades_screen.dart';
import 'package:oo/view/parent/homework_screen.dart';
import 'package:oo/view/parent/parent_profile_screen.dart';
import 'package:oo/view/parent/technical_support_screen.dart';
import 'package:oo/view/screens/Signup_Screen/Signup_Screen.dart';
import 'package:oo/view/screens/home_screen/teacher_home_screen%20(1).dart';

import 'package:oo/view/screens/password/CreateNewPasswordScreen.dart';
import 'package:oo/view/student/edit_student_profile_screen.dart';
import 'package:oo/view/student/notifications_screen.dart';
import 'package:oo/view/student/student_attendance_screen.dart';
import 'package:oo/view/student/student_contact_screen.dart';
import 'package:oo/view/student/student_details_screen.dart';
import 'package:oo/view/student/student_home_screen.dart';
import 'package:oo/view/student/student_profile_screen.dart';
import 'package:oo/view/student/student_results_screen.dart';
import 'package:oo/view/student/student_support_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin/Admin Dashboard.dart';

import 'admin/manage_users.dart';

import 'admin/manage_notifications.dart';
import 'admin/manage_payments.dart';
import 'admin/manage_schools.dart';
import 'admin/view_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);

  await Supabase.initialize(
    url: 'https://tzitjtxfxpehavjnemka.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6aXRqdHhmeHBlaGF2am5lbWthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyNjc3MjYsImV4cCI6MjA2MDg0MzcyNn0.81-9b5-IBtW_cOGw8o0NzMVGG5v91xJ9XylgMA0zUeY',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, device) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'School Brain',
          theme: CustomTheme().baseTheme,
          initialRoute: SplashScreen.routeName,
          routes: {
            ...routes,
            SignUpScreen.routeName: (context) => SignUpScreen(),
            AdminDashboard.routeName: (context) => AdminDashboard(),
            ManageNotificationsScreen.routeName:
                (context) => ManageNotificationsScreen(),
            ManageUsersScreen.routeName: (context) => ManageUsersScreen(),
            ManageSchoolsScreen.routeName: (context) => ManageSchoolsScreen(),
            ManagePaymentsScreen.routeName: (context) => ManagePaymentsScreen(),
            ViewDataScreen.routeName: (context) => ViewDataScreen(),
            ManageStudentsScreen.routeName: (context) => ManageStudentsScreen(),
            MyProfileScreen.routeName: (context) => MyProfileScreen(),
            MyProfileScreen.routeName: (context) => const MyProfileScreen(),
            'StudentProfile': (context) => StudentProfileScreen(),
            'SignUpScreen': (_) => SignUpScreen(),
            'HomeworkScreen': (context) => const HomeworkScreen(),
            'GradesScreen': (context) => const ParentGradesScreen(),
            '/studentHome': (_) => StudentHomeScreen(),
            '/TeacherHomeScreen': (_) => TeacherHomeScreen(),
            AjouterEmploiDuTempsScreen.routeName: (context) => AjouterEmploiDuTempsScreen(),

            '/adminDashboard': (_) => AdminDashboard(),
            '/UserListScreen': (_) => UserListScreen(),
            'ChatWithUserByIdScreen':
                (_) => ChatWithUserByIdScreen(userId: '', name: ''),
            'UserListScreen': (_) => UserListScreen(),
            '/UserListScreen': (context) => UserListScreen(),
            '/ChatWithUserByIdScreen':
                (context) => ChatWithUserByIdScreen(userId: '', name: ''),
            ChatWithUserByIdScreen.routeName:
                (context) => const ChatWithUserByIdScreen(userId: '', name: ''),
            'TechnicalSupportScreen':
                (context) => const TechnicalSupportScreen(),
            StudentContactScreen.routeName: (context) => StudentContactScreen(),
            StudentResultsScreen.routeName:
                (context) => StudentResultsScreen(studentId: ''),
            EditStudentProfileScreen.routeName:
                (context) =>
                EditStudentProfileScreen(name: '', email: '', phone: ''),
            NotificationsScreen.routeName: (context) => NotificationsScreen(),
            StudentAttendanceScreen.routeName:
                (context) => StudentAttendanceScreen(),
            StudentDetailsScreen.routeName:
                (context) => StudentDetailsScreen(
              email: '',
              phone: '',
              birthDate: '',
              academicLevel: '',
              courses: [],
              absences: 0, // Default value
              average: 0.0,
            ),
            StudentSupportScreen.routeName: (context) => StudentSupportScreen(),
            AttendanceScreen.routeName: (context) => AttendanceScreen(),
          },
        );
      },
    );
  }
}
