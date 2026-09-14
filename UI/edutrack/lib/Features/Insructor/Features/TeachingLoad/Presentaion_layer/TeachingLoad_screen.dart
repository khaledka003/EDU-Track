import 'package:edutrack/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:get/get.dart';

import 'package:edutrack/Features/Insructor/Features/DailyLectures/Data_layer/Model/LectureModel.dart';
import 'package:edutrack/Features/Insructor/Features/ExamAssignment/Data_layer/Model/ExamModel.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/Data_layer/Model/TeachingLoadModel.dart';
import 'package:edutrack/Features/Insructor/Features/TeachingLoad/busines_logic_layer/TeachingLoadController.dart';

class TeachingLoadScreen extends GetView<TeachingLoadController> {
  const TeachingLoadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TeachingLoadController());

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Obx(
        () => controller.isLoading.value
            ? const SizedBox()
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // زر قفل النصاب
                  FloatingActionButton.extended(
                    heroTag: "lock_btn",
                    onPressed: () => _showLockConfirmDialog(context),
                    label: const Text(
                      "قفل النصاب",
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: const Icon(Icons.lock_outline, color: Colors.white),
                    backgroundColor: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  // زر تحميل PDF
                  FloatingActionButton.extended(
                    heroTag: "pdf_btn",
                    onPressed: () => _generatePdf(context),
                    label: const Text("تحميل ملف PDF"),
                    icon: const Icon(Icons.download),
                  ),
                ],
              ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.report.value == null) {
            return const Center(child: Text("لا توجد بيانات متاحة حالياً"));
          }

          final report = controller.report.value!;

          return RefreshIndicator(
            onRefresh: () async {
              await controller.fetchData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderTitle(),
                  const SizedBox(height: 15),
                  _buildFilterSection(),
                  const SizedBox(height: 15),
                  _buildInfoSection(report),
                  const SizedBox(height: 20),
                  _buildTeachingTable(report.confirmedLectures),
                  const SizedBox(height: 25),
                  _buildExamTable(report.confirmedExams),
                  const SizedBox(height: 25),
                  // 🔥 إضافة جدول المشاريع في الواجهة
                  _buildProjectsTable(report.confirmedProjects),
                  const SizedBox(height: 25),
                  _buildHRSection(),
                  const SizedBox(height: 20),
                  _buildSignaturesSection(report),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ويدجت الفلترة لاختيار الشهر والسنة
  Widget _buildFilterSection() {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!, width: 0.8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          spacing: 30,
          children: [
            // قائمة السنة
            Obx(() {
              if (controller.isLoadingYears.value) {
                return const SizedBox(
                  height: 50,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return _buildFilterDropdown<String>(
                label: "السنة الأكاديمية",
                value: controller.selectedYear.value,
                items: controller.availableYears,
                onChanged: (val) {
                  if (val != null) {
                    controller.selectedYear.value = val;
                    controller.fetchData();
                  }
                },
              );
            }),

            // قائمة الشهر (مع خيار "الفصل كامل")
            _buildFilterDropdown<int?>(
              label: "الفترة",
              value: controller.selectedMonth.value,
              items: [null, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
              itemLabel: (val) => val == null ? "الفصل كامل" : "شهر $val",
              onChanged: (val) {
                controller.selectedMonth.value = val;
                controller.fetchData();
              },
            ),
          ],
        ),
      ),
    );
  }

  // التوليد المتوافق مع الـ PDF يحافظ على البيانات المفلترة الحالية
  Future<void> _generatePdf(BuildContext context) async {
    try {
      final report = controller.report.value!;
      final pdf = pw.Document();

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
            // 🔥 إضافة جدول المشاريع في ملف الـ PDF
            _buildPdfProjectsTable(report.confirmedProjects),
            pw.SizedBox(height: 25),
            _buildPdfHRSection(),
            pw.SizedBox(height: 20),
            _buildPdfSignaturesSection(report),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
        name:
            'سجل_نصاب_${report.instructorName}_${controller.selectedMonth.value}_${controller.selectedYear.value}.pdf',
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

  Widget _buildTeachingTable(List<LectureModel> lectures) {
    return Table(
      border: TableBorder.all(color: Colors.black, width: 0.8),
      columnWidths: const {
        0: FixedColumnWidth(30),
        1: FlexColumnWidth(3),
        2: FixedColumnWidth(50),
        3: FixedColumnWidth(50),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[300]),
          children: [
            _tableHeader("م"),
            _tableHeader("المقررات"),
            _tableHeader("المطلوب"),
            _tableHeader("المنجز"),
          ],
        ),
        ...lectures.asMap().entries.map((e) {
          final l = e.value;
          List<String> stats = l.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return TableRow(
            children: [
              _tableCell((e.key + 1).toString()),
              _tableCell(l.subject, align: TextAlign.right),
              _tableCell(total),
              _tableCell(done, weight: FontWeight.bold),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildExamTable(List<ExamModel> exams) {
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

  // 🔥 ويدجت جدول المشاريع الجديد في التطبيق
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
        0: const pw.FixedColumnWidth(25),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FixedColumnWidth(40),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _pdfTableHeader("م"),
            _pdfTableHeader("المقررات"),
            _pdfTableHeader("المطلوب"),
            _pdfTableHeader("المنجز"),
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

  // 🔥 ويدجت جدول المشاريع الجديد في ملف الـ PDF
  pw.Widget _buildPdfProjectsTable(List<LectureModel> projects) {
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
            color: PdfColor.fromInt(
              0xFFE8F5E9,
            ), // اللون الأخضر للمشاريع متوافق مع الـ PDF
          ),
          children: [
            _pdfTableHeader("م"),
            _pdfTableHeader("متابعة مشاريع التخرج"),
            _pdfTableHeader("المطلوب"),
            _pdfTableHeader("المنجز"),
          ],
        ),
        ...projects.asMap().entries.map((e) {
          final project = e.value;
          List<String> stats = project.time.split('-');
          String done = stats.isNotEmpty ? stats[0].trim() : "0";
          String total = stats.length > 1 ? stats[1].trim() : "0";

          return pw.TableRow(
            children: [
              _pdfTableCell((e.key + 1).toString()),
              _pdfTableCell(project.subject, align: pw.TextAlign.right),
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

  void _showLockConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد قفل النصاب"),
        content: Text(
          "هل أنت متأكد من قفل نصاب شهر ${controller.selectedMonth.value} لعام ${controller.selectedYear.value}؟ لا يمكن التراجع بعد القفل.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              if (controller.selectedMonth.value == null) {
                Get.snackbar(
                  "تنبيه",
                  "يرجى اختيار شهر محدد أولاً لقفل النصاب، لا يمكن قفل الفصل كامل دفعة واحدة.",
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                );
                return;
              }

              Navigator.pop(context);

              controller.lockTeachingLoad(
                id: box.read('user_id') ?? 0,
                month: controller.selectedMonth.value!,
              );
            },
            child: const Text(
              "تأكيد القفل",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
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
}
