
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:oo/admin/Admin%20Dashboard.dart';
import 'package:oo/view/screens/home_screen/teacher_home_screen%20(1).dart';

import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../student/student_home_screen.dart';
import '../Signup_Screen/Signup_Screen.dart';
import '../password/Forgot Password.dart';

import '../../parent/parent_profile_screen.dart'; // À ajouter si nécessaire

var myColor = LinearGradient(
  colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class LoginScreen extends StatefulWidget {
  static String routeName = 'LoginScreen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    passwordVisible = false;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final user = response.user;

      if (user == null) {
        _showError('Connection failed. Please try again.');
        return;
      }

      final profile =
          await supabase
              .from('profiles')
              .select('user_type')
              .eq('id', user.id)
              .maybeSingle();

      if (profile == null || profile['user_type'] == null) {
        _showError('Profile not found.');
        return;
      }

      final String userType = profile['user_type'];

      if (!mounted) return;

      switch (userType) {
        case 'Student':
          Navigator.pushReplacementNamed(context, StudentHomeScreen.routeName);
          break;
        case 'Teacher':
          Navigator.pushReplacementNamed(context, TeacherHomeScreen.routeName);
          break;
        case 'Parent':
          Navigator.pushReplacementNamed(
            context,
            ParentProfileScreen.routeName,
          );
          break;
        case 'Admin':
          Navigator.pushReplacementNamed(context, AdminDashboard.routeName);
          break;
        default:
          _showError('Unknown user type.');
      }
    } catch (e) {
      _showError('Erreur : ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> signInWithGoogle() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.google);
    } catch (e) {
      _showError('Google error: ${e.toString()}');
    }
  }

  Future<void> signInWithFacebook() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.facebook);
    } catch (e) {
      _showError('Facebook error : ${e.toString()}');
    }
  }

  Future<void> signInWithApple() async {
    try {
      await supabase.auth.signInWithOAuth(OAuthProvider.apple);
    } catch (e) {
      _showError('Apple error : ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:   BoxDecoration(gradient: myColor),
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', height: 100,
                  width: 100,), 
                  const Text(
                    'Connection',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'E-mail address',
                    obscureText: false,
                    icon: Icons.email_outlined,
                    validator:
                        (value) => value!.isEmpty ? 'Email requis' : null,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: !passwordVisible,
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    validator:
                        (value) =>
                            value!.length < 6
                                ? 'Password too short'
                                : null,
                  ),
                  const SizedBox(height: 30),
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      :
                      
                      InkWell(
                        onTap: _login,
                        child: Container(width: double.maxFinite,
                        height: 50,
                        child:Center(child: const Text(
                            'Log in',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),) ,
                        decoration: BoxDecoration(
                          
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          border: Border.all(color: Colors.white)),),
                      )
                      
                   , 

                      
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.google,
                          color: Colors.red,
                        ),
                        onPressed: signInWithGoogle,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.facebook,
                          color: Colors.blue,
                        ),
                        onPressed: signInWithFacebook,
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.apple,
                          color: Colors.black,
                        ),
                        onPressed: signInWithApple,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignUpScreen()),
                      );
                    },
                    child: const Text(
                      "Create an account",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required IconData icon,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontFamily: 'Poppins' , fontSize: 12),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: suffixIcon,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.white70,
          fontFamily: 'Poppins',
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
