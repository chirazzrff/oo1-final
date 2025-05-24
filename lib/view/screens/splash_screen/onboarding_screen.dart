import 'package:flutter/material.dart';
import 'package:oo/view/screens/login_screen/login_screen.dart';
import 'package:sizer/sizer.dart';

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
          "Brain School is a complete educational platform connecting students, teachers, and parents with personalized tracking and interactive courses.",
      "image": "assets/images/onboarding1.jpg",
    },
    {
      "title": "Interactive Learning",
      "description":
          "Engage with interactive activities, quizzes, and real-time feedback, while schools manage everything efficiently.",
      "image": "assets/images/onboarding2.jpg",
    },
    {
      "title": "Better Communication",
      "description":
          "Stay connected with real-time updates, messaging features, and performance tracking.",
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
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 6.h),
                child: Column(
                  children: [
                    Image.asset(
                      _onboardingData[index]["image"]!,
                      height: 40.h,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      _onboardingData[index]["title"]!,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _onboardingData[index]["description"]!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
          ),

          // Page Indicator
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.blue
                        : Colors.grey.shade400,
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
