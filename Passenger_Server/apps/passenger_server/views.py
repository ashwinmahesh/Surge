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
        return JsonResponse({'response':'Login successful', 'first_name':user.first_name, 'last_name':user.last_name, 'email':user.email, 'phone_number':user.phone_number, 'id':user.id})
    return JsonResponse({'response':'Password does not match user'})

@csrf_exempt
def processOrgRegister(request):
    if request.method!='POST':
        return HttpResponse("You are not posting!")
    print(request.POST)
    if len(Organization.objects.filter(name=request.POST['name']))==1:
        return JsonResponse({'response':'invalid'})
    Organization.objects.create(name=request.POST['name'], description=request.POST['description'], poster = User.objects.get(id=request.POST['userID']))
    return JsonResponse({'response':'Successfully created organization!'})

@csrf_exempt
def getYourOrganizations(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    user=User.objects.get(id=int(request.POST['id']))
    orgs = Organization.objects.filter(poster=user).values()
    response={'organizations':list(orgs)}
    return JsonResponse({'response':response})

@csrf_exempt
def deleteOrganization(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    if len(Organization.objects.filter(id=request.POST['id']))==0:
        return JsonResponse({'response':'Organization does not exist'})
    org= Organization.objects.get(id=request.POST['id'])
    org.delete()
    return JsonResponse({'response':'Organization successfully deleted'})

@csrf_exempt
def assignDriver(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    if len(User.objects.filter(email=request.POST['email']))==0:
        return JsonResponse({'response':'User does not exist'})
    user = User.objects.get(email=request.POST['email'])
    user.drivingFor_id = request.POST['orgID']
    user.save()
    return JsonResponse({'response':'Driver added'})

@csrf_exempt
def getOrgDrivers(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    users = User.objects.filter(drivingFor_id=int(request.POST['orgID']))
    output=[]
    for user in users:
        phoneNumber=user.phone_number
        phoneNew = "(" + user.phone_number[0:3] + ") " + user.phone_number[3:6] + "-" + user.phone_number[6:]
        userDict = {'first_name':user.first_name, 'last_name':user.last_name, 'email':user.email, 'phone_number':phoneNew}
        output.append(userDict)
    response ={'users':output}
    return JsonResponse({'response':response})

@csrf_exempt
def removeDriver(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    user = User.objects.get(email=request.POST['email'])
    user.drivingFor_id=-1
    user.save()
    return JsonResponse({'response':'success'})


# Create your views here.
