import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Login.dart';
import 'package:edutrack/Features/Auth/Presentation_layer/Screen/Onboarding/Onboarding.dart';
import 'package:edutrack/Features/Employee/Home/presentation_layer/EmployeeDashboard.dart';
import 'package:edutrack/Features/Insructor/Home.dart';
import 'package:edutrack/Features/Admin/Features/Home/presentation_layer/Screen/DashboardScreen.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController;

  // متغير لمتابعة ما إذا كان أنيميشن Lottie قد انتهى لإظهار الأيقونة الثابتة
  bool _isAnimationCompleted = false;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    String? token = box.read('token');
    String role = box.read('role')?.toString().toLowerCase() ?? '';
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    if (token != null && token.isNotEmpty) {
      if (role == 'admin') {
        Get.offAll(() => DashboardScreen());
      } else if (role == 'employee') {
        Get.offAll(() => EmployeeDashboard());
      } else if (role == 'instructor') {
        Get.offAll(() => Home());
      } else {
        Get.offAll(() => Login());
      }
    } else {
      if (isDesktop) {
        Get.offAll(() => Login());
      } else {
        Get.offAll(() => Onboarding());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLargeScreen = screenWidth > 800;

    // حجم الأنيميشن الأساسي ديناميكياً حسب نوع الشاشة
    final double animationSize = isLargeScreen ? 300.0 : 200.0;

    // حجم الأيقونة الثابتة ديناميكياً ليناسب حجم الموبايل أو اللابتوب بذكاء
    final double iconSize = isLargeScreen
        ? (animationSize - 100.0)
        : (animationSize - 100.0);

    return Scaffold(
      body: Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // الـ AnimatedSwitcher يضمن انتقال تدريجي ناعم (Fade) بين الوجيتين
              AnimatedSwitcher(
                duration: const Duration(
                  milliseconds: 200,
                ), // سرعة الانتقال التناغمي
                child: !_isAnimationCompleted
                    ? ColorFiltered(
                        key: const ValueKey('lottie_anim'),
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                        child: Lottie.asset(
                          'Assets/Animations/education_anim1.json',
                          width: animationSize,
                          height: animationSize,
                          fit: BoxFit.contain,
                          controller: _lottieController,
                          onLoaded: (composition) {
                            _lottieController.duration = composition.duration;

                            // تسريع الأنميشن للضعف
                            _lottieController.duration = Duration(
                              microseconds:
                                  (composition.duration.inMicroseconds / 2.1)
                                      .toInt(),
                            );

                            _lottieController.forward(from: 0.0);

                            // مراقبة حركة الأنميشن لقص الثواني الأخيرة عند 65% كما حددت أنت
                            _lottieController.addListener(() {
                              if (_lottieController.value >= 0.60 &&
                                  !_isAnimationCompleted) {
                                // 1. إيقاف الأنميشن يدوياً فوراً
                                _lottieController.stop();

                                // 2. الانتقال للحالة الثانية لإطلاق تأثير انبثاق الأيقونة الثابتة
                                setState(() {
                                  _isAnimationCompleted = true;
                                });

                                // 3. الثبات والراحة البصرية بعد الارتداد ثم الانتقال
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () {
                                    _navigateToNextScreen();
                                  },
                                );
                              }
                            });
                          },
                        ),
                      )
                    : TweenAnimationBuilder<double>(
                        key: const ValueKey('static_icon_pop'),
                        tween: Tween<double>(begin: 0.0, end: 1.0),
                        duration: const Duration(
                          milliseconds: 500,
                        ), // وقت تأثير الانبثاق والارتداد
                        curve: Curves
                            .ease, // منحنى يعطي ارتداداً مطاطياً فخماً وثقيل للأيقونة
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale:
                                value, // تكبير تدريجي يبدأ من صفر إلى الحجم الطبيعي مع الارتداد
                            child: Icon(
                              Icons.school,
                              size: iconSize, // الحجم الديناميكي المحسوب بدقة
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
