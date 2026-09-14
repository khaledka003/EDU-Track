import 'package:edutrack/Features/Insructor/Features/Profile/busines_logic_layer/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // استدعاء الكنترولر لبدء جلب البيانات
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          _buildArtisticBackground(),
          SafeArea(
            child: Obx(() {
              // عرض مؤشر تحميل أثناء جلب البيانات
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F172A)),
                );
              }

              final user = controller.profile.value;
              if (user == null) {
                return const Center(child: Text("لا توجد بيانات متاحة حالياً"));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  bool isDesktop = constraints.maxWidth > 950;
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: isDesktop
                          ? _buildModernDesktopLayout(user)
                          : _buildModernMobileLayout(user),
                    ),
                  );
                },
              );
            }),
          ),
          Positioned(top: 40, left: 20, child: _buildGlassBackButton()),
        ],
      ),
    );
  }

  // --- خلفية فنية ---
  Widget _buildArtisticBackground() {
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -100,
          child: _buildGradientSphere(500, const Color(0xFFDBEAFE)),
        ),
        Positioned(
          bottom: -100,
          left: -50,
          child: _buildGradientSphere(400, const Color(0xFFFEE2E2)),
        ),
        Positioned(
          top: 250,
          left: 150,
          child: _buildGradientSphere(350, const Color(0xFFE0F2FE)),
        ),
      ],
    );
  }

  Widget _buildGradientSphere(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withOpacity(0)]),
      ),
    );
  }

  // --- تصميم اللابتوب (Desktop) ---
  Widget _buildModernDesktopLayout(user) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          width: 1100,
          height: 700,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSideIdentitySection(user.fullName, user.faculty),
              ),
              Expanded(
                flex: 3,
                child: _buildDetailsSection(
                  user.academicRank,
                  user.specialization,
                  user.email,
                  user.mobile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- تصميم الموبايل (Mobile) ---
  Widget _buildModernMobileLayout(user) {
    return Column(
      children: [
        _buildPremiumAvatar(size: 65),
        const SizedBox(height: 20),
        Text(
          user.fullName,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 10),
        _buildBadge(user.faculty),
        const SizedBox(height: 35),
        _buildNeumorphicCard(
          Icons.lan_rounded,
          "التخصص",
          user.specialization,
          const Color(0xFFEC4899),
          isFullWidth: true,
        ),
        const SizedBox(height: 15),
        _buildNeumorphicCard(
          Icons.phone_iphone_rounded,
          "رقم الموبايل",
          user.mobile,
          const Color(0xFFF59E0B),
          isFullWidth: true,
        ),
        const SizedBox(height: 15),
        _buildNeumorphicCard(
          Icons.email_rounded,
          "البريد الإلكتروني",
          user.email,
          const Color(0xFF06B6D4),
          isFullWidth: true,
        ),
        const SizedBox(height: 40),
        _buildActionButtons(),
      ],
    );
  }

  Widget _buildSideIdentitySection(String name, String college) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.3))),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPremiumAvatar(size: 85),
          const SizedBox(height: 30),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 12),
          _buildBadge(college),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(
    String rank,
    String specialty,
    String email,
    String phone,
  ) {
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "الملف الأكاديمي",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.6,
              children: [
                _buildNeumorphicCard(
                  Icons.school_rounded,
                  "الرتبة الأكاديمية",
                  rank,
                  const Color(0xFF6366F1),
                ),
                _buildNeumorphicCard(
                  Icons.lan_rounded,
                  "التخصص",
                  specialty,
                  const Color(0xFFEC4899),
                ),
                _buildNeumorphicCard(
                  Icons.email_rounded,
                  "البريد الرسمي",
                  email,
                  const Color(0xFF06B6D4),
                ),
                _buildNeumorphicCard(
                  Icons.phone_iphone_rounded,
                  "رقم الموبايل",
                  phone,
                  const Color(0xFFF59E0B),
                ),
              ],
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildPremiumAvatar({required double size}) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: CircleAvatar(
        radius: size,
        backgroundColor: Colors.white.withOpacity(0.8),
        child: Icon(
          Icons.person_outline_rounded,
          size: size * 0.9,
          color: const Color(0xFF64748B),
        ),
      ),
    );
  }

  Widget _buildNeumorphicCard(
    IconData icon,
    String label,
    String value,
    Color accent, {
    bool isFullWidth = false,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildPremiumButton("تعديل البيانات الشخصية", [
          const Color(0xFF1E293B),
          const Color(0xFF334155),
        ], Icons.edit_rounded),
        const SizedBox(height: 12),
        _buildPremiumButton("تغيير كلمة المرور", [
          const Color(0xFF64748B),
          const Color(0xFF94A3B8),
        ], Icons.lock_reset_rounded),
      ],
    );
  }

  Widget _buildPremiumButton(String text, List<Color> colors, IconData icon) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(colors: colors),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white, size: 18),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569),
        ),
      ),
    );
  }

  Widget _buildGlassBackButton() {
    return InkWell(
      onTap: () => Get.back(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.5)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
