from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, Faculty, Department, Instructor, Admin, Employee, Room, Course, Semester, AcademicYear, CourseAllocation, Profile, Lectures, TeachingLoad, ExamDuty
from django.contrib.admin.exceptions import NotRegistered

# 1. إعدادات جدول المستخدمين (User) - الترتيب اللي طلبتيه
from django import forms
from django.contrib.auth.forms import UserCreationForm, UserChangeForm
from django.contrib.auth.forms import UserCreationForm
from django import forms
# هاد الفورم مشان واجهة "إضافة يوزر جديد"
from django.contrib.auth.forms import UserCreationForm

# 1. منعرف فورم التسجيل وبنضيف عليه حقولك
from django.contrib.auth.forms import UserCreationForm
from django import forms

# 1. منعمل فورم خاص بياخد صفات فورم التسجيل تبع جنغو
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User # تأكدي إنك مستوردة مودل اليوزر تبعك

class UserAdmin(BaseUserAdmin):
    # 1. شو بدنا يظهر بالجدول برة (متل ما هو ما غيرنا شي)
    list_display = ('username', 'email', 'first_name', 'last_name', 'phone_number', 'role', 'is_staff')

    # 2. واجهة إضافة يوزر جديد (تركتها متل ما هي مشان الباسورد والتعريف)
    add_fieldsets = BaseUserAdmin.add_fieldsets + (
        (None, {
            'fields': ('first_name', 'last_name', 'phone_number', 'email', 'role'),
        }),
    )

    # 3. واجهة التعديل (هون التعديل السحري)
    # بدل ما نجمع ( + )، رح نعرف الأقسام اللي بتهمنا بس
    fieldsets = (
        ("المعلومات الأساسية", {
            'fields': ('username', 'password')
        }),
        ("المعلومات الشخصية", {
            'fields': ('first_name', 'last_name', 'email', 'phone_number', 'role')
        }),
        # هون شلنا الـ Permissions والـ Important dates تماماً
    )

# تسجيل المودل (القسم التحتاني بضل متل ما هو)
try:
    admin.site.unregister(User)
except admin.sites.NotRegistered:
    pass

admin.site.register(User, UserAdmin)

from django.contrib import admin
from .models import Course, AcademicYear, CourseAllocation

# 1. جدول المواد (مثل الصورة الأخيرة تماماً)
@admin.register(Course)
class CourseAdmin(admin.ModelAdmin):
    # list_display هي اللي بتعمل الأعمدة اللي بالصورة
    list_display = ('course_code', 'course_name', 'credit_hours')
    # إضافة ميزة البحث باسم المادة أو الكود
    search_fields = ('course_name', 'course_code')
    # ترتيب البيانات حسب الكود
    ordering = ('course_code',)

# 2. جدول السنة الدراسية
# @admin.register(AcademicYear)
# class AcademicYearAdmin(admin.ModelAdmin):
#     list_display = ('start_year', 'end_year', 'is_active')
#     list_editable = ('is_active',) # بتقدري تعدلي حالة "نشط" مباشرة من الجدول

# 3. جدول توزيع المواد (Course Allocation)
@admin.register(CourseAllocation)
class CourseAllocationAdmin(admin.ModelAdmin):
    # هون منعرض بيانات الربط بشكل واضح بدل كلمة Object
    list_display = ('course_code', 'instructor', 'semester', 'room')
    # إضافة فلاتر على الجنب للبحث السريع
    list_filter = ('semester', 'instructor')

# 2. تسجيل باقي الجداول (لحتى يرجعوا يظهروا عندك في لوحة التحكم)
admin.site.register(Faculty)
admin.site.register(Admin)
admin.site.register(Room)
admin.site.register(Semester)
admin.site.register(Profile)
admin.site.register(Lectures)
admin.site.register(TeachingLoad)
admin.site.register(ExamDuty)

from django.contrib import admin
from .models import Department, Employee, Instructor, User, Faculty

# 1. جدول الأقسام (Department) - يعرض القسم والكلية التابع لها
@admin.register(Department)
class DepartmentAdmin(admin.ModelAdmin):
    list_display = ('name', 'get_faculty') # جلب الكلية عبر دالة
    search_fields = ('name', 'faculty__name')
    list_filter = ('faculty',)

    def get_faculty(self, obj):
        return obj.faculty.name if obj.faculty else "-"
    get_faculty.short_description = 'الكلية' # اسم العمود بالعربي


# 2. جدول الموظفين (Employee) - يعرض اسم الموظف وكليته
@admin.register(Employee)
class EmployeeAdmin(admin.ModelAdmin):
    list_display = ('get_full_name', 'get_faculty', 'get_phone')
    search_fields = ('user__first_name', 'user__last_name', 'faculty__name')

    def get_full_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"
    get_full_name.short_description = 'اسم الموظف'

    def get_faculty(self, obj):
        return obj.faculty.name if obj.faculty else "-"
    get_faculty.short_description = 'الكلية'

    def get_phone(self, obj):
        return obj.user.phone_number
    get_phone.short_description = 'رقم الهاتف'


# 3. جدول المدرسين (Instructor) - يعرض كامل المعلومات
@admin.register(Instructor)
class InstructorAdmin(admin.ModelAdmin):
    list_display = ('get_full_name', 'academic_rank', 'get_faculty' ,'get_department', 'get_phone')
    list_filter = ('academic_rank', 'department')
    search_fields = ('user__first_name', 'user__last_name', 'department__name')

    def get_full_name(self, obj):
        return f"{obj.user.first_name} {obj.user.last_name}"
    get_full_name.short_description = 'اسم المدرس'

    def get_faculty(self, obj):
        return f"{obj.department.faculty.name}" if obj.department and obj.department.faculty else "-"
    get_faculty.short_description = 'الكلية'

    def get_department(self, obj):
        return obj.department.name if obj.department else "-"
    get_department.short_description = 'القسم'

    def get_phone(self, obj):
        return obj.user.phone_number
    get_phone.short_description = 'رقم الهاتف'


from django.contrib import admin
from .models import AcademicYear, AcademicHoliday

@admin.register(AcademicYear)
class AcademicYearAdmin(admin.ModelAdmin):
    list_display = ('start_year', 'end_year', 'is_active')

@admin.register(AcademicHoliday)
class AcademicHolidayAdmin(admin.ModelAdmin):
    # نغير academic_year إلى semester لأن هذا هو الحقل الموجود حالياً في الموديل
    list_display = ('holiday_id', 'holiday_date', 'semester') 
    list_filter = ('semester',) # الفلترة ستكون حسب الفصل الدراسي