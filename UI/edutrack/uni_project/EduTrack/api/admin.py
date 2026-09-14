from django.contrib import admin
from .models import AcademicYear, Course, Instructor, Notification, Users, Department, CourseAllocation, ExamDuty, Faculty, Room, Semester, TeachingLoad
admin.site.register(AcademicYear)
admin.site.register(Course)
admin.site.register(Instructor)
admin.site.register(Users)
admin.site.register(Department)
admin.site.register(CourseAllocation)
admin.site.register(ExamDuty)
admin.site.register(Faculty)
admin.site.register(Notification)
admin.site.register(Room)
admin.site.register(Semester)
admin.site.register(TeachingLoad)