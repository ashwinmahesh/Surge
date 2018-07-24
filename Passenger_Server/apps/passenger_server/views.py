from django.shortcuts import render, HttpResponse, redirect
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import bcrypt
from apps.passenger_server.models import *

def index(request):
    return JsonResponse({'result':'Set up is good!'})

@csrf_exempt
def processRegister(request):
    if request.method!='POST':
        return HttpResponse('You are not posting!')
    print(request.POST)
    email = request.POST['email']
    if len(User.objects.filter(email=email))>0:
        return JsonResponse({'response':'bad'})
    password=request.POST['password']
    hashedPW = bcrypt.hashpw(password.encode(), bcrypt.gensalt())
    User.objects.create(first_name=request.POST['first_name'], last_name=request.POST['last_name'], email = email, phone_number=request.POST['phone'], password=hashedPW)
    print("Successful registration")
    return JsonResponse({'response':'Registration successful'})

@csrf_exempt
def processLogin(request):
    if request.method!='POST':
        return HttpResponse('You are not posting!')
    print(request.POST)
    email=request.POST['email']
    password = request.POST['password']
    if len(User.objects.filter(email=email))==0:
        return JsonResponse({'response':'User does not exist'})
    user = User.objects.get(email=email)
    if bcrypt.checkpw(password.encode(), user.password.encode()):
        return JsonResponse({'response':'Login successful'})
    return JsonResponse({'response':'Password does not match user'})

# Create your views here.
