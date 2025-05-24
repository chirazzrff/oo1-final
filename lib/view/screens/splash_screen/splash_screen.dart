import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:oo/view/screens/login_screen/login_screen.dart';
import 'package:sizer/sizer.dart';

var myColor = LinearGradient(
  colors: [Color(0xFF8E9EFB), Color(0xFFB8C6DB)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
class SplashScreen extends StatefulWidget {
  static String routeName = 'SplashScreen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 60), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      },
      child: Scaffold(
        backgroundColor:  Color(0xFF8E9EFB),
          drawerScrimColor: Color(0xFFB8C6DB),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Image.asset(
                'assets/images/logo.png',
                height: 60.h,
                width: 60.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- ONBOARDING ----------------------
// ---------------------- ONBOARDING ----------------------
class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentIndex = 0;
  final PageController _controller = PageController();

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Welcome to Brain School!",
      "description":
          "Brain School is a complete educational platform that connects students, teachers, and parents with personalized tracking, interactive courses, and efficient school management. \n\nWith Brain School, you can track your child's progress, communicate with teachers, and access interactive learning materials.",
      "image": "assets/images/onboarding1.jpg",
    },
    {
      "title": "Interactive Learning",
      "description":
          "Brain School revolutionizes digital learning by simplifying school management. \n\nIt enables schools to efficiently manage teachers, students, and courses while providing an engaging learning experience with interactive activities, quizzes, and real-time feedback.",
      "image": "assets/images/onboarding2.jpg",
    },
    {
      "title": "Better Communication",
      "description":
          "With an intuitive interface and powerful tools, Brain School enhances communication between teachers, parents, and students. \n\nReal-time updates, messaging features, and performance tracking ensure students receive the best educational support possible.",
      "image": "assets/images/onboarding3.jpg",
    },
  ];

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: _onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    Center(
                      child: Image.asset(
                        _onboardingData[index]["image"]!,
                        height: 50.h,
                        width: 80.w,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Title (outside the blue container)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      child: Text(
                        _onboardingData[index]["title"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black, // Noir
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Description inside the blue container (Scrollable)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 5.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF8E9EFB),

                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        _onboardingData[index]["description"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 5.h), // Espace en bas pour le défilement
                  ],
                ),
              );
            },
          ),

          // Skip Button
          Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: _skip,
              child: Text(
                "Skip",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E9EFB),
                ),
              ),
            ),
          ),

          // Indicator & Next Button
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == index
                            ? Colors.blue
                            : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),

          // Get Started Button
          if (_currentIndex == _onboardingData.length - 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: ElevatedButton(
                  onPressed: _skip,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Colors.blue.shade700,
                  ),
                  child: Text(
                    "Get Started",
                    style: TextStyle(fontSize: 14.sp, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
