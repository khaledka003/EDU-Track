from django.shortcuts import render
from .models import Course

def course_list(request):
    courses = Course.objects.all()   
    return render(request, 'course_list.html', {'courses': courses})




from django.contrib.auth import authenticate
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

@api_view(['POST'])
@permission_classes([AllowAny])
def login_api(request):
    username = request.data.get('username')
    password = request.data.get('password')

    user = authenticate(username=username, password=password)

    if user is not None and user.is_active:
        return Response({
            'status': 'success',
            'user_id': user.id,
            'username': user.username,
            'email': user.email,
        })
    else:
        return Response({'status': 'error', 'message': 'Invalid credentials'})
