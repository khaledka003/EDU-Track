# This is an auto-generated Django model module.
# You'll have to do the following manually to clean this up:
#   * Rearrange models' order
#   * Make sure each model has one field with primary_key=True
#   * Make sure each ForeignKey and OneToOneField has `on_delete` set to the desired behavior
#   * Remove `managed = False` lines if you wish to allow Django to create, modify, and delete the table
# Feel free to rename the models, but don't rename db_table values or field names.
from django.db import models
from django.contrib.auth.models import AbstractUser 
from django.db import models
from EduTrack import settings

from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    # 1. منعرف الخيارات المتاحة للقائمة المنسدلة
    ROLE_CHOICES = [
        ('admin', 'Admin'),
        ('instructor', 'Instructor'),
        ('employee', 'Employee'),
    ]

    phone_number = models.CharField(max_length=15, blank=True, null=True ,unique=True) 
    
    # 2. منربط الـ choices بالحقل
    role = models.CharField(
        max_length=20, 
        choices=ROLE_CHOICES, 
        default='admin' # أو أي رول بدك ياها تكون افتراضية
    )

    def save(self, *args, **kwargs):
        is_new = self.pk is None
        super().save(*args, **kwargs)

        if is_new:
            # هون الـ self.role رح تكون حصراً وحدة من التلاتة اللي فوق
            if self.role == 'admin':
                Admin.objects.get_or_create(user=self)
            elif self.role == 'instructor':
                Instructor.objects.get_or_create(user=self)
            elif self.role == 'employee':
                Employee.objects.get_or_create(user=self)




class AcademicYear(models.Model):
    academic_year_id = models.AutoField(primary_key=True)
    start_year = models.IntegerField()
    end_year = models.IntegerField()
    is_active = models.BooleanField()
    
    class Meta:
        managed = True
        db_table = 'ACADEMIC_YEAR'
    def __str__(self):
        return f"{self.start_year}-{self.end_year}"


    
    
    
    

class Admin(models.Model):
    
    admin_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)

    class Meta:
        managed = True
        db_table = 'ADMIN'

    def __str__(self):
        return self.user.username

class Course(models.Model):
    course_code = models.CharField(primary_key=True, max_length=50, db_collation='Arabic_CI_AS')
    course_name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    credit_hours = models.IntegerField(default=3) # الحقل الجديد
    department = models.ForeignKey('Department', on_delete=models.CASCADE, related_name='courses')
    class Meta:
        managed = True
        db_table = 'COURSE'
    
    def __str__(self):
        return f"{self.course_name} | {self.course_code}"


class CourseAllocation(models.Model):
    course_allocation_id = models.AutoField(primary_key=True)
    course_code = models.ForeignKey(Course, models.DO_NOTHING, db_column='course_code')
    instructor = models.ForeignKey('Instructor', models.DO_NOTHING)
    semester = models.ForeignKey('Semester', models.DO_NOTHING)
    room = models.ForeignKey('Room', models.DO_NOTHING)

    class Meta:
        managed = True
        db_table = 'COURSE_ALLOCATION'
    def __str__(self):
        return f"{self.course_code.course_name} - {self.instructor.user.username}"


class Department(models.Model):
    department_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    faculty = models.ForeignKey('Faculty', models.DO_NOTHING)

    class Meta:
        managed = True
        db_table = 'DEPARTMENT'
    
    def __str__(self):
     return f"{self.name} ({self.faculty.name})"


class Employee(models.Model):
    employee_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    faculty = models.ForeignKey('FACULTY', on_delete=models.SET_NULL, null=True, blank=True)

    class Meta:
        managed = True
        db_table = 'EMPLOYEE'

    def __str__(self):
        return self.user.username


class ExamDuty(models.Model):
    exam_duty_id = models.AutoField(primary_key=True)
    teaching_load = models.ForeignKey('TeachingLoad', models.DO_NOTHING, null=True, blank=True)
    instructor = models.ForeignKey('Instructor', models.DO_NOTHING, null=True, blank=True)
    course_name = models.ForeignKey('Course', on_delete=models.CASCADE, null=True)
    
    # 🌟 الحقول الجديدة واللازمة للفترات والأسماء:
    exam_name = models.CharField(max_length=100, default="امتحان") # هون بيكتب: تيست 1، تيست 2، فاينل...
    exam_date = models.DateField()        # هاد بيمثل تاريخ بدء الامتحان/الفترة
    exam_end_date = models.DateField(null=True, blank=True) # هاد بيمثل تاريخ انتهاء الامتحان/الفترة

    # حقول الغرف والوقت بنخليها تسمح بـ null (blank=True, null=True) 
    # عشان لما الموظف يضيف "فترة امتحانات عامة للجامعة"، مو شرط يحدد قاعة أو ساعة معينة
    room = models.ForeignKey('Room', models.DO_NOTHING, null=True, blank=True)
    start_time = models.TimeField(null=True, blank=True) 
    end_time = models.TimeField(null=True, blank=True)   

    class Meta:
        managed = True
        db_table = 'EXAM_DUTY'

    def __str__(self):
        return f"{self.exam_name} ({self.exam_date} - {self.exam_end_date})"


class Faculty(models.Model):
    faculty_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')

    class Meta:
        managed = True
        db_table = 'FACULTY'

    def __str__(self):
     return self.name


class Instructor(models.Model):
    instructor_id = models.AutoField(primary_key=True)
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    department = models.ForeignKey('DEPARTMENT', on_delete=models.SET_NULL, null=True, blank=True)
    academic_rank = models.CharField(max_length=100, db_collation='Arabic_CI_AS')

    class Meta:
        managed = True
        db_table = 'INSTRUCTOR'
    
    def __str__(self):
        return self.user.username


class Lectures(models.Model):
    lecture_id = models.AutoField(primary_key=True)
    course_allocation = models.ForeignKey(CourseAllocation, models.DO_NOTHING)
    room = models.ForeignKey('Room', models.DO_NOTHING)
    day_of_week = models.CharField(max_length=20, db_collation='Arabic_CI_AS')
    start_time = models.TimeField()
    end_time = models.TimeField()
    lecture_type = models.CharField(max_length=50, db_collation='Arabic_CI_AS')
    class Meta:
        managed = True
        db_table = 'LECTURES'
    def __str__(self):
     return f"{self.course_allocation.course_code.course_name} - {self.day_of_week}"


class Profile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    role = models.CharField(max_length=50, db_collation='Arabic_CI_AS')

    class Meta:
        managed = True
        db_table = 'PROFILE'



class Room(models.Model):
    room_id = models.AutoField(primary_key=True)
    room_name = models.CharField(max_length=100, db_collation='Arabic_CI_AS')
    capacity = models.IntegerField(default=40) # الحقل الجديد
    location = models.CharField(max_length=255, null=True, blank=True) # الحقل الجديد

    class Meta:
        managed = True
        db_table = 'ROOM'

    def __str__(self):
     return self.room_name 
    

class Semester(models.Model):
    semester_id = models.AutoField(primary_key=True)
    academic_year = models.ForeignKey(AcademicYear, on_delete=models.CASCADE, null=True, blank=True)
    semester_name = models.CharField(max_length=50) # "الفصل الأول"، "الثاني"، "الصيفي"
    start_date = models.DateField(null=True, blank=True)
    end_date = models.DateField(null=True, blank=True)
    coordination_start_date = models.DateField()
    is_active = models.BooleanField(default=True)

    class Meta:
        db_table = 'ACADEMIC_SEMESTER'

class AcademicHoliday(models.Model):
    holiday_id = models.AutoField(primary_key=True)
    semester = models.ForeignKey(Semester, on_delete=models.CASCADE, null=True, blank=True)
    holiday_date = models.DateField()
    description = models.CharField(max_length=255, null=True, blank=True)

class TeachingLoad(models.Model):
    teaching_load_id = models.AutoField(primary_key=True)
    course_allocation = models.ForeignKey(CourseAllocation, models.DO_NOTHING)
    attendance = models.BooleanField()
    lecture_date = models.DateField()
    is_finished = models.BooleanField(default=False)

    is_compensatory = models.BooleanField(default=False) # True إذا كانت تعويضية
    room = models.ForeignKey('Room', models.DO_NOTHING, null=True, blank=True)
    start_time = models.TimeField(null=True, blank=True)
    end_time = models.TimeField(null=True, blank=True)

    class Meta:
        managed = True
        db_table = 'TEACHING_LOAD'


class Notification(models.Model):
    NOTIFICATION_TYPES = [
        ('REMINDER', 'تذكير'),
        ('INFO', 'معلومة'),
        ('WARNING', 'تنبيه'),
    ]

    notification_id = models.AutoField(primary_key=True)
    
    # 🌟 الربط الذهبي والمضمون مع كلاس اليوزر الخاص بكِ:
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, 
        on_delete=models.CASCADE, 
        related_name='notifications'
    )
    
    title = models.CharField(max_length=150)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES, default='INFO')
    is_read = models.BooleanField(default=False)  # عشان الـ Flutter يتحكم بظهور النقطة الحمراء
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        managed = True
        db_table = 'NOTIFICATION'
        ordering = ['-created_at']  # ترتيب تنازلي: الإشعارات الأحدث تظهر أولاً

    def __str__(self):
        return f"{self.title} - {self.user.username}"


class GraduationProject(models.Model):
    PROJECT_TYPE_CHOICES = [
        ('term_project', 'فصلي'),
        ('grad_1', 'تخرج 1'),
        ('grad_2', 'تخرج 2'),
    ]

    # خيارات أيام الأسبوع لفحص التضارب
    DAYS_OF_WEEK = [
        (1, 'الإثنين'),
        (2, 'الثلاثاء'),
        (3, 'الأربعاء'),
        (4, 'الخميس'),
        (5, 'الجمعة'),
        (6, 'السبت'),
        (7, 'الأحد'),
    ]

    project_id = models.AutoField(primary_key=True)
    project_title = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    semester = models.ForeignKey('Semester', on_delete=models.CASCADE, related_name='projects')
    
    project_type = models.CharField(
        max_length=20, 
        choices=PROJECT_TYPE_CHOICES, 
        default='grad_1'
    )
    
    faculty = models.ForeignKey('Faculty', on_delete=models.CASCADE, related_name='projects')
    department = models.ForeignKey('Department', on_delete=models.CASCADE, related_name='projects')
    instructor = models.ForeignKey('Instructor', on_delete=models.DO_NOTHING, related_name='supervised_projects')
    
    student_names = models.TextField(db_collation='Arabic_CI_AS', help_text="أسماء الطلاب المشاركين")
    
    theory_hours = models.FloatField(default=0.0)
    practical_hours = models.FloatField(default=0.0)
    created_at = models.DateField(auto_now_add=True)

    # 🎯 الحقول الجديدة المضافة لفحص التضارب والـ Check الأسبوعي:
    assigned_day = models.IntegerField(choices=DAYS_OF_WEEK, null=True, blank=True, help_text="اليوم المعتمد للمتابعة خلال الأسبوع")
    start_time = models.TimeField(null=True, blank=True, help_text="وقت بدء المتابعة المعتمد")
    end_time = models.TimeField(null=True, blank=True, help_text="وقت انتهاء المتابعة المعتمد")

    class Meta:
        managed = True
        db_table = 'GRADUATION_PROJECT'
        
    def __str__(self):
        return f"{self.project_title} ({self.get_project_type_display()}) - {self.instructor.user.username}"

class ProjectSession(models.Model):
    session_id = models.AutoField(primary_key=True)
    project = models.ForeignKey(GraduationProject, models.CASCADE, related_name='sessions')
    
    # 🌟 الربط السحري بالنصاب: بنخليه يسمح بـ null و blank كرمال ينربط ديناميكياً عند التثبيت
    teaching_load = models.ForeignKey(
        'TeachingLoad', 
        on_delete=models.SET_NULL, 
        null=True, 
        blank=True, 
        related_name='project_sessions'
    )
    
    session_date = models.DateField()  # التاريخ الفعلي للجلسة
    start_time = models.TimeField()    # وقت البدء
    end_time = models.TimeField()      # وقت الانتهاء
    
    class Meta:
        managed = True
        db_table = 'PROJECT_SESSION'




