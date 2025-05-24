
import 'package:flutter/cupertino.dart';
import 'package:oo/admin/ManageStudentsScreen.dart';
import 'package:oo/my_profile_screen.dart';
import 'package:oo/view/parent/attendance_screen.dart';
import 'package:oo/view/parent/parent_home_screen.dart';
import 'package:oo/view/parent/parent_profile_screen.dart';
import 'package:oo/view/screens/assignment_screen/assignment_screen.dart';
import 'package:oo/view/screens/datesheet_screen/datesheet_screen.dart';
import 'package:oo/view/screens/fee_screen/fee_screen.dart';
import 'package:oo/view/screens/home_screen/home_screen.dart';
import 'package:oo/view/screens/home_screen/teacher_home_screen%20(1).dart';



import 'package:oo/view/screens/login_screen/login_screen.dart';
import 'package:oo/view/screens/my_profile/teacher_profile.dart';
import 'package:oo/view/screens/password/CreateNewPasswordScreen.dart';
import 'package:oo/view/student/student_attendance_screen.dart';
import 'package:oo/view/student/student_grades_screen.dart';
import 'package:oo/view/student/student_home_screen.dart';
import 'package:oo/view/student/student_profile_screen.dart';
import 'package:oo/view/teacher/add_student_grade_screen.dart';
import 'admin/Admin Dashboard.dart';




import 'admin/manageSyllabus.dart';
import 'admin/manage_payments.dart';
import 'admin/manage_schools.dart';

import 'admin/manage_users.dart';
import 'admin/view_data.dart';

import 'package:flutter/material.dart';


Map<String, WidgetBuilder> routes = {
  //all screens will be registered here like manifest in android
  SplashScreen.routeName: (context) => SplashScreen(),
  LoginScreen.routeName: (context) => LoginScreen(),
  HomeScreen.routeName: (context) => HomeScreen(),
  MyProfileScreen.routeName: (context) => MyProfileScreen(),
  FeeScreen.routeName: (context) => FeeScreen(),
  AssignmentScreen.routeName: (context) => AssignmentScreen(),
  DateSheetScreen.routeName: (context) => DateSheetScreen(),
  ParentHomeScreen.routeName: (context) => ParentHomeScreen(),
  
  TeacherHomeScreen.routeName: (context) => TeacherHomeScreen(),
  ParentProfileScreen.routeName: (context) => ParentProfileScreen(),
  TeacherProfileScreen.routeName: (context) => TeacherProfileScreen(),
  'TeacherProfile': (context) => TeacherHomeScreen(),
  'ParentProfile': (context) => ParentProfileScreen(),
  'StudentProfileScreen': (context) => MyProfileScreen(),
  AdminDashboard.routeName: (context) => AdminDashboard(),
  ManageUsersScreen.routeName: (context) => ManageUsersScreen(),
  ManageSchoolsScreen.routeName: (context) => ManageSchoolsScreen(),
  ManagePaymentsScreen.routeName: (context) => ManagePaymentsScreen(),
  ViewDataScreen.routeName: (context) => ViewDataScreen(),
  ManageStudentsScreen.routeName: (context) => ManageStudentsScreen(),
  ManageSyllabusScreen.routeName: (context) => ManageSyllabusScreen(),
  MyProfileScreen.routeName: (context) => const MyProfileScreen(),
  'StudentHomeScreen': (context) => const StudentHomeScreen(),
  'StudentProfileScreen': (context) => const StudentProfileScreen(),
  StudentProfileScreen.routeName: (context) => const StudentProfileScreen(),
  StudentHomeScreen.routeName: (context) => const StudentHomeScreen(),
'/manageusers': (context) => ManageUsersScreen(),


  '/student-home': (context) => StudentHomeScreen(),
  AddStudentGradeScreen.routeName: (_) => AddStudentGradeScreen(),

  StudentGradesScreen.routeName: (_) => StudentGradesScreen(),
  '/': (context) => HomeScreen(), // ton écran d'accueil
  AddStudentGradeScreen.routeName: (context) => const AddStudentGradeScreen(),
  '/grades': (context) => const StudentGradesScreen(),
  StudentAttendanceScreen.routeName: (context) => StudentAttendanceScreen(),
  StudentProfileScreen.routeName: (context) => const StudentProfileScreen(),
  StudentHomeScreen.routeName: (context) => const StudentHomeScreen(),
  StudentProfileScreen.routeName: (context) => const StudentProfileScreen(),
  
};



