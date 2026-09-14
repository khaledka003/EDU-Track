from gettext import translation

from .models import AcademicHoliday

def is_holiday(check_date, academic_year_id):
    """
    تعيد True إذا كان التاريخ المعطى مسجلاً كعطلة لهذه السنة
    """
    return AcademicHoliday.objects.filter(
        academic_year_id=academic_year_id, 
        holiday_date=check_date
    ).exists()


from django.utils.timezone import now
from .models import Semester, Lectures, CourseAllocation

def check_and_close_semester():
    # 1. البحث عن الفصل النشط الذي انتهت مدته
    today = now().date()
    expired_semester = Semester.objects.filter(is_active=True, end_date__lt=today).first()

    if expired_semester:
        try:
            with translation.atomic():
                # 2. فك ارتباط المحاضرات (حذف سجلات الجدول الأسبوعي فقط)
                # هذا يفرغ جدول المدرسين للأسبوع القادم
                Lectures.objects.filter(course_allocation__semester=expired_semester).delete()
                
                # 3. إيقاف تفعيل الفصل
                expired_semester.is_active = False
                expired_semester.save()
                
                # ملاحظة: لن نحذف CourseAllocation ولا TeachingLoad 
                # لأننا سنحتاجهما في "تقارير النصاب التدريسي" التاريخية
                
                print(f"تم إغلاق الفصل {expired_semester.semester_name} تلقائياً.")
        except Exception as e:
            print(f"خطأ أثناء الإغلاق التلقائي: {str(e)}")