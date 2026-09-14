# 1. مكتبات بايثون الأساسية (Python Standard Library)
import os
from datetime import date, datetime, time as dt_time, timedelta
import calendar
from time import time 
# 2. مكتبات دجانغو الأساسية (Django Core)
from django.db import connection, transaction
from django.db.models import Case, When, Value, IntegerField
from django.shortcuts import render, get_object_or_404
from django.conf import settings
from django.utils.timezone import now
from django.contrib.auth import authenticate
from django.contrib.auth.hashers import make_password
from django.db.models import Q

# 3. مكتبات Django Rest Framework (DRF)
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.authtoken.models import Token

# 4. موديلات المشروع (Local App Models)
from .models import (
    AcademicHoliday, GraduationProject, Notification, ProjectSession, User, Instructor, Profile, Employee, 
    Faculty, Department, 
    Course, AcademicYear, Semester, 
    Room, CourseAllocation, Lectures, 
    ExamDuty, TeachingLoad
)
# بدلاً من استيراد time من المكتبة العامة، استورديها من datetime فقط

@api_view(['POST'])
@permission_classes([AllowAny])
def login_api(request):
    auto_close_expired_semesters()
    phone = request.data.get('phone_number')
    password = request.data.get('password')
    
    try:
        user_obj = User.objects.get(phone_number=phone)
        username = user_obj.username
    except User.DoesNotExist:
        return Response({'status': 'error', 'message': 'رقم الهاتف غير مسجل'}, status=status.HTTP_404_NOT_FOUND)

    user = authenticate(username=username, password=password)
    
    if user is not None and user.is_active:
        token, created = Token.objects.get_or_create(user=user)
        instructor_id = None
        if user.role == 'instructor':
            instructor_id = getattr(user.instructor, 'instructor_id', user.instructor.pk if hasattr(user, 'instructor') else None)

        return Response({
            'status': 'success',
            'token': token.key,
            'user_id': user.id,
            'role': user.role,
            'instructor_id': instructor_id, 
            'faculty_id': getattr(user.employee.faculty, 'faculty_id', None) if user.role == 'employee' else None
        })
    else:
        return Response({'status': 'error', 'message': 'كلمة المرور غلط'}, status=status.HTTP_401_UNAUTHORIZED)
    

@api_view(['POST'])
@permission_classes([AllowAny])
def register_instructor_api(request):
    data = request.data
    try:
        with transaction.atomic():
            # 1. جلب البيانات الأساسية
            email_val = data.get('email')
            password = data.get('password')
            phone = data.get('phone_number')
            first_name = (data.get('first_name') or '').strip()
            last_name = (data.get('last_name') or '').strip()
            rank = data.get('academic_rank', 'مدرس')
            dept_name = data.get('department_name', '').strip()

            if not email_val or not password or not phone:
                return Response({"status": "error", "message": "الايميل، كلمة السر، ورقم الهاتف مطلوبين"}, status=400)

            # 2. التأكد من عدم تكرار البيانات (Email أو Phone)
            if User.objects.filter(email=email_val).exists():
                return Response({"status": "error", "message": "هذا الايميل مسجل مسبقاً"}, status=400)
            if User.objects.filter(phone_number=phone).exists():
                return Response({"status": "error", "message": "رقم الهاتف هذا مسجل مسبقاً"}, status=400)

            # 3. إنشاء Username فريد (تلقائي)
            username = f"{first_name}_{last_name}" if first_name else email_val.split('@')[0]
            # التأكد من عدم تكرار اليوزرنيم
            final_username = username
            counter = 1
            while User.objects.filter(username=final_username).exists():
                final_username = f"{username}{counter}"
                counter += 1

            # 4. إنشاء المستخدم 
            user = User.objects.create_user(
                username=final_username,
                email=email_val,
                password=password,
                phone_number=phone,
                first_name=first_name,
                last_name=last_name,
                role='instructor'
            )

            # 5. تحديث البيانات الإضافية للمدرس (القسم واللقب الأكاديمي)
            instructor_profile, created = Instructor.objects.get_or_create(user=user)
            instructor_profile.academic_rank = rank
            
            # جلب القسم
            dept = Department.objects.filter(name__icontains=dept_name).first()
            if dept:
                instructor_profile.department = dept
            
            instructor_profile.save()

            return Response({"status": "success", "message": "تم تسجيل المدرس بنجاح"}, status=201)

    except Exception as e:
        print(f"ERROR: {str(e)}") 
        return Response({"status": "error", "message": str(e)}, status=400)
    
@api_view(['POST'])
@permission_classes([AllowAny])
def register_employee_api(request):
    data = request.data
    try:
        with transaction.atomic():
            # 1. جلب البيانات الأساسية
            email_val = data.get('email')
            password = data.get('password')
            phone = data.get('phone_number')
            first_name = (data.get('first_name') or '').strip()
            last_name = (data.get('last_name') or '').strip()
            faculty_id = data.get('faculty_id') 

            if not email_val or not password or not phone:
                return Response({"status": "error", "message": "الايميل، كلمة السر، ورقم الهاتف مطلوبين"}, status=400)

            # 2. التأكد من عدم تكرار البيانات
            if User.objects.filter(email=email_val).exists():
                return Response({"status": "error", "message": "هذا الايميل مسجل مسبقاً"}, status=400)
            if User.objects.filter(phone_number=phone).exists():
                return Response({"status": "error", "message": "رقم الهاتف هذا مسجل مسبقاً"}, status=400)

            # 3. إنشاء Username فريد
            username_base = f"{first_name}_{last_name}" if first_name else email_val.split('@')[0]
            final_username = username_base
            counter = 1
            while User.objects.filter(username=final_username).exists():
                final_username = f"{username_base}{counter}"
                counter += 1

            # 4. إنشاء المستخدم برتبة موظف 
            user = User.objects.create_user(
                username=final_username,
                email=email_val,
                password=password,
                phone_number=phone,
                first_name=first_name,
                last_name=last_name,
                role='employee' 
            )

            # 5. تحديث بيانات الموظف (الكلية)
            employee_profile, created = Employee.objects.get_or_create(user=user)

            if faculty_id:
                try:
                    faculty = Faculty.objects.get(faculty_id=faculty_id)
                    employee_profile.faculty = faculty
                except Faculty.DoesNotExist:
                    pass 
            
            employee_profile.save()

            return Response({
                "status": "success", 
                "message": "تم تسجيل الموظف بنجاح",
                "username": final_username
            }, status=201)

    except Exception as e:
        return Response({"status": "error", "message": f"حدث خطأ: {str(e)}"}, status=400)

@api_view(['GET'])
@permission_classes([AllowAny]) 
def get_profile_data_api(request, user_id): 
    try:
        # 1. جلب اليوزر مع البروفايل تبعه دفعة واحدة (مشان السرعة)
        # منUSED select_related لمتابعة العلاقات (User -> Instructor -> Department -> Faculty)
        user = User.objects.select_related('instructor__department__faculty').filter(id=user_id).first()

        if not user:
            return Response({"status": "error", "message": "المستخدم غير موجود"}, status=404)

        # 2. استخراج بيانات المدرس إذا كان اليوزر مدرس
        instructor_profile = getattr(user, 'instructor', None)
        
        # 3. بناء الرد (Response)
        data = {
            "full_name": f"{user.first_name} {user.last_name}".strip(),
            "email": user.email,
            "mobile": user.phone_number if user.phone_number else "لا يوجد", # هلق صار يرجع الرقم الصح
            "academic_rank": instructor_profile.academic_rank if instructor_profile else "غير محدد",
            "specialization": instructor_profile.department.name if instructor_profile and instructor_profile.department else "غير محدد",
            "faculty": instructor_profile.department.faculty.name if instructor_profile and instructor_profile.department and instructor_profile.department.faculty else "غير محدد",
            "role": user.role # ضفتلك الرول كمان مشان الفرونت إند
        }
        
        return Response({"status": "success", "data": data})

    except Exception as e:
        return Response({"status": "error", "message": f"حدث خطأ: {str(e)}"}, status=500)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_all_faculties(request):
    try:
        # جلب كل الكليات
        faculties = Faculty.objects.all()
        
        # بناء القائمة مع تنظيف الأسماء من الفراغات الزائدة
        data = [
            {
                "id": f.faculty_id, 
                "name": f.name.strip()
            } 
            for f in faculties
        ]
        
        return Response({
            "status": "success", 
            "count": len(data), # إضافة عداد (اختياري) مفيد للزميل في Flutter
            "data": data
        }, status=200)
        
    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء جلب الكليات: {str(e)}"
        }, status=400)
    

@api_view(['GET'])
@permission_classes([AllowAny])
def get_departments_by_faculty(request, faculty_id):
    try:
        # التأكد من وجود الكلية
        if not Faculty.objects.filter(pk=faculty_id).exists():
            return Response({"status": "error", "message": "الكلية غير موجودة"}, status=404)

        depts = Department.objects.filter(faculty_id=faculty_id)
        
        # بناء القائمة (استخدمنا الأسماء التي يتوقعها الفلتر)
        data = [
            {
                "department_id": d.department_id, 
                "name": d.name.strip()
            } 
            for d in depts
        ]
        
        # هنا التعديل السحري: نرسل كل المسميات ليرتاح الفلتر
        return Response({
            "status": "success", 
            "departments": data, # هذا المفتاح يحتاجه الفلتر
            "data": data         # وهذا المفتاح احتياطي في حال كان الكود عندك يبحث عن data
        }, status=200)

    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=400)
    

@api_view(['GET'])
@permission_classes([AllowAny])
def get_all_instructors(request):
    try:
        # جلب المدرسين مع بيانات اليوزر والقسم والكلية بطلب واحد SQL
        instructors = Instructor.objects.select_related(
            'user', 
            'department', 
            'department__faculty'
        ).all()
        
        results = []
        for inst in instructors:
            # تأمين الكود: نتأكد إنو اليوزر موجود فعلاً لتجنب AttributeError
            if inst.user:
                results.append({
                    "user_id": inst.user.id,  
                    "first_name": inst.user.first_name.strip() if inst.user.first_name else "",
                    "last_name": inst.user.last_name.strip() if inst.user.last_name else "",
                    "email": inst.user.email if inst.user.email else "",
                    "phone_number": inst.user.phone_number if inst.user.phone_number else "", # ضفتلك الرقم كمان
                    "faculty_name": inst.department.faculty.name.strip() if inst.department and inst.department.faculty else "لم يحدد",
                    "department_name": inst.department.name.strip() if inst.department else "لم يحدد",
                    "academic_rank": inst.academic_rank.strip() if inst.academic_rank else "مدرس",
                })
            
        return Response({
            "status": "success",
            "count": len(results),
            "data": results
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        print(f"الخطأ في الجانغو: {str(e)}")
        # يفضل نرجع رسالة خطأ واضحة بدل قائمة فارغة مشان زميلك يعرف شو المشكلة
        return Response({
            "status": "error", 
            "message": f"فشل جلب قائمة المدرسين: {str(e)}"
        }, status=status.HTTP_400_BAD_REQUEST)
    


@api_view(['GET'])
@permission_classes([AllowAny])
def get_all_employees(request):
    try:
        # تعديل الـ select_related لتطابق الحقول المتاحة (user, faculty)
        employees = Employee.objects.select_related('user', 'faculty').all()
        
        results = []
        for emp in employees:
            if emp.user:
                results.append({
                    "user_id": emp.user.id,
                    "first_name": emp.user.first_name.strip() if emp.user.first_name else "",
                    "last_name": emp.user.last_name.strip() if emp.user.last_name else "",
                    "email": emp.user.email if emp.user.email else "",
                    "phone_number": emp.user.phone_number if emp.user.phone_number else "",
                    # تغيير الحقل من department لـ faculty حسب الموديل عندك
                    "faculty_name": emp.faculty.name.strip() if emp.faculty else "إدارة عامة",
                    "role": emp.user.role,
                })
            
        return Response({
            "status": "success",
            "count": len(results),
            "data": results
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ: {str(e)}"
        }, status=status.HTTP_400_BAD_REQUEST)

 
@api_view(['GET'])
@permission_classes([AllowAny])
def get_all_admins(request):
    try:
        # فلترة المستخدمين اللي الرول تبعهم admin
        admins = User.objects.filter(role='admin')
        
        results = []
        for admin in admins:
            results.append({
                "user_id": admin.id,
                "first_name": admin.first_name.strip() if admin.first_name else "",
                "last_name": admin.last_name.strip() if admin.last_name else "",
                "email": admin.email if admin.email else "",
                "phone_number": admin.phone_number if admin.phone_number else "",
                "role": "مدير نظام",
            })
            
        return Response({
            "status": "success",
            "count": len(results),
            "data": results
        }, status=status.HTTP_200_OK)
    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    


@api_view(['PUT', 'DELETE'])
@permission_classes([AllowAny])
def manage_instructor_api(request, user_id):
    # 1. البحث عن المستخدم (سواء بالأي دي تبعه أو برقم المدرس)
    user = User.objects.filter(id=user_id).first()
    if not user:
        # محاولة البحث عن طريق جدول المدرسين إذا كان الرقم المبعوث هو instructor_id
        instructor_obj = Instructor.objects.filter(instructor_id=user_id).first()
        if instructor_obj:
            user = instructor_obj.user
        else:
            return Response({"status": "error", "message": "المدرس غير موجود"}, status=404)

    # --- أولاً: منطق التحديث (PUT) ---
    if request.method == 'PUT':
        data = request.data
        try:
            with transaction.atomic():
                # تحديث بيانات اليوزر الأساسية
                user.first_name = data.get('first_name', user.first_name).strip()
                user.last_name = data.get('last_name', user.last_name).strip()
                user.email = data.get('email', user.email).strip()
                user.phone_number = data.get('phone_number', user.phone_number).strip()
                user.save()

                # تحديث بيانات المدرس (الرتبة والقسم)
                instructor = getattr(user, 'instructor', None)
                if instructor:
                    instructor.academic_rank = data.get('academic_rank', instructor.academic_rank)
                    # تحديث القسم إذا انبعت الأي دي تبعه
                    dept_id = data.get('department_id')
                    if dept_id:
                        instructor.department_id = dept_id
                    instructor.save()
            
            return Response({"status": "success", "message": "تم تحديث بيانات المدرس بنجاح"})
        except Exception as e:
            return Response({"status": "error", "message": f"فشل التحديث: {str(e)}"}, status=400)

    # --- ثانياً: منطق الحذف (DELETE) ---
    elif request.method == 'DELETE':
        try:
            with transaction.atomic():
                # الحصول على معرف المدرس للتنظيف
                instructor = getattr(user, 'instructor', None)
                
                if instructor:
                    inst_id = instructor.instructor_id
                    
                    # تنظيف الجداول المرتبطة (SQL مباشر لضمان الحذف المتسلسل المعقد)
                    with connection.cursor() as cursor:
                        # 1. حذف الإشعارات
                        cursor.execute("DELETE FROM Notification WHERE user_id = %s", [user.id])

                        # 2. حذف الـ Exam_Duty
                        cursor.execute("""
                            DELETE FROM EXAM_DUTY 
                            WHERE instructor_id = %s 
                            OR teaching_load_id IN (
                                SELECT teaching_load_id FROM TEACHING_LOAD 
                                WHERE course_allocation_id IN (SELECT course_allocation_id FROM COURSE_ALLOCATION WHERE instructor_id = %s)
                            )
                        """, [inst_id, inst_id])

                        # --- 🌟 إضافة جديدة: حذف الجلسات المرتبطة بالأحمال قبل حذف الأحمال نفسها 🌟 ---
                        cursor.execute("""
                            DELETE FROM PROJECT_SESSION 
                            WHERE teaching_load_id IN (
                                SELECT teaching_load_id FROM TEACHING_LOAD 
                                WHERE course_allocation_id IN (SELECT course_allocation_id FROM COURSE_ALLOCATION WHERE instructor_id = %s)
                            )
                        """, [inst_id])

                        # 3. حذف سجلات الأحمال
                        cursor.execute("""
                            DELETE FROM TEACHING_LOAD 
                            WHERE course_allocation_id IN (
                                SELECT course_allocation_id FROM COURSE_ALLOCATION WHERE instructor_id = %s
                            )
                        """, [inst_id])

                        # 4. حذف المحاضرات وتخصيص المواد
                        cursor.execute("DELETE FROM LECTURES WHERE course_allocation_id IN (SELECT course_allocation_id FROM COURSE_ALLOCATION WHERE instructor_id = %s)", [inst_id])
                        # 5. حذف مشاريع التخرج المرتبطة بالمدرس
                        cursor.execute("DELETE FROM GRADUATION_PROJECT WHERE instructor_id = %s", [inst_id])
                        cursor.execute("DELETE FROM COURSE_ALLOCATION WHERE instructor_id = %s", [inst_id])

                # 2. حذف البروفايل (عبر ORM)
                Profile.objects.filter(user=user).delete()

                # 3. حذف المستخدم (بسبب OnDelete=CASCADE سيمسح سطر المدرس تلقائياً في أغلب الأنظمة)
                user.delete()

            return Response({"status": "success", "message": "تم الحذف بنجاح تنظيف قاعدة البيانات"})

        except Exception as e:
            return Response({"status": "error", "message": f"فشل الحذف: {str(e)}"}, status=400)

    return Response({"status": "error", "message": "طلب غير مدعوم"}, status=405)


@api_view(['PUT', 'DELETE'])
@permission_classes([AllowAny])
def manage_employee_api(request, user_id):
    employee = Employee.objects.select_related('user').filter(user_id=user_id).first()
    if not employee:
        return Response({"status": "error", "message": "الموظف غير موجود"}, status=404)

    if request.method == 'PUT':
        data = request.data
        try:
            with transaction.atomic():
                user = employee.user
                user.first_name = data.get('first_name', user.first_name).strip()
                user.last_name = data.get('last_name', user.last_name).strip()
                user.phone_number = data.get('phone_number', user.phone_number).strip()
                user.save()
                
                # تعديل الكلية المرتبطة بالموظف
                faculty_id = data.get('faculty_id')
                if faculty_id:
                    employee.faculty_id = faculty_id
                employee.save()
            return Response({"status": "success", "message": "تم تحديث بيانات الموظف"})
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=400)

    elif request.method == 'DELETE':
        try:
            with transaction.atomic():
                user = employee.user
                # هون بتحطي أي SQL لـ "تنظيف" متعلقات الموظف إذا في
                user.delete() # هاد رح يحذف اليوزر وسطر الموظف تلقائياً
            return Response({"status": "success", "message": "تم حذف الموظف بنجاح"})
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=400)


@api_view(['POST'])
def add_course_api(request):
    data = request.data
    try:
        c_code = data.get('course_code')
        c_name = data.get('course_name')
        c_hours = data.get('credit_hours', 3)
        dept_name = data.get('department_name') # القادم من الفلتر

        if not c_code or not c_name:
            return Response({"status": "error", "message": "البيانات ناقصة"}, status=400)

        # 1. البحث عن القسم بناءً على الاسم المبعوث من الفلتر
        dept_obj = None
        if dept_name:
            dept_obj = Department.objects.filter(name=dept_name).first()

        # 2. عملية الإنشاء
        new_course = Course.objects.create(
            course_code=c_code,
            course_name=c_name,
            credit_hours=c_hours,
            department=dept_obj # نربط كائن القسم إذا لقيناه
        )
            
        return Response({"status": "success", "message": "تمت الإضافة"}, status=201)
        
    except Exception as e:
        print(f"الخطأ الحقيقي: {str(e)}") # شوفي الـ Terminal شو رح يطبع
        return Response({"status": "error", "message": f"خطأ: {str(e)}"}, status=400)
    

@api_view(['GET'])
@permission_classes([AllowAny])
def all_courses(request):
    try:
        # جلب المواد مع بيانات القسم والكلية المرتبطة بها
        courses_query = Course.objects.select_related('department__faculty').all()
        
        courses_list = []
        for course in courses_query:
            # التحقق إذا كانت المادة مرتبطة بقسم أم لا
            dept_name = course.department.name if course.department else "غير مصنف"
            faculty_name = course.department.faculty.name if (course.department and course.department.faculty) else ""
            
            courses_list.append({
                "course_id": course.course_code, 
                "course_code": course.course_code,
                "course_name": course.course_name.strip(),
                "credit_hours": course.credit_hours,
                "department_name": dept_name,
                "faculty_name": faculty_name 
            })
            
        return Response({
            "status": "success",
            "count": len(courses_list),
            "data": courses_list
        }, status=200)
            
    except Exception as e:
        print(f"Error in all_courses: {str(e)}")
        return Response({
            "status": "error",
            "message": f"فشل جلب المقررات: {str(e)}"
        }, status=500)
    

@api_view(['DELETE'])
@permission_classes([AllowAny])
def delete_course(request, course_code):
    try:
        course = Course.objects.filter(course_code=course_code).first()
        if not course:
            return Response({"status": "error", "message": "المقرر غير موجود"}, status=404)

        with transaction.atomic():
            # 1. إيجاد كافة الـ allocations المرتبطة بهذا المقرر
            allocations = CourseAllocation.objects.filter(course_code=course)
            
            for allocation in allocations:
                # 2. حذف المحاضرات المرتبطة بهذا التخصيص أولاً (هذا كان يسبب الخطأ الأخير)
                Lectures.objects.filter(course_allocation=allocation).delete()
                
                # 3. إيجاد الـ TeachingLoads المرتبطة بالـ allocation
                loads = TeachingLoad.objects.filter(course_allocation=allocation)
                
                for load in loads:
                    # 4. حذف الـ ExamDuty المرتبط بالـ TeachingLoad
                    ExamDuty.objects.filter(teaching_load=load).delete()
                    # حذف الـ TeachingLoad نفسه
                    load.delete()
                
                # 5. حذف أي ExamDuty قد يكون مرتبطاً بالـ allocation مباشرة
                # (نستخدم course_name_id بناءً على رسالة الخطأ السابقة)
                ExamDuty.objects.filter(course_name_id=course_code).delete()
                
                # 6. حذف الـ Allocation
                allocation.delete()
            
            # 7. حذف المقرر نفسه
            course.delete()
        
        return Response({"status": "success", "message": "تم حذف المقرر وكافة ارتباطاته بنجاح"})

    except Exception as e:
        return Response({"status": "error", "message": f"خطأ في الحذف: {str(e)}"}, status=400)


@api_view(['GET', 'PUT'])
@permission_classes([AllowAny])
def manage_course(request, course_code):
    try:
        # 1. البحث عن المقرر (المفتاح الأساسي هو course_code)
        course = Course.objects.filter(course_code=course_code).first()
        
        if not course:
            return Response({"status": "error", "message": "المقرر غير موجود"}, status=404)

        # --- حالة جلب البيانات (GET) ---
        if request.method == 'GET':
            return Response({
                "status": "success",
                "data": {
                    "course_code": course.course_code,
                    "course_name": course.course_name.strip(),
                    "credit_hours": course.credit_hours,
                    "department_name": "القسم العام"
                }
            }, status=200)

        # --- حالة التعديل (PUT) ---
        elif request.method == 'PUT':
            data = request.data
            
            # تحديث القيم (نستخدم القيمة القديمة كـ default إذا لم يتم إرسال قيمة جديدة)
            course.course_name = data.get('course_name', course.course_name).strip()
            course.credit_hours = data.get('credit_hours', course.credit_hours)
            
            course.save() # حفظ التغييرات في قاعدة البيانات
            
            return Response({
                "status": "success", 
                "message": "تم تحديث بيانات المقرر بنجاح"
            }, status=200)

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ: {str(e)}"
        }, status=500)


@api_view(['POST'])
@permission_classes([AllowAny])
def allocate_course_api(request):
    # 1. التحقق من وجود "فترة تنسيق" نشطة حالياً
    today = now().date()
    active_semester = Semester.objects.filter(
        coordination_start_date__lte=today, # التاريخ الحالي بعد أو يساوي تاريخ بدء التنسيق
        end_date__gte=today                # التاريخ الحالي قبل أو يساوي تاريخ نهاية الفصل
    ).first()

    if not active_semester:
        return Response({
            "status": "error", 
            "message": "عذراً، لا يمكن إجراء تخصيص حالياً. فترة التنسيق لم تبدأ بعد أو أن الفصل قد انتهى."
        }, status=400)

    # دعم إرسال مادة واحدة أو قائمة مواد
    data_list = request.data if isinstance(request.data, list) else [request.data]
    results = []

    try:
        with transaction.atomic():
            for data in data_list:
                # 2. استخراج البيانات من الطلب
                u_id = data.get('instructor_id') # الأي دي تبع المستخدم
                c_code = data.get('course_id')   # كود المادة
                # نستخدم s_id من الطلب أو نعتمد active_semester.id مباشرة لضمان الدقة
                s_id = active_semester.semester_id 
                r_id = data.get('room_id')
                day = data.get('day_of_week')
                start = data.get('start_time')
                end = data.get('end_time')
                l_type = data.get('lecture_type', 'نظري')

                # 3. التأكد من وجود المدرس
                instructor = Instructor.objects.filter(user_id=u_id).first()
                if not instructor:
                    raise Exception(f"المدرس رقم {u_id} غير موجود!")

                # --- [فحص التضاربات] ---
                
                # أ. هل المدرس مشغول بهذا الوقت؟
                instructor_conflict = Lectures.objects.filter(
                    course_allocation__instructor=instructor,
                    day_of_week=day,
                    start_time__lt=end,
                    end_time__gt=start,
                    course_allocation__semester=active_semester # فحص التضارب ضمن الفصل الحالي فقط
                ).exists()
                
                if instructor_conflict:
                    raise Exception(f"تضارب: المدرس {instructor.user.first_name} مشغول في هذا الوقت يوم {day}")

                # ب. هل القاعة محجوزة بهذا الوقت؟
                room_conflict = Lectures.objects.filter(
                    room_id=r_id,
                    day_of_week=day,
                    start_time__lt=end,
                    end_time__gt=start,
                    course_allocation__semester=active_semester
                ).exists()

                if room_conflict:
                    raise Exception(f"تضارب: القاعة رقم {r_id} محجوزة مسبقاً في هذا الوقت")

                # --- [عملية الحفظ] ---

                # 4. إنشاء سجل التخصيص (Course Allocation)
                allocation = CourseAllocation.objects.create(
                    course_code=Course.objects.get(course_code=c_code),
                    instructor=instructor,
                    semester=active_semester,
                    room_id=r_id
                )

                # 5. إنشاء سجل الموعد (Lecture)
                lecture = Lectures.objects.create(
                    course_allocation=allocation,
                    room_id=r_id,
                    day_of_week=day,
                    start_time=start,
                    end_time=end,
                    lecture_type=l_type
                )

                results.append({
                    "allocation_id": allocation.course_allocation_id,
                    "lecture_id": lecture.lecture_id,
                    "semester_name": active_semester.semester_name
                })

        return Response({
            "status": "success", 
            "message": f"تم حفظ {len(results)} فئة بنجاح خلال فترة تنسيق {active_semester.semester_name}",
            "data": results
        }, status=201)

    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=400)


@api_view(['POST'])
@permission_classes([AllowAny])
def add_room_api(request):
    data = request.data
    try:
        name = data.get('room_name')
        location = data.get('location', '') # اختيارية
        capacity = data.get('capacity', 40) # قيمة افتراضية إذا لم ترسل

        # 1. التحقق من البيانات الأساسية
        if not name:
            return Response({"status": "error", "message": "اسم القاعة مطلوب"}, status=400)

        # 2. إضافة القاعة باستخدام ORM
        new_room = Room.objects.create(
            room_name=name,
            location=location,
            capacity=capacity
        )
            
        return Response({
            "status": "success", 
            "message": "تمت إضافة القاعة بنجاح",
            "room_id": new_room.room_id  # نرجع الـ ID مشان نستخدمه بالبوستمان فوراً
        }, status=201)

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء الإضافة: {str(e)}"
        }, status=400)   




@api_view(['POST'])
def open_academic_year_api(request):
    data = request.data
    try:
        # 1. جلب النص المرسل من الفرونت إند
        year_name = data.get('yearName') 
        
        if not year_name:
            return Response({
                "status": "error", 
                "message": "الرجاء إدخال اسم السنة الدراسية"
            }, status=400)

        # 2. معالجة النص: استبدال الشرطة المائلة (/) بشرطة عادية (-) لتوحيد الصيغة
        # هذا يحل المشكلة سواء أرسل المستخدم 2025/2026 أو 2025-2026
        clean_name = year_name.replace('/', '-')
        
        if '-' not in clean_name:
            return Response({
                "status": "error", 
                "message": "تنسيق السنة غير صحيح. مثال: 2025-2026 أو 2025/2026"
            }, status=400)

        # 3. تقسيم النص وتجهيز القيم
        parts = clean_name.split('-')
        start_v = parts[0].strip() # strip لإزالة أي مسافات زائدة
        end_v = parts[1].strip()

        # 4. تنفيذ العملية داخل الـ Database
        with transaction.atomic():
            # إيقاف أي سنة دراسية نشطة حالياً
            AcademicYear.objects.filter(is_active=True).update(is_active=False)
            
            # إنشاء السنة الدراسية الجديدة
            new_year = AcademicYear.objects.create(
                start_year=int(start_v),
                end_year=int(end_v),
                is_active=True
            )
            
        return Response({
            "status": "success",
            "academic_year_id": new_year.academic_year_id,
            "message": f"تم فتح السنة الدراسية {start_v}-{end_v} بنجاح"
        }, status=201)

    except ValueError:
        # هذا الخطأ يحدث إذا فشل int(start_v) في تحويل النص إلى رقم
        return Response({
            "status": "error", 
            "message": "يجب أن تكون السنوات أرقاماً صحيحة"
        }, status=400)
        
    except Exception as e:
        # لأي خطأ غير متوقع آخر
        return Response({
            "status": "error", 
            "message": str(e)
        }, status=400)
    
@api_view(['POST'])
def open_semester_api(request):
    data = request.data
    try:
        print(f"DEBUG: Data received: {request.data}")
        # 1. استخراج البيانات الأساسية
        year_id = data.get('academic_year_id')
        semester_name = data.get('semesterName')
        
        start_date_raw = data.get('startDate')
        end_date_raw = data.get('endDate')
        coord_start_raw = data.get('coordination_start_date') 
        coord_end_raw = data.get('coordination_end_date')

        # تحويل التواريخ من صيغة ISO (Flutter) إلى صيغة Django (YYYY-MM-DD)
        start_date = start_date_raw.split('T')[0] if start_date_raw else None
        end_date = end_date_raw.split('T')[0] if end_date_raw else None
        coord_start = coord_start_raw.split('T')[0] if coord_start_raw else start_date
        coord_end = coord_end_raw.split('T')[0] if coord_end_raw else end_date

        with transaction.atomic():
            # 2. إنشاء الفصل الدراسي
            new_semester = Semester.objects.create(
                academic_year_id=year_id,
                semester_name=semester_name,
                start_date=start_date,
                end_date=end_date,
                coordination_start_date=coord_start, 
                is_active=True
            )

            # 3. تخزين العطل الرسمية
            # 3. تخزين العطل الرسمية (معدل للتعامل مع البيانات القادمة)
            holidays = data.get('holidays', [])
            holiday_objects = []
            
            for h in holidays:
                # إذا كانت h عبارة عن نص (تاريخ مباشرة)
                if isinstance(h, str):
                    h_date = h.split('T')[0]
                # إذا كانت h عبارة عن قاموس (كما كان سابقاً)
                elif isinstance(h, dict):
                    h_date_raw = h.get('date', '')
                    h_date = h_date_raw.split('T')[0] if h_date_raw else None
                else:
                    continue

                if h_date:
                    holiday_objects.append(
                        AcademicHoliday(
                            semester=new_semester, 
                            holiday_date=h_date,
                        )
                    )
            
            if holiday_objects:
                AcademicHoliday.objects.bulk_create(holiday_objects)

            # 🌟 4. تخزين فترات الامتحانات في جدول ExamDuty
            exam_periods = data.get('exam_periods', [])
            exam_period_objects = []
            
            for ep in exam_periods:
                ep_start = ep.get('start').split('T')[0] if ep.get('start') else None
                ep_end = ep.get('end').split('T')[0] if ep.get('end') else None
                
                if ep_start and ep_end:
                    exam_period_objects.append(
                        ExamDuty(
                            exam_name=ep.get('name', 'امتحان'),
                            exam_date=ep_start,
                            exam_end_date=ep_end,
                            instructor=None,
                            course_name=None,
                            room=None,
                            teaching_load=None
                        )
                    )
            
            if exam_period_objects:
                ExamDuty.objects.bulk_create(exam_period_objects)

        return Response({
            "status": "success",
            "message": f"تم افتتاح {semester_name} وتخزين العطل وفترات الامتحانات بنجاح",
            "semester_id": new_semester.semester_id
        }, status=201)

    except Exception as e:
        import traceback
        # هذا السطر سيطبع الخطأ الكامل في الـ Terminal مع اسم الحقل الذي يسبب المشكلة
        print(f"DEBUG: --------------------------------")
        print(f"DEBUG: الخطأ الحقيقي هو: {str(e)}")
        traceback.print_exc() 
        print(f"DEBUG: --------------------------------")
        return Response({"status": "error", "message": str(e)}, status=400)

        
@api_view(['PUT']) 
def update_semester_api(request, semester_id):
    data = request.data
    # اطبع البيانات القادمة في الـ Terminal عندك لتعرف ماذا يرسل Flutter بالضبط
    print(f"DEBUG: Incoming data: {data}") 
    
    try:
        semester = Semester.objects.get(semester_id=semester_id)
        
        # استخدم أسماء الحقول التي يرسلها Flutter فعلياً
        # لاحظ هنا استخدمنا .get() مع قيمة افتراضية لتجنب الـ None
        semester.semester_name = data.get('semesterName', semester.semester_name)
        
        if data.get('startDate'):
            semester.start_date = data.get('startDate').split('T')[0]
        if data.get('endDate'):
            semester.end_date = data.get('endDate').split('T')[0]
        if data.get('coordination_start_date'):
            semester.coordination_start_date = data.get('coordination_start_date').split('T')[0]

        with transaction.atomic():
            semester.save()
            
            new_holidays = data.get('holidays')
            if new_holidays is not None:
                AcademicHoliday.objects.filter(semester=semester).delete()
                for h in new_holidays:
                    if h: # تأكد أن التاريخ ليس فارغاً
                        AcademicHoliday.objects.create(
                            semester=semester, 
                            holiday_date=h.split('T')[0]
                        )

        return Response({"status": "success"}, status=200)

    except Exception as e:
        print(f"CRITICAL ERROR: {str(e)}") # سيظهر هذا في الـ Terminal عندك باللون الأحمر غالباً
        return Response({"status": "error", "message": str(e)}, status=400)
@api_view(['GET'])
@permission_classes([AllowAny])
def get_rooms_api(request):
    try:
        # جلب جميع الغرف باستخدام الـ ORM
        rooms_objects = Room.objects.all()
        
        # تحويل البيانات إلى قائمة من القواميس (Dictionaries)
        rooms_data = []
        for room in rooms_objects:
            rooms_data.append({
                "id": room.room_id,
                "name": room.room_name.strip() if room.room_name else "",
                "location": room.location.strip() if room.location else "",
                "capacity": room.capacity or 0
            })
            
        return Response({
            "status": "success", 
            "data": rooms_data
        }, status=200)

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء جلب البيانات: {str(e)}"
        }, status=400)
    
@api_view(['PUT', 'DELETE'])
@permission_classes([AllowAny])
def manage_room_api(request, room_id):
    # محاولة جلب القاعة أولاً
    try:
        room = Room.objects.get(room_id=room_id)
    except Room.DoesNotExist:
        return Response({"status": "error", "message": "القاعة غير موجودة"}, status=404)

    # حالة التعديل (Update)
    if request.method == 'PUT':
        data = request.data
        try:
            # تحديث الحقول إذا كانت موجودة في الطلب، وإلا المحافظة على القيمة القديمة
            room.room_name = data.get('room_name', room.room_name)
            room.location = data.get('location', room.location)
            room.capacity = data.get('capacity', room.capacity)
            room.save()
            
            return Response({
                "status": "success",
                "message": "تم تحديث بيانات القاعة بنجاح"
            }, status=200)
        except Exception as e:
            return Response({"status": "error", "message": str(e)}, status=400)

    # حالة الحذف (Delete)
    if request.method == 'DELETE':
        try:
            room.delete()
            return Response({
                "status": "success",
                "message": "تم حذف القاعة بنجاح"
            }, status=200)
        except Exception as e:
            return Response({"status": "error", "message": f"لا يمكن حذف القاعة لارتباطها ببيانات أخرى: {str(e)}"}, status=400)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_instructor_daily_schedule(request, instructor_id):
    # خريطة الأيام مع كافة احتمالات 
    flexible_days = {
        'Monday': ['الاثنين', 'الأثنين', 'إثنين', 'الاثنين'],
        'Tuesday': ['الثلاثاء'],
        'Wednesday': ['الأربعاء', 'الاربعاء'],
        'Thursday': ['الخميس'],
        'Friday': ['الجمعة', 'الجمعه'],
        'Saturday': ['السبت'],
        'Sunday': ['الأحد', 'الاحد'],
    }
    
    target_date_str = request.query_params.get('date', datetime.now().strftime('%Y-%m-%d'))
    
    try:
        target_date = datetime.strptime(target_date_str, '%Y-%m-%d').date()
        current_day_en = target_date.strftime('%A') 
        possible_ar_days = flexible_days.get(current_day_en, [])
        search_terms = possible_ar_days + [current_day_en]

        # مصفوفة الجدول النهائي التي سنرسلها للـ Flutter
        schedule = []

        # التأكد من وجود المدرس أولاً
        instructor = Instructor.objects.filter(user_id=instructor_id).first()
        if not instructor:
            return Response({"status": "error", "message": "المدرس غير موجود"}, status=404)

        # 1. التحقق من أن التاريخ يقع ضمن فترة فصل دراسي نشط
        active_semester = Semester.objects.filter(
            is_active=True,
            start_date__lte=target_date,
            end_date__gte=target_date
        ).first()

        if not active_semester:
            return Response({
                "status": "success",
                "message": "خارج نطاق الفصل الدراسي الحالي أو لم يبدأ الدوام بعد",
                "requested_date": target_date_str,
                "data": []
            })

        #  2. جلب المحاضرات التعويضية المخصصة لهذا التاريخ الفعلي (إن وجدت)
        # جلبها قبل فحص العطل والامتحانات لأن التعويضية تتحدى العطل الاستثنائية
        compensatory_records = TeachingLoad.objects.filter(
            course_allocation__instructor=instructor,
            course_allocation__semester=active_semester,
            lecture_date=target_date,
            is_compensatory=True
        ).select_related('course_allocation__course_code', 'room').order_by('start_time')

        for comp in compensatory_records:
            schedule.append({
                "lecture_id": comp.teaching_load_id, 
                "course": comp.course_allocation.course_code.course_name.strip(),
                "start": comp.start_time.strftime('%H:%M') if comp.start_time else "--:--",
                "end": comp.end_time.strftime('%H:%M') if comp.end_time else "--:--",
                "room": comp.room.room_name.strip() if comp.room else "غير محدد",
                "type": "محاضرة تعويضية", 
                "is_done": comp.attendance, 
                "is_compensatory": True 
            })

        # 3. التحقق من العطل الرسمية (تؤثر فقط على المحاضرات العادية الثابتة)
        is_holiday = AcademicHoliday.objects.filter(holiday_date=target_date).exists()
        if is_holiday:
            return Response({
                "status": "success",
                "message": "اليوم عطلة رسمية (تظهر المحاضرات التعويضية فقط إن وجدت)",
                "requested_day": possible_ar_days[0] if possible_ar_days else current_day_en,
                "data": schedule 
            })

        # 4. التحقق من فترة الامتحانات (توقف المحاضرات العادية فقط)
        current_exam = ExamDuty.objects.filter(
            exam_date__lte=target_date,
            exam_end_date__gte=target_date
        ).first()

        if current_exam:
            return Response({
                "status": "success",
                "message": f"توقفت المحاضرات العادية بسبب فترة: {current_exam.exam_name} (تظهر التعويضية فقط)",
                "requested_date": target_date_str,
                "data": schedule 
            })

        # 5. جلب المحاضرات الطبيعية الثابتة (في حال كان اليوم دوام طبيعي)
        lectures = Lectures.objects.filter(
            course_allocation__instructor=instructor,
            course_allocation__semester=active_semester,
            day_of_week__in=search_terms 
        ).select_related('course_allocation__course_code', 'room').order_by('start_time')

        for lec in lectures:
            attendance_record = TeachingLoad.objects.filter(
                course_allocation=lec.course_allocation,
                lecture_date=target_date,
                is_compensatory=False # نضمن ألا نخلط مع سجل تعويضي بنفس اليوم
            ).first()

            schedule.append({
                "lecture_id": lec.lecture_id,
                "course": lec.course_allocation.course_code.course_name.strip(),
                "start": lec.start_time.strftime('%H:%M') if lec.start_time else "--:--",
                "end": lec.end_time.strftime('%H:%M') if lec.end_time else "--:--",
                "room": lec.room.room_name.strip() if lec.room else "غير محدد",
                "type": lec.lecture_type,
                "is_done": attendance_record.attendance if attendance_record else False,
                "is_compensatory": False
            })

        # ترتيب الجدول النهائي حسب وقت البدء لكي تظهر المحاضرات متسلسلة زمنياً للدكتور
        schedule.sort(key=lambda x: x['start'])

        return Response({
            "status": "success", 
            "instructor_id_used": instructor.instructor_id,
            "semester_name": active_semester.semester_name,
            "requested_date": target_date_str,
            "requested_day": possible_ar_days[0] if possible_ar_days else current_day_en, 
            "data": schedule
        })

    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=400)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_instructor_weekly_schedule(request, instructor_id):
    try:
        # 1. التأكد من وجود المدرس
        instructor = Instructor.objects.filter(user_id=instructor_id).first()
        if not instructor:
            return Response({
                "status": "error", 
                "message": f"المستخدم رقم {instructor_id} غير مسجل كمدرس"
            }, status=404)

        # 2. تعريف ترتيب الأيام (مهم جداً للترتيب الأسبوعي العربي)
        day_order = Case(
            When(day_of_week='الأحد', then=Value(1)),
            When(day_of_week='الاثنين', then=Value(2)),
            When(day_of_week='الثلاثاء', then=Value(3)),
            When(day_of_week='الأربعاء', then=Value(4)),
            When(day_of_week='الخميس', then=Value(5)),
            When(day_of_week='الجمعة', then=Value(6)),
            When(day_of_week='السبت', then=Value(7)),
            output_field=IntegerField(),
        )

        # 3. جلب كافة محاضرات المدرس مع الترتيب
        lectures = Lectures.objects.filter(
            course_allocation__instructor=instructor
        ).select_related('course_allocation__course_code', 'room').annotate(
            order=day_order
        ).order_by('order', 'start_time')

        # 4. تنظيم البيانات في Dictionary حسب اليوم
        weekly_data = {}
        for lec in lectures:
            day = lec.day_of_week
            if day not in weekly_data:
                weekly_data[day] = []
            
            start_str = lec.start_time.strftime('%H:%M') if lec.start_time else "--:--"
            end_str = lec.end_time.strftime('%H:%M') if lec.end_time else "--:--"

            weekly_data[day].append({
                "course": lec.course_allocation.course_code.course_name.strip(),
                "time": f"{start_str} - {end_str}",
                "room": lec.room.room_name.strip() if lec.room else "غير محدد"
            })

        return Response({
            "status": "success", 
            "instructor_id_used": instructor.instructor_id,
            "data": weekly_data
        })

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ: {str(e)}"
        }, status=400)


@api_view(['POST'])
@permission_classes([AllowAny])
def assign_exam_duties(request):
    course_code = request.data.get('course_code')
    exam_date = request.data.get('exam_date')
    room_id = request.data.get('room_id')
    user_ids = request.data.get('instructors') # قائمة IDs المدرسين
    start_time = request.data.get('start_time') 
    end_time = request.data.get('end_time')
    
    # الحقول الجديدة اللي ضفناها للموديل
    exam_name = request.data.get('exam_name', 'امتحان')
    exam_end_date = request.data.get('exam_end_date', None)

    try:
        with transaction.atomic():
            # 1. جلب المدرسين
            instructors = Instructor.objects.filter(user_id__in=user_ids)
            if not instructors.exists():
                return Response({"status": "error", "message": "لم يتم العثور على مدرسين في النظام"}, status=404)

            # 2. جلب المادة مباشرة من جدول الكورسات كرمال نضمن الاسم دايماً
            course_obj = Course.objects.filter(course_code=course_code).first()

            # 3. محاولة جلب النصاب التابع للمادة (إذا وجد)
            t_load = TeachingLoad.objects.filter(
                course_allocation__course_code=course_code
            ).first()

            # 🎯 التعديل السحري: شلنا الـ return 400 الصارم. 
            # إذا الـ TeachingLoad فاضي هلق (بسبب التنظيف)، المراقبة مارح تضرب!
            
            # 4. تجهيز قائمة التكليفات
            duties_to_create = []
            for inst in instructors:
                duties_to_create.append(
                    ExamDuty(
                        exam_name=exam_name,
                        exam_date=exam_date,
                        exam_end_date=exam_end_date,
                        start_time=start_time, 
                        end_time=end_time,
                        room_id=room_id, 
                        instructor=inst,
                        course_name=course_obj, # 🌟 الربط المباشر مع الكورس لضمان الاسم دايماً
                        teaching_load=None   # بياخد الـ ID إذا موجود، أو بيبقى NULL بأمان إذا لسا ما انخلق
                    )
                )

            # 5. الإدخال بالجملة
            ExamDuty.objects.bulk_create(duties_to_create)

        return Response({"status": "success", "message": "تم تكليف المدرسين بالمراقبة بنجاح"})

    except Exception as e:
        return Response({"status": "error", "message": f"حدث خطأ أثناء التكليف: {str(e)}"}, status=500)


@api_view(['POST'])
def check_lecture_attendance(request):
    lecture_id_input = request.data.get('lecture_id')
    
    try:
        with transaction.atomic():
            current_date = date.today()

            # --- الخطوة 1: البحث الذكي في المحاضرات التعويضية أولاً ---
            # حتى لو لم يرسل Flutter قيمة is_compensatory، سنبحث إذا كان الـ ID ينتمي لجدول TeachingLoad
            load_to_update = TeachingLoad.objects.filter(pk=lecture_id_input, is_compensatory=True).first()
            
            if load_to_update:
                load_to_update.attendance = 1
                load_to_update.is_finished = True
                load_to_update.save()
                return Response({"status": "success", "message": "تم تحديث حضور المحاضرة التعويضية بنجاح"})

            # --- الخطوة 2: إذا لم تكن تعويضية، نكمل كودك القديم للمحاضرات العادية ---
            try:
                lecture = Lectures.objects.get(lecture_id=lecture_id_input)
            except Lectures.DoesNotExist:
                return Response({
                    "status": "error", 
                    "message": "المحاضرة غير موجودة في الجدول الأساسي"
                }, status=404)

            # البحث عن السجل اليومي للمحاضرة العادية
            load_to_update = TeachingLoad.objects.filter(
                course_allocation=lecture.course_allocation,
                lecture_date=current_date,
                is_compensatory=False 
            ).first()

            if load_to_update:
                load_to_update.attendance = 1
                load_to_update.is_finished = True
                load_to_update.save()
                message = "تم تحديث السجل بنجاح"
            else:
                TeachingLoad.objects.create(
                    course_allocation=lecture.course_allocation,
                    lecture_date=current_date,
                    attendance=1,
                    is_finished=True,
                    is_compensatory=False
                )
                message = "تم إنشاء سجل جديد بنجاح"

            return Response({"status": "success", "message": message})

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"خطأ في معالجة البيانات: {str(e)}"
        }, status=500)
    
@api_view(['GET'])
@permission_classes([AllowAny])
def get_instructor_exam_duties(request, instructor_id):
    try:
        # جلب كل المراقبات مع عمل select_related للـ course_name المباشر والـ room والـ teaching_load
        duties_queryset = ExamDuty.objects.select_related(
            'course_name', 
            'room', 
            'teaching_load'
        ).filter(
            instructor__user_id=instructor_id
        ).order_by('exam_date')

        duties_list = []
        for duty in duties_queryset:
            # 1. قراءة اسم المادة
            course_display_name = "مادة غير محددة"
            if duty.course_name:
                course_display_name = duty.course_name.course_name
            elif duty.teaching_load and duty.teaching_load.course_allocation and duty.teaching_load.course_allocation.course_code:
                course_display_name = duty.teaching_load.course_allocation.course_code.course_name
            
            # 2. معالجة الوقت وتوحيد صيغته للـ Flutter (مثلاً: 12:00 - 13:00 أو الصيغة العادية حسب موديلك)
            formatted_time = "10:00 AM"
            if duty.start_time:
                formatted_time = duty.start_time.strftime('%I:%M %p')

            # 3. 🌟 فحص حالة الحضور (التشيك بوكس) وتحويلها للـ Boolean اللي ناطره الفلتر
            is_done_boolean = False
            if duty.teaching_load and duty.teaching_load.attendance is True:
                is_done_boolean = True

            duties_list.append({
                "id": duty.exam_duty_id,       # 🔥 يطابق json['id'] بالفلتر
                "course": course_display_name, # يطابق json['course']
                "exam_name": duty.exam_name, 
                "date": duty.exam_date.strftime('%Y-%m-%d') if duty.exam_date else "لم يحدد تاريخ", # يطابق json['date']
                "time": formatted_time,        # يطابق json['time']
                "room": duty.room.room_name if duty.room else "قاعة غير محددة", # يطابق json['room']
                "is_done": is_done_boolean     # 🔥 الحقل السحري! غيرناه من is_attended لـ is_done لسيطابق الفلتر بالملي 🎯
            })

        return Response({
            "status": "success", 
            "data": duties_list
        })

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"خطأ في جلب المراقبات: {str(e)}"
        }, status=500)

@api_view(['POST'])
@permission_classes([AllowAny])
def check_exam_attendance(request):
    duty_id = request.data.get('exam_duty_id')
    
    try:
        with transaction.atomic():
            # 1. جلب بيانات المراقبة مع المادة والمدرس
            try:
                exam_duty = ExamDuty.objects.select_related('instructor', 'course_name').get(exam_duty_id=duty_id)
            except ExamDuty.DoesNotExist:
                return Response({"status": "error", "message": "المراقبة غير موجودة"}, status=404)

            # إذا كانت المراقبة معمول عليها تشيك مسبقاً
            if exam_duty.teaching_load and exam_duty.teaching_load.attendance:
                return Response({"status": "success", "message": "المراقبة مثبتة الحضور مسبقاً"})

            # 2. جلب التخصيص المطابق تماماً للمدرس والمادة
            exact_alloc = None
            if exam_duty.course_name:
                exact_alloc = CourseAllocation.objects.filter(
                    instructor=exam_duty.instructor,
                    course_code=exam_duty.course_name
                ).first()
            
            if not exact_alloc:
                exact_alloc = CourseAllocation.objects.filter(instructor=exam_duty.instructor).first()
            
            if not exact_alloc:
                return Response({"status": "error", "message": "لا يوجد أي تخصيص مواد مسجل لهذا المدرس"}, status=404)

            # 3. إنشاء سجل الحضور 
            teaching_load = TeachingLoad.objects.create(
                course_allocation=exact_alloc, 
                lecture_date=exam_duty.exam_date,
                attendance=True,
                is_finished=True,
                room=exam_duty.room,
                start_time=exam_duty.start_time,
                end_time=exam_duty.end_time
            )

            # 4. ربط المراقبة بسجل النصاب وحفظها
            exam_duty.teaching_load = teaching_load
            exam_duty.save()

        # 🌟 هاد السطر اللي كان ناقصك يا غفران! رجوع استجابة نجاح للـ Flutter
        return Response({
            "status": "success",
            "message": "تم إثبات حضور المراقبة الامتحانية بنجاح وتحديث النصاب التدريسي."
        }, status=200)

    except Exception as e:
        print(f"FINAL DEBUG ERROR: {str(e)}")
        return Response({
            "status": "error", 
            "message": f"خطأ في قاعدة البيانات: {str(e)}"
        }, status=500)
    

    

@api_view(['GET', 'POST'])
def academic_log_manager(request, user_id):
    # الحصول على التاريخ من الرابط (Query Params) أو استخدام تاريخ اليوم
    target_date_str = request.query_params.get('date', date.today().strftime('%Y-%m-%d'))
    try:
        date_obj = datetime.strptime(target_date_str, '%Y-%m-%d').date()
    except ValueError:
        return Response({"error": "تنسيق التاريخ غير صحيح، يجب أن يكون YYYY-MM-DD"}, status=400)

    # --- 1. جزء جلب البيانات (GET) ---
    if request.method == 'GET':
        days_mapping = {
            'Monday': 'الاثنين', 'Tuesday': 'الثلاثاء', 'Wednesday': 'الأربعاء',
            'Thursday': 'الخميس', 'Friday': 'الجمعة', 'Saturday': 'السبت', 'Sunday': 'الأحد'
        }
        day_name_en = date_obj.strftime('%A')
        day_name_ar = days_mapping.get(day_name_en)

        # جلب المحاضرات بناءً على الـ user_id واليوم (مع تصحيح اسم الحقل لـ course_code)
        lectures = Lectures.objects.select_related(
            'course_allocation__course_code', 
            'room'
        ).filter(
            course_allocation__instructor__user_id=user_id,
            day_of_week=day_name_ar
        )

        activities = []
        for lec in lectures:
            # التحقق إذا كانت المحاضرة مسجلة في جدول الحضور لهذا التاريخ
            is_checked = TeachingLoad.objects.filter(
                course_allocation=lec.course_allocation,
                lecture_date=date_obj
            ).exists()

            activities.append({
                "id": str(lec.lecture_id),
                # استخدام course_code للوصول لاسم المادة بناءً على الخطأ السابق
                "title": lec.course_allocation.course_code.course_name if lec.course_allocation.course_code else "مادة غير محددة",
                "type": lec.lecture_type or "نظري",
                "time": lec.start_time.strftime('%H:%M') if lec.start_time else "00:00",
                "room": lec.room.room_name if lec.room else "N/A",
                "isChecked": is_checked,
                "category": "lecture"
            })
        
        return Response(activities, status=200)

    # --- 2. جزء حفظ التعديلات (POST) ---
    if request.method == 'POST':
        data = request.data
        items = data if isinstance(data, list) else [data]
        
        try:
            with transaction.atomic():
                for item in items:
                    lec_id = item.get('lecture_id')
                    is_done = item.get('is_done', False)

                    try:
                        lecture_obj = Lectures.objects.get(lecture_id=lec_id)
                    except Lectures.DoesNotExist:
                        continue

                    if is_done:
                        # إنشاء أو تحديث الحضور (استخدمنا الحقول الأساسية فقط لضمان عمل الجداول الجديدة)
                        TeachingLoad.objects.update_or_create(
                            course_allocation=lecture_obj.course_allocation,
                            lecture_date=date_obj,
                            defaults={'attendance': 1}
                        )
                    else:
                        # حذف سجل الحضور لهذا التاريخ عند إلغاء الـ Check
                        TeachingLoad.objects.filter(
                            course_allocation=lecture_obj.course_allocation,
                            lecture_date=date_obj
                        ).delete()

                return Response({"status": "success", "message": "Updated successfully"}, status=200)
        except Exception as e:
            print(f"POST Error Detail: {str(e)}")
            return Response({"error": f"Internal Error: {str(e)}"}, status=500)
        
@api_view(['GET'])
@permission_classes([AllowAny])
def get_instructor_teaching_load_report(request, user_id):
    try:
        # 1. جلب المدرس والتأكد من وجوده في النظام
        try:
            instructor_obj = Instructor.objects.select_related('user', 'department__faculty').get(user_id=user_id)
        except Instructor.DoesNotExist:
            return Response({
                "status": "error", 
                "message": "المدرس المطلوب غير موجود في النظام."
            }, status=404)
        
        # 2. تحديد الشهر والسنة المطلوبين
        today = date.today()
        selected_month = int(request.query_params.get('month', today.month))
        selected_year = int(request.query_params.get('year', today.year))

        # 3. الفحص المبكر لنطاق العام الدراسي الفعال
        active_year_obj = AcademicYear.objects.filter(is_active=True).first()
        if active_year_obj:
            if selected_year > active_year_obj.end_year or (selected_year == active_year_obj.end_year and selected_month in [7, 8]):
                return Response({
                    "status": "error",
                    "message": "لا توجد بيانات، التاريخ المحدد خارج نطاق العام الدراسي الفعال."
                }, status=200)

        # 4. تحديد حالة إغلاق الشهر
        monthly_records = TeachingLoad.objects.filter(
            course_allocation__instructor=instructor_obj,
            lecture_date__month=selected_month,
            lecture_date__year=selected_year
        )
        has_records = monthly_records.exists()
        is_month_finished = has_records and not monthly_records.filter(is_finished=False).exists()

        # 5. حساب المحاضرات (العادية بسطر، والتعويضية المضافة بسطر مستقل فوراً)
        allocations = CourseAllocation.objects.filter(instructor=instructor_obj).select_related('course_code')
        lectures_list = [] 
        total_lect_hours_fixed = 0.0

        # أ. أولاً: نمر على المواد الأساسية (العادية) من التخصيص لمنع التكرار العشوائي
        distinct_courses = {}
        for alloc in allocations:
            if not alloc.course_code:
                continue
            c_name = alloc.course_code.course_name.strip()
            credit_hours = float(getattr(alloc.course_code, 'credit_hours', 3.0))
            
            # حساب الـ Required للمحاضرة العادية بناءً على أيام التقويم
            _, num_days = calendar.monthrange(selected_year, selected_month)
            lectures_required = 0
            target_day_of_week = getattr(alloc, 'day_of_week', 0) 
            
            for day in range(1, num_days + 1):
                if date(selected_year, selected_month, day).weekday() == target_day_of_week:
                    lectures_required += 1
            if lectures_required == 0:
                lectures_required = 4

            # عدد المرات المنجزة للمحاضرات العادية
            regular_done_count = TeachingLoad.objects.filter(
                course_allocation=alloc, 
                is_compensatory=False, 
                attendance=True, 
                is_finished=True,
                lecture_date__month=selected_month, 
                lecture_date__year=selected_year
            ).count()

            # دمج التكرار للمواد الأساسية لو نازلة بأكثر من شعبة لمنع تكرار نفس السطر العادي
            if c_name in distinct_courses:
                distinct_courses[c_name]["required"] += lectures_required
                distinct_courses[c_name]["done"] += regular_done_count
            else:
                distinct_courses[c_name] = {
                    "required": lectures_required,
                    "done": regular_done_count,
                    "credit_hours": credit_hours
                }

        # تحويل المواد العادية المصفاة إلى القائمة النهائية وحساب ساعاتها للهيدر
        for c_name, data in distinct_courses.items():
            total_lect_hours_fixed += data["credit_hours"]
                
            lectures_list.append({
                "course": c_name,
                "required": data["required"],
                "done": float(data["done"])
            })

        # ب. ثانياً: جلب "كل" المحاضرات التعويضية المضافة لهذا الدكتور في هذا الشهر فوراً
        compensatory_records = TeachingLoad.objects.filter(
            course_allocation__instructor=instructor_obj,
            is_compensatory=True,
            lecture_date__month=selected_month,
            lecture_date__year=selected_year
        ).select_related('course_allocation__course_code')

        for comp_lec in compensatory_records:
            comp_course_name = comp_lec.course_allocation.course_code.course_name.strip()
            
            # الـ Required دايماً 1 لكل محاضرة تعويضية مضافة
            comp_required = 1
            comp_done = 1 if (comp_lec.attendance is True and comp_lec.is_finished is True) else 0

            # إضافة السطر الجديد والمطلوب بالظبط كرمال الفلتر والـ Flutter
            lectures_list.append({
                "course": f"{comp_course_name} - تعويضية",
                "required": comp_required,
                "done": float(comp_done)
            })

        # 6. حساب المراقبات الامتحانية
        exam_duties = ExamDuty.objects.filter(
            instructor=instructor_obj,
            exam_date__month=selected_month,
            exam_date__year=selected_year
        ).select_related('course_name', 'teaching_load__course_allocation__course_code')
        
        total_exam_required = 0.0 
        exams_list = []

        for duty in exam_duties:
            duty_weight = 0.0
            if duty.start_time and duty.end_time:
                dt_start = datetime.combine(date.today(), duty.start_time)
                dt_end = datetime.combine(date.today(), duty.end_time)
                duration_seconds = (dt_end - dt_start).total_seconds()
                duty_weight = round(duration_seconds / 3600.0, 2) 

            is_done_exam = duty_weight if (duty.teaching_load and duty.teaching_load.attendance is True) else 0.0
            
            total_exam_required += duty_weight 
            
            course_title = "مراقبة امتحانية"
            if duty.course_name:
                course_title = duty.course_name.course_name.strip()

            exams_list.append({
                "course": course_title, 
                "required": duty_weight,  
                "done": is_done_exam      
            })

        # 🌟 الشغل الجديد (تم ضبط المحاذاة ليصبح الكود خارج حلقة المراقبات) 🌟
        assigned_projects = GraduationProject.objects.filter(instructor=instructor_obj)
        total_project_hours = 0.0
        projects_list = []

        for project in assigned_projects:
            # جلب جميع الجلسات لهذا المشروع في هذا الشهر فقط
            sessions = ProjectSession.objects.filter(
                project=project,
                session_date__month=selected_month,
                session_date__year=selected_year
            )
            
            project_hours_this_month = 0.0
            for session in sessions:
                if session.start_time and session.end_time:
                    dt_start = datetime.combine(date.today(), session.start_time)
                    dt_end = datetime.combine(date.today(), session.end_time)
                    duration_seconds = (dt_end - dt_start).total_seconds()
                    project_hours_this_month += round(duration_seconds / 3600.0, 2)

            total_project_hours += project_hours_this_month
            p_type_display = project.get_project_type_display()

            projects_list.append({
                "course": f"متابعة مشروع ({project.project_title}) - {p_type_display}",
                "required": project_hours_this_month,
                "done": project_hours_this_month
            })

        # 7. الحساب النهائي الشامل للهيدر (حساب الساعات التكليفية بالكامل بناءً على طلبك)
        final_total_required = total_lect_hours_fixed + total_exam_required + total_project_hours
        final_total_done = total_lect_hours_fixed + total_exam_required + total_project_hours

        # 8. تصدير الاستجابة المتوافقة مع واجهات الـ Flutter بالملي
        return Response({
            "instructor_info": {
                "name": f"{instructor_obj.user.first_name} {instructor_obj.user.last_name}".strip(),
                "rank": instructor_obj.academic_rank or "",
                "faculty": instructor_obj.department.faculty.name if instructor_obj.department else "",
                "department": instructor_obj.department.name if instructor_obj.department else "",
                "report_date": today.strftime("%Y-%m-%d"),
                "selected_month": selected_month,
                "is_finished": is_month_finished, 
            },
            "total_hours": round(final_total_required, 2),        
            "total_completed_hours": round(final_total_done, 2), 
            "statistics": {
                "lectures": lectures_list, 
                "exams": exams_list,
                "projects": projects_list  
            }
        })

    except Exception as e:
        import traceback
        traceback.print_exc()  
        return Response({
            "status": "error", 
            "message": f"حدث خطأ غير متوقع في السيرفر: {str(e)}"
        }, status=500)
        
            
@api_view(['POST'])
@permission_classes([AllowAny]) 
def add_faculty(request):
    name = request.data.get('name')
    
    if not name:
        return Response({"error": "اسم الكلية مطلوب"}, status=status.HTTP_400_BAD_REQUEST)
    
    # التأكد من عدم وجود الكلية مسبقاً
    if Faculty.objects.filter(name=name).exists():
        return Response({"error": "هذه الكلية موجودة مسبقاً"}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        faculty = Faculty.objects.create(name=name)
        return Response({
            "message": "تمت إضافة الكلية بنجاح",
            "faculty_id": faculty.faculty_id,
            "name": faculty.name
        }, status=status.HTTP_201_CREATED)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['POST'])
@permission_classes([AllowAny])
def add_department(request):
    name = request.data.get('name')
    faculty_id = request.data.get('faculty_id')
    
    if not name or not faculty_id:
        return Response({"error": "اسم القسم ومعرف الكلية مطلوبان"}, status=status.HTTP_400_BAD_REQUEST)
    
    try:
        # التأكد من وجود الكلية
        faculty = Faculty.objects.get(faculty_id=faculty_id)
        
        # التأكد من عدم تكرار القسم داخل نفس الكلية
        if Department.objects.filter(name=name, faculty=faculty).exists():
            return Response({"error": "هذا القسم موجود مسبقاً في هذه الكلية"}, status=status.HTTP_400_BAD_REQUEST)
        
        department = Department.objects.create(name=name, faculty=faculty)
        
        return Response({
            "message": "تمت إضافة القسم بنجاح",
            "department_id": department.department_id,
            "name": department.name,
            "faculty": faculty.name
        }, status=status.HTTP_201_CREATED)
        
    except Faculty.DoesNotExist:
        return Response({"error": "الكلية المحددة غير موجودة"}, status=status.HTTP_404_NOT_FOUND)
    except Exception as e:
        return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
@api_view(['GET'])
@permission_classes([AllowAny]) 
def instructors_by_employee_faculty(request, employee_user_id):
    try:
        # 1. جلب بيانات الموظف لمعرفة كليته
        try:
            employee = Employee.objects.select_related('faculty').get(user_id=employee_user_id)
            target_faculty = employee.faculty
        except Employee.DoesNotExist:
            return Response({"status": "error", "message": "الموظف غير موجود"}, status=404)

        if not target_faculty:
            return Response({"status": "error", "message": "هذا الموظف غير مرتبط بكلية حالياً"}, status=400)

        # 2. جلب كل المدرسين اللي أقسامهم تابعة لنفس الكلية
        # نستخدم __ (Double Underscore) للوصول للعلاقات البعيدة
        instructors_query = Instructor.objects.filter(
            department__faculty=target_faculty
        ).select_related('user', 'department')

        instructors_list = []
        for ins in instructors_query:
            instructors_list.append({
                "instructor_id": ins.instructor_id,
                "user_id": ins.user.id,
                "full_name": f"د. {ins.user.first_name} {ins.user.last_name}".strip() or ins.user.username,
                "academic_rank": ins.academic_rank,
                "department_name": ins.department.name if ins.department else "بدون قسم",
                "email": ins.user.email
            })

        return Response({
            "status": "success",
            "faculty_name": target_faculty.name,
            "count": len(instructors_list),
            "data": instructors_list
        }, status=200)

    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=500)



@api_view(['GET'])
def courses_by_faculty(request, faculty_id):
    # اطبعي الـ ID المبعوث لتعرفي ماذا يرسل الفلاتر فعلياً
    print(f"--- Requested Faculty ID: {faculty_id} ---") 
    
    try:
        # جلب المواد
        courses_query = Course.objects.filter(
            department__faculty_id=faculty_id
        ).select_related('department')

        # اطبعي عدد المواد الناتجة عن الفلترة
        print(f"--- Found {courses_query.count()} courses for this faculty ---")

        courses_list = []
        for course in courses_query:
            courses_list.append({
                "course_id": str(course.course_code), 
                "course_name": course.course_name,
                "department_name": course.department.name if course.department else "عام"
            })

        return Response({"status": "success", "data": courses_list}, status=200)

    except Exception as e:
        print(f"Error: {str(e)}")
        return Response({"status": "error", "message": str(e)}, status=500)


@api_view(['GET'])
@permission_classes([AllowAny])
def get_academic_years(request):
    try:
        # قمنا بإضافة 'semester_set__academicholiday_set' للـ prefetch لتحسين الأداء وتقليل طلبات القاعدة
        years = AcademicYear.objects.prefetch_related('semester_set__academicholiday_set').all().order_by('-start_year')
        
        results = []
        for year in years:
            semesters = year.semester_set.all().order_by('semester_name')
            
            semester_data = []
            for sem in semesters:
                # الوصول للعطل المرتبطة بهذا الفصل من جدول AcademicHoliday
                holidays = sem.academicholiday_set.all().order_by('holiday_date')
                
                # تحويل قائمة العطل إلى نصوص ISO لتفهمها واجهة الفلاتر
                holiday_list = [h.holiday_date.strftime('%Y-%m-%d') for h in holidays]
                
                semester_data.append({
                    "semester_id": sem.semester_id,
                    "semester_name": sem.semester_name,
                    "is_active": sem.is_active,
                    "start_date": sem.start_date.strftime('%Y-%m-%d') if sem.start_date else None,
                    "end_date": sem.end_date.strftime('%Y-%m-%d') if sem.end_date else None,
                    "coordination_start": sem.coordination_start_date.strftime('%Y-%m-%d') if sem.coordination_start_date else None,
                    "holidays": holiday_list  # هكذا ستصل قائمة العطل للفرونت إند
                })
            
            results.append({
                "year_id": year.academic_year_id,
                "year_display": f"{year.start_year}-{year.end_year}",
                "start_year": year.start_year,
                "end_year": year.end_year,
                "is_active": year.is_active,
                "semesters": semester_data
            })

        return Response({
            "status": "success",
            "data": results
        }, status=200)

    except Exception as e:
        import logging
        logging.error(f"Error in get_academic_years: {str(e)}")
        return Response({"status": "error", "message": f"خطأ في الوصول للبيانات: {str(e)}"}, status=400)
    
@api_view(['POST'])
def confirm_monthly_load(request, user_id):
    try:
        # 1. التأكد من وجود المدرس
        instructor_obj = Instructor.objects.get(user_id=user_id)
        
        # 2. استلام الشهر والسنة من الطلب
        month = int(request.data.get('month'))
        year = int(request.data.get('year'))
        
        # 3. تحديث كافة سجلات هذا الشهر للمدرس لتصبح "منتهية"
        updated_count = TeachingLoad.objects.filter(
            course_allocation__instructor=instructor_obj,
            lecture_date__month=month,
            lecture_date__year=year
        ).update(is_finished=True)
        
        # إذا ما لقى محاضرات بهذا الشهر، يفضل تخبري المستخدم
        if updated_count == 0:
            return Response({
                "status": "warning",
                "message": f"لا توجد محاضرات مسجلة لشهر {month} لتأكيدها"
            })

        return Response({
            "status": "success",
            "message": f"تم تأكيد وإغلاق كافة محاضرات شهر {month} بنجاح"
        })
        
    except Instructor.DoesNotExist:
        return Response({"error": "المدرس غير موجود"}, status=404)
    except Exception as e:
        return Response({"error": str(e)}, status=500)
    

#دالة اغلاق الفصل التلقائي
def auto_close_expired_semesters():
    """
    تقوم هذه الدالة بالتحقق من وجود فصول منتهية التاريخ وهي لا تزال 'نشطة'
    ثم تقوم بإغلاقها وتنظيف جدول المحاضرات.
    """
    today = now().date()
    # جلب الفصول التي تاريخ نهايتها أصغر من اليوم ولا تزال نشطة
    expired_semesters = Semester.objects.filter(is_active=True, end_date__lt=today)

    if expired_semesters.exists():
        try:
            with transaction.atomic():
                for semester in expired_semesters:
                    # 1. حذف سجلات المحاضرات (الجدول الأسبوعي) لهذا الفصل حصراً
                    # هذا هو 'فك الارتباط' الذي سيجعل جداول المدرسين فارغة للفصل الجديد
                    Lectures.objects.filter(course_allocation__semester=semester).delete()
                    
                    # 2. إيقاف تفعيل الفصل
                    semester.is_active = False
                    semester.save()
                    
                    print(f"--- [Auto-Close] Semester {semester.semester_name} closed successfully ---")
        except Exception as e:
            print(f"--- [Auto-Close Error]: {str(e)} ---")


@api_view(['GET'])
def get_available_years(request):
    try:
        # جلب كل السنوات الأكاديمية وترتيبها من الأحدث للأقدم بناءً على سنة البدء
        academic_years = AcademicYear.objects.all().order_by('-start_year')
        
        # تشكيل القائمة بالشكل المطلـوب: start_year-end_year
        years_list = []
        for ac_year in academic_years:
            # دمج السنتين مع شحطة بيناتهم وتحويلهم لنص
            range_string = f"{ac_year.start_year}-{ac_year.end_year}"
            years_list.append(range_string)
            
        return Response({
            "status": "success",
            "years": years_list
        })
        
    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=500)
    
#هاد ما استعملناه ابدا 
@api_view(['GET'])
def get_all_instructors_monthly_status(request):
    try:
        # الموظف بيبعت بس الشهر والسنة يلي بده يراقبهم
        selected_month = int(request.query_params.get('month', datetime.now().month))
        selected_year = int(request.query_params.get('year', datetime.now().year))

        instructors = Instructor.objects.select_related('user', 'department').all()
        result_list = []

        for inst in instructors:
            # جلب سجلات حضور هذا الدكتور للشهر المحدد
            monthly_records = TeachingLoad.objects.filter(
                course_allocation__instructor=inst,
                lecture_date__month=selected_month,
                lecture_date__year=selected_year
            )
            
            has_records = monthly_records.exists()
            # فحص حالة الإغلاق
            is_finished = has_records and not monthly_records.filter(is_finished=False).exists()

            # منبعت كل البيانات والـ Flutter بيلعب فيها متل ما بده
            result_list.append({
                "instructor_id": inst.instructor_id,
                "user_id": inst.user.id, 
                "name": f"{inst.user.first_name} {inst.user.last_name}".strip(),
                "department": inst.department.name if inst.department else "غير محدد",
                "has_records": has_records,
                "is_finished": is_finished
            })

        return Response({
            "status": "success",
            "month": selected_month,
            "year": selected_year,
            "data": result_list
        })
    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=400)   

@api_view(['POST'])
def send_reminder_to_instructor(request):
    try:
        data = request.data
        target_user_id = data.get('user_id')  # الـ ID تبع يوزر الدكتور (وليس الـ instructor_id)
        month = data.get('month')
        year = data.get('year')

        # التحقق من تمرير البيانات المطلوبة بالـ Body
        if not target_user_id or not month or not year:
            return Response({
                "status": "error",
                "message": "تأكد من إرسال جميع البيانات المطلوبة: user_id, month, year."
            }, status=400)

        # إنشاء الإشعار في قاعدة البيانات
        Notification.objects.create(
            user_id=target_user_id,
            title="تذكير بإغلاق النصاب الشهري",
            message=f"يرجى مراجعة وتأكيد تقرير النصاب الشهري الخاص بك لشهر {month}-{year} وضغط زر 'إنهاء التقرير' لاستكمال الإجراءات الإدارية.",
            notification_type='REMINDER'
        )

        return Response({
            "status": "success", 
            "message": "تم تسجيل إشعار التذكير في النظام بنجاح."
        }, status=201)
        
    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء إرسال التذكير: {str(e)}"
        }, status=400)
    
    
@api_view(['GET'])
def get_user_notifications(request, user_id):
    try:
        # جلب الإشعارات الخاصة بهذا المستخدم فقط وترتيبها من الأحدث للأقدم
        notifications = Notification.objects.filter(user_id=user_id).values(
            'notification_id', 'title', 'message', 'notification_type', 'is_read', 'created_at'
        )
        
        # تحويل التاريخ لصيغة مقروءة ومناسبة للـ Flutter
        notifications_list = list(notifications)
        for notif in notifications_list:
            if notif['created_at']:
                notif['created_at'] = notif['created_at'].strftime("%Y-%m-%d %H:%M:%S")

        return Response({
            "status": "success",
            "user_id": user_id,
            "data": notifications_list
        }, status=200)
        
    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء جلب الإشعارات: {str(e)}"
        }, status=400)

@api_view(['POST'])
def mark_notification_as_read(request, notification_id):
    try:
        # جلب الإشعار المحدد من الرابط فوراً
        try:
            notification = Notification.objects.get(pk=notification_id)
        except Notification.DoesNotExist:
            return Response({
                "status": "error",
                "message": "هذا الإشعار غير موجود في النظام."
            }, status=404)

        # تحويل حالة القراءة إلى True وحفظ التعديل
        notification.is_read = True
        notification.save()

        return Response({
            "status": "success",
            "message": f"تم تحديث الإشعار رقم {notification_id} إلى مقروء بنجاح."
        }, status=200)

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء تحديث الإشعار: {str(e)}"
        }, status=400)
    

@api_view(['POST'])
def add_compensatory_lecture(request):
    try:
        # 1. استقبال البيانات من الـ Request Body
        course_allocation_id = request.data.get('course_allocation_id')
        room_id = request.data.get('room_id')
        lecture_date = request.data.get('lecture_date')
        start_time = request.data.get('start_time')
        end_time = request.data.get('end_time')

        # التحقق من وجود البيانات الأساسية
        if not all([course_allocation_id, room_id, lecture_date, start_time, end_time]):
            return Response({
                "status": "error",
                "message": "جميع الحقول (المادة، القاعة، التاريخ، وقت البدء، وقت الانتهاء) مطلوبة."
            }, status=status.HTTP_400_BAD_REQUEST)

        # 2. التأكد من صحة الـ IDs بالداتابيز
        try:
            allocation = CourseAllocation.objects.get(pk=course_allocation_id)
            room = Room.objects.get(pk=room_id)
        except (CourseAllocation.DoesNotExist, Room.DoesNotExist):
            return Response({
                "status": "error",
                "message": "المادة أو القاعة غير موجودة في النظام."
            }, status=status.HTTP_404_NOT_FOUND)

        # 3. إنشاء سجل المحاضرة التعويضية فوراً في الـ Teaching Load
        compensatory_lecture = TeachingLoad.objects.create(
            course_allocation=allocation,
            lecture_date=lecture_date,
            attendance=False,
            is_finished=False,
            is_compensatory=True,  # هاد المربط الفعلي
            room=room,
            start_time=start_time,
            end_time=end_time
        )

        return Response({
            "status": "success",
            "message": "تمت إضافة المحاضرة التعويضية بنجاح إلى نصاب الدكتور.",
            "data": {
                "teaching_load_id": compensatory_lecture.teaching_load_id,
                "lecture_date": compensatory_lecture.lecture_date,
                "is_compensatory": compensatory_lecture.is_compensatory
            }
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({
            "status": "error",
            "message": f"حدث خطأ غير متوقع: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    

@api_view(['GET'])
@permission_classes([AllowAny])
def get_academic_holidays(request):
    try:
        # 1. استقبال الشـهر والسنة كـ Query Params (اختيارية)
        today = date.today()
        selected_month = request.query_params.get('month')
        selected_year = request.query_params.get('year', today.year)

        # 2. بناء الفلتر ديناميكياً
        filters = {}
        
        if selected_month:
            filters['holiday_date__month'] = int(selected_month)
            
        if selected_year:
            filters['holiday_date__year'] = int(selected_year)
        else:
            # إذا لم يرسل سنة، نجلب عطل السنة الحالية افتراضياً
            filters['holiday_date__year'] = today.year

        # 3. استعلام الداتابيز وجلب العطل مرتبة من الأقرب للأبعد
        holidays = AcademicHoliday.objects.filter(**filters).order_by('holiday_date')

        # 4. تجهيز مصفوفة البيانات للـ Flutter
        holidays_list = []
        for holiday in holidays:
            holidays_list.append({
                # بفرض أن الحقول عندك هي holiday_date و holiday_name (عدلي المسميات حسب الموديل)
                "date": holiday.holiday_date.strftime('%Y-%m-%d'),
              #  "name": holiday.name.strip() if hasattr(holiday, 'name') else "عطلة رسمية",
                "day_name": holiday.holiday_date.strftime('%A'), # اسم اليوم بالإنكليزي (مثال: Friday)
            })

        return Response({
            "status": "success",
            "total_holidays": len(holidays_list),
            "filtered_by": {
                "year": selected_year,
                "month": selected_month if selected_month else "كل أشهر السنة"
            },
            "data": holidays_list
        }, status=200)

    except Exception as e:
        return Response({
            "status": "error",
            "message": f"حدث خطأ أثناء جلب العطل: {str(e)}"
        }, status=400)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_lectures(request):
    try:
        # 1. استقبال بارامترات الفلترة من الـ Query Params (كلها اختيارية)
        holiday_date_param = request.query_params.get('holiday_date') # التاريخ القادم من الـ api السابق
        instructor_id_param = request.query_params.get('instructor_id') # فلتر الأستاذ
        course_id_param = request.query_params.get('course_id') # فلتر المادة

        # 2. بناء الفلتر الديناميكي (Query Builder)
        query_filters = Q()

        # أ) الفلترة حسب العطلة:
        # إذا الموظف اختار عطلة من القائمة المنسدلة، بدنا نعرف شو هو "يوم الأسبوع" تبع هي العطلة
        # عشان نجيب كل المحاضرات اللي بتصادف بهاد اليوم وضاعت على الدكاترة
        if holiday_date_param:
            from datetime import datetime
            holiday_date = datetime.strptime(holiday_date_param, '%Y-%m-%d').date()
            holiday_day_en = holiday_date.strftime('%A') # مثل: Tuesday
            
            # خريطة توافق الأيام مع داتابيز العربي عندك
            days_map = {
                'Monday': 'الاثنين', 'Tuesday': 'الثلاثاء', 'Wednesday': 'الأربعاء',
                'Thursday': 'الخميس', 'Friday': 'الجمعة', 'Saturday': 'السبت', 'Sunday': 'الأحد'
            }
            holiday_day_ar = days_map.get(holiday_day_en, '')
            
            # الفلترة تبحث عن الأيام المتطابقة بالهمزات أو الإنجليزي حسب تخزينك
            query_filters &= (Q(day_of_week__icontains=holiday_day_ar) | Q(day_of_week__icontains=holiday_day_en))

        # ب) الفلترة حسب المدرس:
        if instructor_id_param:
            query_filters &= Q(course_allocation__instructor_id=instructor_id_param)

        # ج) الفلترة حسب المادة:
        if course_id_param:
            query_filters &= Q(course_allocation__course_code_id=course_id_param)

        # 3. جلب البيانات بناءً على الفلاتر المدمجة مع عمل select_related لتسريع الاستعلام
        lectures = Lectures.objects.filter(query_filters).select_related(
            'course_allocation__instructor__user',
            'course_allocation__course_code',
            'room'
        ).order_by('day_of_week', 'start_time')

        # 4. تجهيز الـ JSON للـ Flutter ليخدم واجهات الإدارة والتعويض المباشر
        lectures_list = []
        for lec in lectures:
            instructor_user = lec.course_allocation.instructor.user if lec.course_allocation.instructor else None
            lectures_list.append({
                "lecture_id": lec.lecture_id,
                "day_of_week": lec.day_of_week.strip(),
                "start_time": lec.start_time.strftime('%H:%M') if lec.start_time else "--:--",
                "end_time": lec.end_time.strftime('%H:%M') if lec.end_time else "--:--",
                "lecture_type": lec.lecture_type,
                "room": {
                    "id": lec.room.room_id if lec.room else None,
                    "name": lec.room.room_name.strip() if lec.room else "غير محدد"
                },
                "course": {
                    "id": lec.course_allocation.course_code.course_code if lec.course_allocation.course_code else None,
                    "name": lec.course_allocation.course_code.course_name.strip() if lec.course_allocation.course_code else "غير محدد"
                },
                "instructor": {
                    "id": lec.course_allocation.instructor_id if lec.course_allocation.instructor else None,
                    "name": f"{instructor_user.first_name} {instructor_user.last_name}".strip() if instructor_user else "غير محدد"
                },
                # 🔥 هاد الحقل ذهبي ومهم جداً للـ Flutter عند طلب "إضافة محاضرة تعويضية"
                "course_allocation_id": lec.course_allocation.course_allocation_id
            })

        return Response({
            "status": "success",
            "total_results": len(lectures_list),
            "data": lectures_list
        }, status=200)

    except Exception as e:
        return Response({
            "status": "error",
            "message": f"خطأ في جلب الفئات: {str(e)}"
        }, status=400)
    

@api_view(['POST', 'PUT', 'DELETE'])
@permission_classes([AllowAny])
def manage_lecture_actions(request, lecture_id):

    try:
        # 1. جلب الفئة والتأكد من وجودها مسبقاً في الجدول العام
        lecture = Lectures.objects.get(lecture_id=lecture_id)
    except Lectures.DoesNotExist:
        return Response({
            "status": "error",
            "message": f"الفئة رقم {lecture_id} غير موجودة في النظام أو تم حذفها مسبقاً."
        }, status=404)

    # 🟢 أولاً: سيناريو التعديل (إذا كان الطلب POST أو PUT)
    if request.method in ['POST', 'PUT']:
        try:
            # استقبال البيانات الجديدة من الـ Body (إذا لم يرسل الحقل، يحافظ على القيمة القديمة)
            lecture.day_of_week = request.data.get('day_of_week', lecture.day_of_week)
            lecture.start_time = request.data.get('start_time', lecture.start_time)
            lecture.end_time = request.data.get('end_time', lecture.end_time)
            lecture.room_id = request.data.get('room_id', lecture.room_id)
            lecture.lecture_type = request.data.get('lecture_type', lecture.lecture_type)
            
            lecture.save()
            
            return Response({
                "status": "success",
                "message": f"تم تحديث بيانات الفئة رقم {lecture_id} بنجاح في الجدول العام."
            }, status=200)
            
        except Exception as e:
            return Response({
                "status": "error",
                "message": f"خطأ أثناء تحديث البيانات: {str(e)}"
            }, status=400)

    # 🔴 ثانياً: سيناريو الحذف (إذا كان الطلب DELETE)
    elif request.method == 'DELETE':
        try:
            lecture.delete()
            return Response({
                "status": "success",
                "message": f"تم حذف الفئة رقم {lecture_id} بنجاح نهائي من الجدول الأسبوعي."
            }, status=200)
        except Exception as e:
            return Response({
                "status": "error",
                "message": f"حدث خطأ أثناء محاولة الحذف: {str(e)}"
            }, status=400)



#ما الو داعي 
@api_view(['GET'])
@permission_classes([AllowAny])
def get_all_courses_hours_summary(request):
    try:
        # 1. جلب كل المقررات المخزنة في النظام
        courses = Course.objects.all()
        
        if not courses.exists():
            return Response({
                "status": "success",
                "message": "لا توجد مقررات مسجلة في النظام حالياً.",
                "data": []
            }, status=status.HTTP_200_OK)
            
        courses_list = []
        
        # 2. المرور على كل مادة واستخراج الساعات بشكل عام وتفصيلي
        for course in courses:
            # ملاحظة: استخدمت getattr كحماية في حال كانت القيم null بالداتابيز لتنزل 0 بدل ما تضرب كراش
            lecture_hours = float(getattr(course, 'lecture_hours', 0.0) or 0.0) # ساعات النظري
            lab_hours = float(getattr(course, 'lab_hours', 0.0) or 0.0)         # ساعات العملي
            total_credit_hours = float(getattr(course, 'credit_hours', 0.0) or 0.0) # إجمالي الساعات المعتمدة
            
            courses_list.append({
                "course_code": course.course_code if hasattr(course, 'course_code') else str(course.pk),
                "course_name": course.course_name.strip(),
                "total_hours": total_credit_hours,  # عدد الساعات بشكل عام
                "theory_hours": lecture_hours,      # كم ساعة نظري
                "practical_hours": lab_hours        # كم ساعة عملي
            })
            
        # 3. إرجاع الرد النهائي النظيف للفرونت إند
        return Response({
            "status": "success",
            "total_courses_count": len(courses_list),
            "data": courses_list
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            "status": "error",
            "message": f"حدث خطأ أثناء جلب بيانات المقررات: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    


@api_view(['POST'])
@permission_classes([AllowAny]) 
def add_project(request):
    try:
        # 1. استقبال البيانات الأربعة القادمة من الواجهة
        instructor_id = request.data.get('instructor_id')
        project_type = request.data.get('project_type')      
        theory_hours = request.data.get('theory_hours', 0.0)
        practical_hours = request.data.get('practical_hours', 0.0)

        # 2. التحقق من الحقول الأساسية
        if not all([instructor_id, project_type]):
            return Response({
                "status": "error", 
                "message": "اسم الدكتور ونوع المشروع مطلوبان."
            }, status=status.HTTP_400_BAD_REQUEST)

        # 3. جلب بيانات الدكتور والتحقق من وجوده
        try:
            instructor = Instructor.objects.get(pk=instructor_id)
        except Instructor.DoesNotExist:
            return Response({"status": "error", "message": "الدكتور المحدد غير موجود بالسيستم."}, status=status.HTTP_404_NOT_FOUND)

        # 🎯 التعبئة التلقائية للكلية (سلسلة العلاقات)
        if instructor.department and instructor.department.faculty:
            faculty_id = instructor.department.faculty.pk
        else:
            return Response({
                "status": "error", 
                "message": "فشل سحب الكلية: يرجى التأكد من تعيين قسم للدكتور أولاً."
            }, status=status.HTTP_400_BAD_REQUEST)

        # 🎯 التعبئة التلقائية للفصل الدراسي الحالي والنشط
        try:
            current_semester = Semester.objects.get(is_active=True)
        except Semester.DoesNotExist:
            return Response({"status": "error", "message": "لا يوجد فصل دراسي نشط حالياً بالسيستم، يرجى تفعيل فصل أولاً."}, status=status.HTTP_400_BAD_REQUEST)
        except Semester.MultipleObjectsReturned:
            current_semester = Semester.objects.filter(is_active=True).first()

        # 4. التأكد من صحة خيار نوع المشروع
        valid_types = ['term_project', 'grad_1', 'grad_2']
        if project_type not in valid_types:
            return Response({
                "status": "error", 
                "message": "نوع المشروع غير صحيح."
            }, status=status.HTTP_400_BAD_REQUEST)

        # توليد العنوان تلقائياً بالخلفية فقط لإرضاء الداتابيز
        username = instructor.user.username if instructor.user else f"ID {instructor_id}"
        type_labels = {'term_project': 'فصلي', 'grad_1': 'تخرج 1', 'grad_2': 'تخرج 2'}
        generated_title = f" مشروع {type_labels[project_type]} "

        # 5. إنشاء السجل بالداتابيز
        project = GraduationProject.objects.create(
            project_title=generated_title,
            faculty_id=faculty_id,
            department_id=instructor.department.pk if instructor.department else None, 
            instructor=instructor,
            semester=current_semester, 
            project_type=project_type,
            theory_hours=float(theory_hours),
            practical_hours=float(practical_hours),
            student_names="عام / جميع المجموعات",
            assigned_day=None,
            start_time=None,
            end_time=None
        )

        # 🎯 الـ Response النظيف والمختصر متل ما بدك تماماً:
        return Response({
            "status": "success",
            "message": "تم إسناد مادة المشروع للدكتور بنجاح وتعبئة البيانات تلقائياً.",
            "data": {
                "project_id": project.project_id,
                "project_type": project.get_project_type_display(),
                "theory_hours": project.theory_hours,
                "practical_hours": project.practical_hours
            }
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ غير متوقع: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['DELETE'])
@permission_classes([AllowAny])
def delete_project(request, project_id):
    try:
        # 1. البحث عن المشروع المطلوب بناءً على الـ ID الممرر بالرابط
        try:
            project = GraduationProject.objects.get(pk=project_id)
        except GraduationProject.DoesNotExist:
            return Response({
                "status": "error",
                "message": "المشروع المطلوب غير موجود في النظام أو تم حذفه مسبقاً."
            }, status=status.HTTP_404_NOT_FOUND)

        # 2. تنفيذ عملية الحذف (بسبب CASCADE، كل الجلسات التابعة إلو رح تنحذف تلقائياً)
        project.delete()

        return Response({
            "status": "success",
            "message": "تم حذف المشروع بنجاح مع كافة الجلسات والسجلات المرتبطة به بشكل كامل."
        }, status=status.HTTP_200_OK)

    except Exception as e:
        return Response({
            "status": "error",
            "message": f"حدث خطأ غير متوقع أثناء الحذف: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([AllowAny])
def get_instructor_projects(request, instructor_id): # 👈 غيرنا البارامتر هون
    try:
        # 1. جلب الفصل الدراسي النشط حالياً بالسيستم
        try:
            current_semester = Semester.objects.get(is_active=True)
        except Semester.DoesNotExist:
            return Response({
                "status": "error", 
                "message": "لا يوجد فصل دراسي نشط حالياً بالسيستم."
            }, status=status.HTTP_400_BAD_REQUEST)
        except Semester.MultipleObjectsReturned:
            current_semester = Semester.objects.filter(is_active=True).first()

        # 2. الاستعلام المباشر عن المشاريع بناءً على الـ instructor_id
        projects = GraduationProject.objects.filter(
            instructor_id=instructor_id, # 👈 تصفية مباشرة وسريعة بالـ ID تبع الدكتور
            semester=current_semester
        )
        
        project_list = []
        
        # 3. بناء الاستجابة المختصرة والنظيفة للـ Flutter
        for p in projects:
            project_list.append({
                "project_id": p.project_id,
                "project_title": p.project_title,
                "theory_hours": p.theory_hours,
                "practical_hours": p.practical_hours
            })
            
        return Response({
            "status": "success",
            "count": len(project_list),
            "data": project_list
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            "status": "error", 
            "message": f"حدث خطأ أثناء جلب مشاريع الدكتور: {str(e)}"
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

from django.db import transaction
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework import status
from datetime import datetime, time, timedelta

@api_view(['POST'])
@permission_classes([AllowAny])
def record_project_session(request):
    try:
        # 1. جلب البيانات
        project_id = request.data.get('project_id')
        session_date_str = request.data.get('session_date')
        start_time_str = request.data.get('start_time')
        end_time_str = request.data.get('end_time')

        if not all([project_id, session_date_str, start_time_str, end_time_str]):
            return Response({"status": "error", "message": "جميع الحقول مطلوبة."}, status=status.HTTP_400_BAD_REQUEST)

        # 2. تحويل وتصحيح الوقت
        session_date = datetime.strptime(session_date_str, "%Y-%m-%d").date()
        s_time = datetime.strptime(start_time_str, "%H:%M:%S").time()
        e_time = datetime.strptime(end_time_str, "%H:%M:%S").time()

        if s_time < time(8, 0, 0):
            s_time = (datetime.combine(datetime.today(), s_time) + timedelta(hours=12)).time()
        if e_time < time(8, 0, 0):
            e_time = (datetime.combine(datetime.today(), e_time) + timedelta(hours=12)).time()

        # 3. فحص الدوام
        if s_time < time(8, 0, 0) or e_time > time(18, 30, 0):
            return Response({"status": "error", "message": "الدوام الرسمي من 8:00 صباحاً حتى 6:30 مساءً."}, status=400)

        # جلب المشروع
        project = GraduationProject.objects.get(pk=project_id)
        
        # 4. حساب الأسبوع (للمنطق الداخلي فقط)
        days_difference = (session_date - project.semester.start_date).days
        if days_difference < 0:
            return Response({"status": "error", "message": "تاريخ الجلسة قبل بدء الفصل."}, status=400)
        # week_number مستخدم للمنطق إذا احتجته لاحقاً، لكن لن نمرره للـ Database
        week_number = (days_difference // 7) + 1 

        # 5. حساب الساعات بدقة (ORM)
        start_of_week = session_date - timedelta(days=session_date.weekday())
        end_of_week = start_of_week + timedelta(days=6)

        existing_sessions = ProjectSession.objects.filter(
            project=project, session_date__range=[start_of_week, end_of_week]
        )
        
        # حساب الساعات السابقة بالثواني
        total_seconds_recorded = sum([(datetime.combine(datetime.min, s.end_time) - datetime.combine(datetime.min, s.start_time)).total_seconds() for s in existing_sessions])
        
        # حساب مدة الجلسة الحالية بالثواني
        current_seconds = (datetime.combine(datetime.min, e_time) - datetime.combine(datetime.min, s_time)).total_seconds()
        
        total_hours = (total_seconds_recorded + current_seconds) / 3600.0
        max_allowed = project.theory_hours + project.practical_hours

        # كشف السبب الحقيقي إذا كان أكبر من المسموح
        if total_hours > (max_allowed + 0.05):
            return Response({
                "status": "error", 
                "message": f"تجاوز الساعات: المحاولة ({total_hours:.2f} ساعة) بينما المسموح هو ({max_allowed:.2f} ساعة)."
            }, status=400)

        # 6. فحص التضارب مع المحاضرات الثابتة
        day_name_ar = {
            'Monday': 'الإثنين', 'Tuesday': 'الثلاثاء', 'Wednesday': 'الأربعاء',
            'Thursday': 'الخميس', 'Friday': 'الجمعة', 'Saturday': 'السبت', 'Sunday': 'الأحد'
        }.get(session_date.strftime('%A'))

        if Lectures.objects.filter(
            course_allocation__instructor=project.instructor,
            day_of_week=day_name_ar,
            start_time__lt=e_time,
            end_time__gt=s_time
        ).exists():
            return Response({"status": "error", "message": "تضارب مع محاضرة ثابتة."}, status=400)

        # 7. الحفظ باستخدام Transaction
        with transaction.atomic():
            # إنشاء TeachingLoad
            any_allocation = CourseAllocation.objects.filter(instructor=project.instructor).first()
            new_load = TeachingLoad.objects.create(
                course_allocation=any_allocation,
                attendance=True,
                lecture_date=session_date,
                is_finished=True,
                is_compensatory=False,
                start_time=s_time,
                end_time=e_time
            )

            # إنشاء الجلسة (تم حذف week_number من هنا)
            new_session = ProjectSession.objects.create(
                project=project,
                teaching_load=new_load,
                session_date=session_date,
                start_time=s_time,
                end_time=e_time
            )
        print(f"DEBUG: الرد الذي يتم إرساله هو: { {'status': 'success', 'message': 'تم تسجيل الجلسة بنجاح', 'data': {'session_id': new_session.session_id}} }")
        return Response({
            "status": "success", 
            "message": "تم تسجيل الجلسة بنجاح", 
            "session_id": new_session.session_id,  # وضعنا الـ ID في المستوى الأول
            "data": {"session_id": new_session.session_id} # أبقينا الـ data كما هي لضمان التوافق
        }, status=status.HTTP_201_CREATED)

    except Exception as e:
        return Response({"status": "error", "message": str(e)}, status=500)
  
