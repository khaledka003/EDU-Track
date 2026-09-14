from django.urls import path
from . import views

urlpatterns = [
    path('api/login/', views.login_api, name='login_api'),
    path('courses/', views.course_list, name='course_list'),
]
