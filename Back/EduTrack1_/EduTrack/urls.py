

from django.contrib import admin
from django.urls import path, include # تأكدي من إضافة include

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('api.urls')), # هاد السطر بيربط روابط تطبيق الـ api
]
