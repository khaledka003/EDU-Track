import 'package:edutrack/Features/Insructor/Features/WeeklySchedule/busines_logic_layer/WeeklyController.dart'; // استيراد كونترولر الجدول الأسبوعي
import 'package:edutrack/Features/Insructor/Features/Project/busines_logic_layer/ProjectViewController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' as intl;

class QuotaFillingSheet extends StatefulWidget {
  final int projectId;
  final String projectTitle;

  const QuotaFillingSheet({
    Key? key,
    required this.projectId,
    required this.projectTitle,
  }) : super(key: key);

  @override
  State<QuotaFillingSheet> createState() => _QuotaFillingSheetState();
}

class _QuotaFillingSheetState extends State<QuotaFillingSheet> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<dynamic> _reservedLecturesForSelectedDay =
      []; // لتخزين محاضرات اليوم المختار

  // دالة مساعدة لتحويل الوقت إلى صيغة HH:MM:SS المطلوبة في دجانغو
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return intl.DateFormat('HH:mm:ss').format(dt);
  }

  // 🔄 دالة لتحديث المحاضرات المحجوزة بناءً على اليوم المختار
  void _updateReservedSlots(DateTime date) {
    final weeklyCtrl = Get.find<WeeklyController>();
    // تحويل اسم اليوم للغة العربية ليطابق المفاتيح الموجودة في الـ weeklyData (الأحد، الاثنين...)
    String dayNameArabic = intl.DateFormat('EEEE', 'ar').format(date);

    // تصحيح الأخطاء الإملائية الشائعة في أسماء الأيام لمطابقة مفاتيح السيرفر تماماً
    if (dayNameArabic == "الإثنين") dayNameArabic = "الاثنين";

    if (weeklyCtrl.weeklyData.containsKey(dayNameArabic)) {
      setState(() {
        _reservedLecturesForSelectedDay =
            weeklyCtrl.weeklyData[dayNameArabic] ?? [];
      });
    } else {
      setState(() {
        _reservedLecturesForSelectedDay = [];
      });
    }
  }

  // 📅 فتح نافذة اختيار التاريخ
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('ar', 'AE'),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _startTime = null; // تصفير الوقت القديم لتجنب التضارب عند تغيير اليوم
        _endTime = null;
      });
      _updateReservedSlots(
        picked,
      ); // تحديث المحاضرات المحجوزة فوراً لليوم الجديد
    }
  }

  Future<void> _pickStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 8, minute: 30),
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? const TimeOfDay(hour: 10, minute: 0),
    );
    if (picked != null && picked != _endTime) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectViewCtrl = Get.find<ProjectViewController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.9, // زيادة الارتفاع ليتسع لعرض الأوقات المحجوزة
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Obx(() {
            if (projectViewCtrl.isSavingSession.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "جاري معالجة الجلسة والتحقق من عدم وجود تضارب...",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              // إضافة سكرول مرن حتى لا يحصل OverFlow عند ظهور الأوقات المحجوزة
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.more_time_rounded,
                                  color: Colors.indigo.shade700,
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "تسجيل جلسة مشروع جديدة",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "المشروع: ${widget.projectTitle}",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, thickness: 1),
                  const SizedBox(height: 12),

                  // 1. اختيار التاريخ الفعلي
                  const Text(
                    "تاريخ الجلسة",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => _pickDate(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: Colors.indigo.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _selectedDate == null
                                ? "اضغط هنا لاختيار تاريخ الجلسة"
                                : intl.DateFormat(
                                    'yyyy-MM-dd (EEEE)',
                                    'ar',
                                  ).format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedDate == null
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                              color: _selectedDate == null
                                  ? Colors.grey.shade500
                                  : Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🔥 2. قسم عرض الأوقات المحجوزة باللون الأحمر (يظهر فقط إذا تم اختيار تاريخ ووجد محاضرات)
                  if (_selectedDate != null) ...[
                    const Text(
                      "المواعيد غير المتاحة في هذا اليوم (محاضرات ثابتة):",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _reservedLecturesForSelectedDay.isEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "ممتاز! جدول الدكتور فارغ تماماً في هذا اليوم.",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _reservedLecturesForSelectedDay.map((
                              lecture,
                            ) {
                              String timeLabel = "";
                              String courseName = "";
                              if (lecture is Map) {
                                timeLabel = (lecture['time'] ?? '').toString();
                                courseName =
                                    (lecture['subject'] ??
                                            lecture['name'] ??
                                            'محاضرة ثابته')
                                        .toString();
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.block_rounded,
                                      color: Colors.red.shade800,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "$courseName ($timeLabel)",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red.shade900,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                    const SizedBox(height: 20),
                  ],

                  // 3. اختيار الوقت الحركي (من وإلى)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "وقت البدء",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectedDate == null
                                  ? null
                                  : () => _pickStartTime(
                                      context,
                                    ), // تفعيل فقط بعد اختيار التاريخ
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedDate == null
                                      ? Colors.grey.shade100
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_filled_rounded,
                                      color: _selectedDate == null
                                          ? Colors.grey
                                          : Colors.green.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _startTime == null
                                          ? "00:00"
                                          : _startTime!.format(context),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedDate == null
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "وقت الانتهاء",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _selectedDate == null
                                  ? null
                                  : () => _pickEndTime(context),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedDate == null
                                      ? Colors.grey.shade100
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.disabled_by_default_rounded,
                                      color: _selectedDate == null
                                          ? Colors.grey
                                          : Colors.red.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _endTime == null
                                          ? "00:00"
                                          : _endTime!.format(context),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: _selectedDate == null
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // 4. زر التأكيد النهائي والإرسال
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          (_selectedDate == null ||
                              _startTime == null ||
                              _endTime == null)
                          ? null
                          : () async {
                              final String dateStr = intl.DateFormat(
                                'yyyy-MM-dd',
                              ).format(_selectedDate!);
                              final String startStr = _formatTimeOfDay(
                                _startTime!,
                              );
                              final String endStr = _formatTimeOfDay(_endTime!);

                              // حفظ الـ Context الحالي للـ BottomSheet قبل الدخول في الـ async
                              final Map<String, dynamic> sessionData = {
                                'projectId': widget.projectId,
                                'sessionDate': dateStr,
                                'startTime': startStr,
                                'endTime': endStr,
                              };

                              // استدعاء الدالة وانتظار النتيجة
                              bool isSuccess = await projectViewCtrl
                                  .saveProjectSession(
                                    projectId: sessionData['projectId'],
                                    sessionDate: sessionData['sessionDate'],
                                    startTime: sessionData['startTime'],
                                    endTime: sessionData['endTime'],
                                  );

                              if (isSuccess) {
                                // إغلاق الـ BottomSheet الحالية فوراً وبأمان
                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Get.back();
                                }

                                // تحديث البيانات في الخلفية بعد الإغلاق
                                projectViewCtrl.fetchInstructorProjects();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade200,
                        disabledForegroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "تأكيد وتسجيل الجلسة",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
