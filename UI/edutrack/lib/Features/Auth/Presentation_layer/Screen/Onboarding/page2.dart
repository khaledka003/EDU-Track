import 'package:easy_localization/easy_localization.dart'; // إضافة الاستيراد للترجمة
import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Onboarding/TopCurveClipper.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';

class Page2 extends StatelessWidget {
  const Page2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyColors().Ocean_Blue,
            MyColors().Deep_Ocean_Blue,
            MyColors().Oxford_Blue,
          ],
        ),
      ),
      child: Column(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.35,
              child: Icon(
                Icons.auto_graph,
                size: 100,
                color: MyColors().Deep_Ocean_Blue,
              ),
              color: Colors.white.withAlpha(200),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Text(
            tr("onboarding_page2_title"), // استبدال النص
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              tr("onboarding_page2_desc"), // استبدال النص
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
