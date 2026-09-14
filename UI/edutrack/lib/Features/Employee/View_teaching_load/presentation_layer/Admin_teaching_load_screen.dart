import 'package:edutrack/Features/Admin/Features/Home/presentation_layer/Screen/DashboardScreen.dart';
import 'package:edutrack/Features/Insructor/Features/DailyLectures/Data_layer/Model/LectureModel.dart';
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Model/ExamModel.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Model/TeachingLoadModel.dart';
import 'package:edutrack/Style/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:edutrack/Features/Employee/View_teaching_load/busines_logic_layer/AdminTeachingLoadController%20.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AdminTeachingLoadScreen extends GetView<AdminTeachingLoadController> {
  const AdminTeachingLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // التأكد من حقن الكنترولر
    if (!Get.isRegistered<AdminTeachingLoadController>()) {
      Get.put(AdminTeachingLoadController());
    }

    return Scaffold(
      backgroundColor: MyColors().Ghost_White,
      body: Row(
        children: [
          // قائمة المدرسين (الجانبية)
          _buildInternalInstructorList(),

          // منطقة عرض التقرير (المحتوى الأساسي)
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildReportContent(),
            ),
          ),
        ],
      ),
    );
  }

  // داخل كلاس AdminTeachingLoadScreen في تابع _buildInternalInstructorList

  Widget _buildInternalInstructorList() {
    return Container(
      width: 280, // وسعنا العرض شوي للراحة
      decoration: BoxDecoration(
        color: MyColors().AdminSidebarContent, // لون أغمق وأفخم
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Column(
        children: [
          // Header القائمة
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.blueAccent.withOpacity(0.1),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.blueAccent,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  "إدارة النصاب التدريسي",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                const Text(
                  "قائمة أعضاء الهيئة التدريسية",
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, indent: 20, endIndent: 20),

          Expanded(
            child: Obx(() {
              if (controller.isLoadingInstructors.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.blueAccent),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 12,
                ),
                itemCount: controller.facultyInstructors.length,
                itemBuilder: (context, index) {
                  final instructor = controller.facultyInstructors[index];
                  final String name = instructor['full_name'] ?? "بدون اسم";

                  return Obx(() {
                    final isSelected =
                        controller.selectedInstructor['id'] == instructor['id'];
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: isSelected
                            ? Colors.blueAccent
                            : Colors.transparent,
                      ),
                      child: ListTile(
                        onTap: () => controller.selectInstructor(instructor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: Icon(
                          Icons.person_pin_rounded,
                          color: isSelected ? Colors.white : Colors.white54,
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        trailing: Icon(
                          Icons.keyboard_arrow_right_outlined,

                          color: Colors.white,
                        ),
                        //
                        // Obx(() {
                        //   final report = controller.report.value;

                        //   // التأكد أولاً أن التقرير ليس فارغاً (null) وأن قيمة isfinished هي false

                        //   if (report != null && report.isfinished == false) {
                        //     return Icon(
                        //       Icons.notification_important_outlined,

                        //       color: Colors.red,
                        //     );
                        //   } else {
                        //     Icon(
                        //       Icons.keyboard_arrow_right_outlined,

                        //       color: Colors.white,
                        //     );
                        //   }

                        //   // ⚠️ ضروري جداً: إرجاع ويدجيت فارغة في حال كان التقرير مكتمل أو null عشان الـ Obx ما تضرب

                        //   return const SizedBox.shrink();
                        // }),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          // ElevatedButton(onPressed: () {}, child: Text("data")),
        ],
      ),
    );
  }

  // ... (داخل كلاس AdminTeachingLoadScreen)
  Widget _buildReportContent() {
    return Obx(() {
      // 1. الفحص الصحيح للـ RxMap: هل هي فارغة؟
      if (controller.selectedInstructor.isEmpty) {
        return _buildEmptyState();
      }

      // 2. حالة التحميل
      if (controller.isLoadingReport.value) {
        return Center(
          child: CircularProgressIndicator(color: colors.oxfordBlue),
        );
      }

      final report = controller.report.value;
      if (report == null) return const Center(child: Text("لا توجد بيانات"));

      return Column(
        children: [
          // Top Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Obx(
              () => Column(
                children: [
                  // شريط الاختيارات
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 30,
                      children: [
                        // قائمة السنة
                        Obx(() {
                          // 1. نتحقق إذا كانت القائمة لسه عم تتحمل من السيرفر مشان ما يضرب الـ Dropdown بقيمة فاضية
                          if (controller.isLoadingYears.value) {
                            return const SizedBox(
                              height: 50,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          // 2. إذا كانت القائمة جاهزة وفيها بيانات، بنعرض الـ Dropdown بنوعه الجديد String
                          return _buildFilterDropdown<String>(
                            label: "السنة الأكاديمية",
                            value: controller
                                .selectedYear
                                .value, // القيمة النصية الحالية (مثال: "2025-2026")
                            items: controller
                                .availableYears, // القائمة الديناميكية المستلمة من الباك إند
                            onChanged: (val) {
                              if (val != null) {
                                controller.selectedYear.value =
                                    val; // تحديث القيمة المختارة بالكونترولر
                                controller
                                    .fetchReport(); // إعادة جلب البيانات بناءً على السنة الجديدة
                              }
                            },
                          );
                        }),

                        // قائمة الشهر (مع خيار "الفصل كامل")
                        _buildFilterDropdown<int?>(
                          label: "الفترة",
                          value: controller.selectedMonth.value,
                          items: [null, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
                          itemLabel: (val) =>
                              val == null ? "الفصل كامل" : "شهر $val",
                          onChanged: (val) {
                            controller.selectedMonth.value = val;
                            controller.fetchReport();
                          },
                        ),

                        // زر طباعة PDF
                        ElevatedButton.icon(
                          onPressed: () => _generatePdf(),
                          icon: const Icon(Icons.print_rounded, size: 18),
                          label: const Text("PDF"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),

                        // الزر الجديد: يظهر فقط إذا كان التقرير غير مكتمل (isfinished == false)
                        Obx(() {
                          // نفترض أن التقرير مخزن في الكنترولر باسم reportModel أو اسم مشابه
                          final report = controller.report.value;

                          // التأكد أولاً أن التقرير ليس فارغاً (null) وأن قيمة isfinished هي false
                          if (report != null && report.isfinished == false) {
                            return ElevatedButton.icon(
                              onPressed: () {
                                // هنا تستدعي الفانكشن المسؤولة عن إرسال الإشعار من الكنترولر
                                controller.sendNotificationToInstructor();
                              },
                              icon: const Icon(
                                Icons.notification_important_rounded,
                                size: 18,
                              ),
                              label: const Text("إرسال إشعار"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .orangeAccent, // لون مميز للتحذير/الإشعار
                                foregroundColor: Colors.white,
                              ),
                            );
                          }

                          // في حال كان مكتمل (true) أو البيانات لم تُجلب بعد، لا يعرض شيئاً
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),

                  // الـ Row اللي فيه الاسم والزر
                ],
              ),
            ),
          ),

          // التقرير الفعلي
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(
                40,
              ), // زيادة الـ Padding ليعطي شكل رسمي
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 900,
                  ), // عرض الورقة المثالي
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Column(
                      children: [
                        _buildHeaderTitle(),
                        const SizedBox(height: 30),
                        _buildInfoSection(report),
                        const SizedBox(height: 30),
                        _buildTeachingTable(report.confirmedLectures),
                        const SizedBox(height: 30),
                        _buildExamTable(report.confirmedExams),
                        const SizedBox(height: 40),
                        _buildProjectsTable(report.confirmedProjects),
                        const SizedBox(height: 25),
                        _buildHRSection(),
                        const SizedBox(height: 40),
                        _buildSignaturesSection(report),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterDropdown<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
    String Function(T)? itemLabel,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: const SizedBox(),
        hint: Text(label),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(itemLabel != null ? itemLabel(item) : item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSignaturesSection(TeachingLoadReportModel r) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.8),
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[100]),
          children: [
            _tableHeader("اسم المدرس"),
            _tableHeader("تدقيق رئيس القسم"),
            _tableHeader("عميد الكلية"),
            _tableHeader("رئيس الجامعة"),
          ],
        ),
        TableRow(
          children: [
            _signatureCell(r.instructorName, "-"),
            _signatureCell("قيد التدقيق", "-"),
            _signatureCell("قيد التدقيق", "-"),
            _signatureCell("قيد التدقيق", "-"),
          ],
        ),
      ],
    );
  }

  Widget _infoCell(String text) => Padding(
    padding: const EdgeInsets.all(6.0),
    child: Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );

  Widget _tableHeader(String text) => Container(
    padding: const EdgeInsets.all(6),
    alignment: Alignment.center,
    child: Text(
      text,
      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
  Widget _tableCell(
    String text, {
    TextAlign align = TextAlign.center,
    FontWeight weight = FontWeight.normal,
  }) => Container(
    padding: const EdgeInsets.all(6),
    alignment: align == TextAlign.center
        ? Alignment.center
        : Alignment.centerRight,
    child: Text(text, style: TextStyle(fontSize: 10, fontWeight: weight)),
  );

  Widget _signatureCell(String name, String date) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    child: Column(
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(date, style: const TextStyle(fontSize: 8)),
        const SizedBox(height: 12),
        const Text(
          "التوقيع: .........",
          style: TextStyle(fontSize: 8, color: Colors.grey),
        ),
      ],
    ),
  );

  Widget _buildProjectsTable(List<LectureModel> projects) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.8),
      columnWidths: const {
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(4),
        2: FixedColumnWidth(65),
        3: FixedColumnWidth(65),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(
            color: Color(0xFFE8F5E9),
          ), // لون أخضر فاتح مخصص للمشاريع
          children: [
            _tableHeader("م"),
            _tableHeader("متابعة مشاريع التخرج"),
            _tableHeader("المطلوب"),
            _tableHeader("المنجز"),
          ],
        ),
        ...projects.asMap().entries.map((e) {
          final project = e.value;
          List<String> stats = project.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return TableRow(
            children: [
              _tableCell((e.key + 1).toString()),
              _tableCell(project.subject, align: TextAlign.right),
              _tableCell(total),
              _tableCell(done, weight: FontWeight.bold),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHRSection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: const Text(
            "مخصص لمديرية الموارد البشرية",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        Table(
          border: TableBorder.all(color: Colors.black, width: 0.8),
          children: [
            TableRow(
              children: [
                _infoCell("عدد الساعات النظرية المنجزة: (      ) ساعة"),
                _infoCell("عدد الساعات الفعلية المنجزة: (      ) ساعة"),
              ],
            ),
            TableRow(
              children: [
                _infoCell("عدد الساعات العملية المنجزة: (      ) ساعة"),
                _infoCell("النقص في تحقيق النصاب: (      ) ساعة"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExamTable(List<ExamModel> exams) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.8),
      columnWidths: const {
        0: FixedColumnWidth(30), // م
        1: FlexColumnWidth(4), // المهمة (المقرر) - أعطيناه مساحة أكبر
        2: FixedColumnWidth(65), // المطلوب
        3: FixedColumnWidth(65), // المنجز
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFE1F5FE)),
          children: [
            _tableHeader("م"),
            _tableHeader("المهمة (المقرر)"),
            _tableHeader("المطلوب"),
            _tableHeader("المنجز"),
          ],
        ),
        ...exams.asMap().entries.map((e) {
          final exam = e.value;
          List<String> stats = exam.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return TableRow(
            children: [
              _tableCell((e.key + 1).toString()),
              _tableCell(exam.course, align: TextAlign.right),
              _tableCell(total),
              _tableCell(done, weight: FontWeight.bold),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTeachingTable(List<LectureModel> lectures) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.8),
      columnWidths: const {
        0: FixedColumnWidth(30), // م
        1: FlexColumnWidth(3), // المقررات
        2: FixedColumnWidth(50), // المطلوب
        3: FixedColumnWidth(50), // المنجز
        // 4: FixedColumnWidth(40), // نظري
        // 5: FixedColumnWidth(40), // عملي
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _tableHeader("م"),
            _tableHeader("المقررات"),
            _tableHeader("المطلوب"),
            _tableHeader("المنجز"),
            // _tableHeader("نظري"),
            // _tableHeader("عملي"),
          ],
        ),
        ...lectures.asMap().entries.map((e) {
          final l = e.value;
          // تفكيك القيم من النص "done - total"
          List<String> stats = l.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return TableRow(
            children: [
              _tableCell((e.key + 1).toString()),
              _tableCell(l.subject, align: TextAlign.right),
              _tableCell(total),
              _tableCell(done, weight: FontWeight.bold), // المنجز بخط عريض
              // _tableCell(l.type == "نظري" ? "2" : "-"),
              // _tableCell(l.type == "عملي" ? "2" : "-"),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildHeaderTitle() => const Center(
    child: Text(
      "سجل الساعات التدريسية (الهيئة التدريسية والتعليمية)",
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.underline,
      ),
    ),
  );

  Widget _buildInfoSection(TeachingLoadReportModel r) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.8),
      children: [
        TableRow(
          children: [
            _infoCell("الكلية: ${r.faculty}"),
            _infoCell("اسم المدرس: ${r.instructorName}"),
            _infoCell("إجمالي الساعات : ${r.totalCompletedHours}"),
          ],
        ),
        TableRow(
          children: [
            _infoCell("القسم: ${r.department}"),
            _infoCell("المرتبة العلمية: ${r.rank}"),
            _infoCell("التاريخ :${r.reportDate}"),
          ],
        ),
      ],
    );
  }

  Future<void> _generatePdf() async {
    try {
      final report = controller.report.value!;
      final pdf = pw.Document();

      // التعديل الجوهري هنا: تحميل الخطوط من ملفاتك المحلية وليس من الإنترنت
      final regularFontData = await rootBundle.load(
        "Assets/Font/Cairo-Regular.ttf",
      );
      final boldFontData = await rootBundle.load("Assets/Font/Cairo-Bold.ttf");

      final pw.Font arabicFont = pw.Font.ttf(regularFontData);
      final pw.Font arabicFontBold = pw.Font.ttf(boldFontData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          textDirection: pw.TextDirection.rtl,
          margin: const pw.EdgeInsets.all(20),
          theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicFontBold),
          build: (pw.Context context) => [
            _buildPdfHeaderTitle(),
            pw.SizedBox(height: 15),
            _buildPdfInfoSection(report),
            pw.SizedBox(height: 20),
            _buildPdfTeachingTable(report.confirmedLectures),
            pw.SizedBox(height: 25),
            _buildPdfExamTable(report.confirmedExams),
            pw.SizedBox(height: 25),
            _buildPdfHRSection(),
            pw.SizedBox(height: 20),
            _buildPdfSignaturesSection(report),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name: 'سجل_نصاب_${report.instructorName}.pdf',
      );
    } catch (e) {
      Get.snackbar(
        "خطأ",
        "تأكد من مسار الخطوط Assets/Font/: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  pw.Widget _buildPdfHeaderTitle() => pw.Center(
    child: pw.Text(
      "سجل الساعات التدريسية (الهيئة التدريسية والتعليمية)",
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        decoration: pw.TextDecoration.underline,
      ),
    ),
  );

  pw.Widget _buildPdfInfoSection(TeachingLoadReportModel r) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
      children: [
        pw.TableRow(
          children: [
            _pdfInfoCell("الكلية: ${r.faculty}"),
            _pdfInfoCell("اسم المدرس: ${r.instructorName}"),
            _pdfInfoCell("إجمالي الساعات المنجزة: ${r.totalCompletedHours}"),
          ],
        ),
        pw.TableRow(
          children: [
            _pdfInfoCell("القسم: ${r.department}"),
            _pdfInfoCell("المرتبة العلمية: ${r.rank}"),
            _pdfInfoCell("التاريخ :${r.reportDate}"),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfTeachingTable(List<LectureModel> lectures) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
      columnWidths: {
        0: const pw.FixedColumnWidth(25), // م
        1: const pw.FlexColumnWidth(3), // المقررات
        2: const pw.FixedColumnWidth(40), // المطلوب
        3: const pw.FixedColumnWidth(40), // المنجز
        // 4: const pw.FixedColumnWidth(30), // نظري
        // 5: const pw.FixedColumnWidth(30), // عملي
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfTableHeader("م"),
            _pdfTableHeader("المقررات"),
            _pdfTableHeader("المطلوب"),
            _pdfTableHeader("المنجز"),
            // _pdfTableHeader("نظري"),
            // _pdfTableHeader("عملي"),
          ],
        ),
        ...lectures.asMap().entries.map((e) {
          final l = e.value;
          List<String> stats = l.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return pw.TableRow(
            children: [
              _pdfTableCell((e.key + 1).toString()),
              _pdfTableCell(l.subject, align: pw.TextAlign.right),
              _pdfTableCell(total),
              _pdfTableCell(done, weight: pw.FontWeight.bold),
              // _pdfTableCell(l.type == "نظري" ? "2" : "-"),
              // _pdfTableCell(l.type == "عملي" ? "2" : "-"),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfExamTable(List<ExamModel> exams) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(50),
        3: const pw.FixedColumnWidth(50),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFE1F5FE),
          ),
          children: [
            _pdfTableHeader("م"),
            _pdfTableHeader("المهمة (المقرر)"),
            _pdfTableHeader("المطلوب"),
            _pdfTableHeader("المنجز"),
          ],
        ),
        ...exams.asMap().entries.map((e) {
          final exam = e.value;
          List<String> stats = exam.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return pw.TableRow(
            children: [
              _pdfTableCell((e.key + 1).toString()),
              _pdfTableCell(exam.course, align: pw.TextAlign.right),
              _pdfTableCell(total),
              _pdfTableCell(done, weight: pw.FontWeight.bold),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildPdfHRSection() {
    return pw.Column(
      children: [
        pw.Container(
          width: double.infinity,
          color: PdfColors.grey400,
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(
            "مخصص لمديرية الموارد البشرية",
            textAlign: pw.TextAlign.center,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        ),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
          children: [
            pw.TableRow(
              children: [
                _pdfInfoCell("عدد الساعات النظرية المنجزة: (      ) ساعة"),
                _pdfInfoCell("عدد الساعات الفعلية المنجزة: (      ) ساعة"),
              ],
            ),
            pw.TableRow(
              children: [
                _pdfInfoCell("عدد الساعات العملية المنجزة: (      ) ساعة"),
                _pdfInfoCell("النقص في تحقيق النصاب: (      ) ساعة"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildPdfSignaturesSection(TeachingLoadReportModel r) => pw.Table(
    border: pw.TableBorder.all(color: PdfColors.black, width: 0.6),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey100),
        children: [
          _pdfTableHeader("اسم المدرس"),
          _pdfTableHeader("تدقيق رئيس القسم"),
          _pdfTableHeader("عميد الكلية"),
          _pdfTableHeader("رئيس الجامعة"),
        ],
      ),
      pw.TableRow(
        children: [
          _pdfSignatureCell(r.instructorName, " "),
          _pdfSignatureCell("رئيس القسم", " "),
          _pdfSignatureCell("عميد الكلية", " "),
          _pdfSignatureCell("رئيس الجامعة", " "),
        ],
      ),
    ],
  );

  pw.Widget _pdfInfoCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
    ),
  );
  pw.Widget _pdfTableHeader(String text) => pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
    ),
  );
  pw.Widget _pdfTableCell(
    String text, {
    pw.FontWeight weight = pw.FontWeight.normal,
    pw.TextAlign align = pw.TextAlign.center,
  }) => pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: align == pw.TextAlign.center
        ? pw.Alignment.center
        : pw.Alignment.centerRight,
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 7.5, fontWeight: weight),
    ),
  );

  pw.Widget _pdfSignatureCell(String name, String date) => pw.Padding(
    padding: const pw.EdgeInsets.all(4),
    child: pw.Column(
      children: [
        pw.Text(
          name,
          style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text(date, style: const pw.TextStyle(fontSize: 6.5)),
        pw.SizedBox(height: 6),
        pw.Text("التوقيع: .........", style: const pw.TextStyle(fontSize: 6.5)),
      ],
    ),
  );

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_rounded, size: 80, color: Colors.grey[200]),
          const SizedBox(height: 16),
          Text(
            'اختر مدرساً من القائمة لعرض تقرير النصاب',
            style: TextStyle(color: Colors.grey[400], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
