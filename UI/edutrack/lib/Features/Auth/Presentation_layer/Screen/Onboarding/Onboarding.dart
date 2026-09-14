import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Login.dart';
import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Onboarding/page1.dart';
import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Onboarding/page2.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController controller = PageController(initialPage: 0);
  final List<Widget> pages = [Page1(), Page2(), Login()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(controller: controller, children: pages),
          Padding(
            padding: EdgeInsets.only(bottom: 50),
            child: SmoothPageIndicator(
              controller: controller,
              count: pages.length,
              effect: ExpandingDotsEffect(
                dotColor: Colors.white.withAlpha(200),
                activeDotColor: Colors.white,
                dotHeight: 10,
                dotWidth: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
