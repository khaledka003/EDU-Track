
from django.db import models

class AcademicYear(models.Model):
    academic_year_id = models.IntegerField(primary_key=True)
    start_year = models.IntegerField(blank=True, null=True)
    end_year = models.IntegerField(blank=True, null=True)
    is_active = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Academic_Year'

    def __str__(self):
        return f"{self.start_year}-{self.end_year}"


class Course(models.Model):
    course_id = models.IntegerField(primary_key=True)
    course_name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    credit_hours = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Course'

    def __str__(self):
        return self.course_name


class CourseAllocation(models.Model):
    course_allocation_id = models.IntegerField(primary_key=True)
    course = models.ForeignKey(Course, models.DO_NOTHING, blank=True, null=True)
    instructor = models.ForeignKey('Instructor', models.DO_NOTHING, blank=True, null=True)
    semester = models.ForeignKey('Semester', models.DO_NOTHING, blank=True, null=True)
    room = models.ForeignKey('Room', models.DO_NOTHING, blank=True, null=True)
    teaching_load = models.ForeignKey('TeachingLoad', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Course_Allocation'


class Department(models.Model):
    department_id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    faculty = models.ForeignKey('Faculty', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Department'

    def __str__(self):
        return self.name


class ExamDuty(models.Model):
    exam_duty_id = models.IntegerField(primary_key=True)
    exam_date = models.DateField(blank=True, null=True)
    room = models.ForeignKey('Room', models.DO_NOTHING, blank=True, null=True)
    teaching_load = models.ForeignKey('TeachingLoad', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Exam_Duty'


class Faculty(models.Model):
    faculty_id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')

    class Meta:
        managed = False
        db_table = 'Faculty'

    def __str__(self):
        return self.name


class Instructor(models.Model):
    instructor_id = models.IntegerField(primary_key=True)
    username = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    department = models.ForeignKey(Department, models.DO_NOTHING, blank=True, null=True)
    user = models.OneToOneField('Users', models.DO_NOTHING, blank=True, null=True)
    academic_rank = models.CharField(max_length=100, db_collation='Arabic_CI_AS', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Instructor'

    def __str__(self):
        return self.username


class Notification(models.Model):
    notification_id = models.IntegerField(primary_key=True)
    user = models.ForeignKey('Users', models.DO_NOTHING, blank=True, null=True)
    exam_duty = models.ForeignKey(ExamDuty, models.DO_NOTHING, blank=True, null=True)
    message = models.CharField(max_length=500, db_collation='Arabic_CI_AS', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Notification'


class Room(models.Model):
    room_id = models.IntegerField(primary_key=True)
    room_name = models.CharField(max_length=255, db_collation='Arabic_CI_AS', blank=True, null=True)
    capacity = models.IntegerField(blank=True, null=True)
    location = models.CharField(max_length=255, db_collation='Arabic_CI_AS', blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Room'
    
    def __str__(self):
        return self.room_name 


class Semester(models.Model):
    semester_id = models.IntegerField(primary_key=True)
    date_start = models.DateField(blank=True, null=True)
    date_end = models.DateField(blank=True, null=True)
    date_holiday = models.DateField(blank=True, null=True)
    academic_year = models.ForeignKey(AcademicYear, models.DO_NOTHING, blank=True, null=True)
    semester_name = models.CharField(max_length=100, db_collation='Arabic_CI_AS', blank=True, null=True)  # Field name made lowercase.

    class Meta:
        managed = False
        db_table = 'Semester'

    def __str__(self):
        return self.semester_name
    


class TeachingLoad(models.Model):
    teaching_load_id = models.IntegerField(primary_key=True)
    attendance = models.BooleanField(blank=True, null=True)
    status = models.CharField(max_length=50, db_collation='Arabic_CI_AS', blank=True, null=True)
    course_allocation = models.OneToOneField(CourseAllocation, models.DO_NOTHING, blank=True, null=True)
    lecture_time = models.TimeField(blank=True, null=True)
    lecture_type = models.CharField(max_length=50, db_collation='Arabic_CI_AS', blank=True, null=True)
    room_id = models.IntegerField(blank=True, null=True)
    lecture_date = models.DateField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Teaching_Load'


class Users(models.Model):
    user_id = models.IntegerField(primary_key=True)
    email = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    role = models.CharField(max_length=50, db_collation='Arabic_CI_AS', blank=True, null=True)
    is_active = models.BooleanField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'Users'

    








class AuthGroup(models.Model):
    name = models.CharField(unique=True, max_length=150, db_collation='Arabic_CI_AS')

    class Meta:
        managed = False
        db_table = 'auth_group'


class AuthGroupPermissions(models.Model):
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)
    permission = models.ForeignKey('AuthPermission', models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_group_permissions'
        unique_together = (('group', 'permission'),)


class AuthPermission(models.Model):
    name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING)
    codename = models.CharField(max_length=100, db_collation='Arabic_CI_AS')

    class Meta:
        managed = False
        db_table = 'auth_permission'
        unique_together = (('content_type', 'codename'),)


class AuthUser(models.Model):
    password = models.CharField(max_length=128, db_collation='Arabic_CI_AS')
    last_login = models.DateTimeField(blank=True, null=True)
    is_superuser = models.BooleanField()
    username = models.CharField(unique=True, max_length=150, db_collation='Arabic_CI_AS')
    first_name = models.CharField(max_length=150, db_collation='Arabic_CI_AS')
    last_name = models.CharField(max_length=150, db_collation='Arabic_CI_AS')
    email = models.CharField(max_length=254, db_collation='Arabic_CI_AS')
    is_staff = models.BooleanField()
    is_active = models.BooleanField()
    date_joined = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'auth_user'


class AuthUserGroups(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    group = models.ForeignKey(AuthGroup, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_groups'
        unique_together = (('user', 'group'),)


class AuthUserUserPermissions(models.Model):
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)
    permission = models.ForeignKey(AuthPermission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'auth_user_user_permissions'
        unique_together = (('user', 'permission'),)


class DjangoAdminLog(models.Model):
    action_time = models.DateTimeField()
    object_id = models.TextField(db_collation='Arabic_CI_AS', blank=True, null=True)
    object_repr = models.CharField(max_length=200, db_collation='Arabic_CI_AS')
    action_flag = models.SmallIntegerField()
    change_message = models.TextField(db_collation='Arabic_CI_AS')
    content_type = models.ForeignKey('DjangoContentType', models.DO_NOTHING, blank=True, null=True)
    user = models.ForeignKey(AuthUser, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'django_admin_log'


class DjangoContentType(models.Model):
    app_label = models.CharField(max_length=100, db_collation='Arabic_CI_AS')
    model = models.CharField(max_length=100, db_collation='Arabic_CI_AS')

    class Meta:
        managed = False
        db_table = 'django_content_type'
        unique_together = (('app_label', 'model'),)


class DjangoMigrations(models.Model):
    app = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    name = models.CharField(max_length=255, db_collation='Arabic_CI_AS')
    applied = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_migrations'


class DjangoSession(models.Model):
    session_key = models.CharField(primary_key=True, max_length=40, db_collation='Arabic_CI_AS')
    session_data = models.TextField(db_collation='Arabic_CI_AS')
    expire_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'django_session'
