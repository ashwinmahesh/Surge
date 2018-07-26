from django.shortcuts import render, HttpResponse, redirect
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import bcrypt
from apps.passenger_server.models import *
from djangounchained_flash import ErrorManager, getFromSession

def index(request):
    if 'flash' not in request.session:
        request.session['flash']=ErrorManager().addToSession()
    if 'loggedIn' in request.session and request.session['loggedIn']==True:
        if 'userID' in request.session and len(User.objects.filter(id=request.session['userID']))==1:
            if User.objects.get(id=request.session['userID']).user_level==9:
                return redirect('/main')
    e=getFromSession(request.session['flash'])
    context={
        'email_error':e.getMessages('email_error'),
        'password_error':e.getMessages('password_error'),
        'main_error':e.getMessages('main_error')
    }
    request.session['flash']=e.addToSession()
    return render(request,'passenger_server/login.html', context)

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
    users = User.objects.filter(drivingFor_id=org.id)
    for user in users:
        user.drivingFor_id=-1
        user.save()
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
    if user.drivingFor_id!=-1:
        if len(Organization.objects.filter(id=user.drivingFor_id))==1:
            org = Organization.objects.get(id=user.drivingFor_id)
            org.drivers-=1
            org.save()
    user.drivingFor_id = request.POST['orgID']
    user.save()
    org = Organization.objects.get(id=request.POST['orgID'])
    org.drivers+=1
    org.save()
    return JsonResponse({'response':'Driver added'})

@csrf_exempt
def getOrgDrivers(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    users = User.objects.filter(drivingFor_id=int(request.POST['orgID']))
    org_name = Organization.objects.get(id=int(request.POST['orgID'])).name
    output=[]
    for user in users:
        phoneNumber=user.phone_number
        phoneNew = "(" + user.phone_number[0:3] + ") " + user.phone_number[3:6] + "-" + user.phone_number[6:]
        userDict = {'first_name':user.first_name, 'last_name':user.last_name, 'email':user.email, 'phone_number':phoneNew, 'phone_raw':phoneNumber}
        output.append(userDict)
    response ={'users':output}
    return JsonResponse({'response':response, 'organization':org_name})

@csrf_exempt
def removeDriver(request):
    if request.method!='POST':
        return HttpResponse("This page is accessible by POST only!")
    print(request.POST)
    user = User.objects.get(email=request.POST['email'])
    org = Organization.objects.get(id=user.drivingFor_id)
    org.drivers-=1
    org.save()
    user.drivingFor_id=-1
    user.save()
    return JsonResponse({'response':'success'})

@csrf_exempt
def fetchAllActive(request):
    orgs = Organization.objects.filter(drivers__gt=0).filter(approved=True)
    output=[]
    for org in orgs:
        org_data={'name':org.name, 'drivers':org.drivers, 'queue_count':len(org.passengers.all()), 'id':org.id}
        output.append(org_data)
    # response={'organizations':list(orgs)}
    response={'organizations':output}
    # response={'organizations':list(orgs)}
    return JsonResponse({'response':response})

@csrf_exempt
def searchFor(request):
    if request.method!='POST':
        return HttpResponse("Posting only. Sorry pal.")
    print(request.POST)
    orgs = Organization.objects.filter(drivers__gt=0).filter(approved=True).filter(name__contains=request.POST['key'])
    output=[]
    for org in orgs:
        org_data={'name':org.name, 'drivers':org.drivers, 'queue_count':len(org.passengers.all()), 'id':org.id}
        output.append(org_data)
    # response={'organizations':list(orgs)}
    response={'organizations':output}
    return JsonResponse({'response':response})

@csrf_exempt
def joinQueue(request):
    if request.method!='POST':
        return HttpResponse("Posting only. Sorry pal.")
    print(request.POST)
    if len(User.objects.filter(id=request.POST['userID']))==0 or len(Organization.objects.filter(id=request.POST['orgID']))==0:
        return JsonResponse({'response':'bad'})
    user = User.objects.get(id=request.POST['userID'])
    org = Organization.objects.get(id=request.POST['orgID'])
    user.queue=org
    user.longitude = request.POST['long']
    user.latitude = request.POST['lat']
    user.location = request.POST['address']
    user.save()
    return JsonResponse({'response':'added'})

@csrf_exempt
def getQueuePos(request):
    if request.method!='POST':
        return HttpResponse("Posting only. Sorry pal.")
    print(request.POST)
    if len(User.objects.filter(id=request.POST['userID']))==0 or len(Organization.objects.filter(id=request.POST['orgID']))==0:
        return JsonResponse({'response':'bad'})
    org = Organization.objects.get(id=request.POST['orgID'])
    passengers = org.passengers.all()
    counter=0
    for passenger in passengers:
        counter+=1
        print("Passenger Id: ",passenger.id)
        if passenger.id == request.POST['userID']:
            break
        
    return JsonResponse({'response':'Got your request baby!', 'position':counter, 'organization':org.name})

@csrf_exempt
def getQueuedOrganization(request):
    if request.method!='POST':
        return HttpResponse("Posting only. Sorry pal.")
    print(request.POST)
    user = User.objects.get(id=request.POST['userID'])
    print('Request.POST[orgID]:',request.POST['orgID'])
    if user.queue is None or user.queue.id!=int(request.POST['orgID']):
        return JsonResponse({'response':'not in line'})
    return JsonResponse({'response':'in line'})

@csrf_exempt
def removeFromQueue(request):
    if request.method!='POST':
        return HttpResponse("Posting only. Sorry pal.")
    print(request.POST)
    user = User.objects.get(id=int(request.POST['userID']))
    user.queue=None
    user.driver_id=-1
    user.location=''
    user.longitude = ''
    user.latitude = ''
    user.driver_id=-1
    user.save()
    return JsonResponse({'response':'success'})

@csrf_exempt
def getDrivingForId(request):
    if request.method!='POST':
        return HttpResponse("Posting only. Sorry pal.")
    print(request.POST)
    user = User.objects.get(id=int(request.POST['userID']))
    return JsonResponse({'response':'success', 'drivingFor_ID':user.drivingFor_id})

@csrf_exempt
def fetchQueue(request):
    if request.method!='POST':
        return HttpResponse("You must post.")
    print(request.POST)
    if len(Organization.objects.filter(id=int(request.POST['orgID'])))==0:
        return JsonResponse({'response':'Could not find organization'})
    queue_raw = Organization.objects.get(id=int(request.POST['orgID'])).passengers.all()
    org_name = Organization.objects.get(id=int(request.POST['orgID'])).name
    queue=[]
    for user in queue_raw:
        phoneNumber=user.phone_number
        phoneNew = "(" + user.phone_number[0:3] + ") " + user.phone_number[3:6] + "-" + user.phone_number[6:]
        driver=""
        if user.driver_id!=-1:
            driver = User.objects.get(id=user.driver_id).first_name + " " + User.objects.get(id=user.driver_id).last_name
        info={'id':user.id, 'first_name':user.first_name, 'last_name':user.last_name, 'email':user.email, 'phone_number':phoneNew, 'lat':user.latitude, 'long':user.longitude, 'driver_id':user.driver_id, 'location':user.location, 'driver':driver, 'phone_raw':phoneNumber}
        queue.append(info)
    return JsonResponse({'response':'Fetched your queue', 'queue':list(queue), 'name':org_name})
    
@csrf_exempt
def assignPassengerDriver(request):
    if request.method!='POST':
        return HttpResponse('Posting only. Sorry pal.')
    print(request.POST)
    driverID = int(request.POST['driverID'])
    passengerID = int(request.POST['passengerID'])
    if len(User.objects.filter(id=driverID))==0 or len(User.objects.filter(id=passengerID))==0:
        return JsonResponse({'response':'Unable to pick this person up'})
    passenger = User.objects.get(id=passengerID)
    if passenger.driver_id!=-1:
        return JsonResponse({'response':'Unable to pick this person up'})
    passenger.driver_id=driverID
    passenger.save()
    return JsonResponse({'response':'We have assigned the driver'})

@csrf_exempt
def removePassengerDriver(request):
    if request.method!='POST':
        return HttpResponse('Posting only. Sorry pal.')
    print(request.POST)
    passengerID = int(request.POST['passengerID'])
    if len(User.objects.filter(id=passengerID))==0:
        return JsonResponse({'response':'Could not find this passenger'})
    passenger = User.objects.get(id=passengerID)
    passenger.driver_id=-1
    passenger.save()
    return JsonResponse({'response':'success'})

def processAdminLogin(request):
    if request.method!='POST':
        return redirect('/')
    e=getFromSession(request.session['flash'])
    if len(User.objects.filter(email=request.POST['email']))==0:
        e.addMessage("Email does not exist in server", "email_error")
        request.session['flash']=e.addToSession()
        return redirect('/')
    if not bcrypt.checkpw(request.POST['password'].encode(), User.objects.get(email=request.POST['email']).password.encode()):
        e.addMessage("Invalid password", "password_error")
        request.session['flash']=e.addToSession()
        return redirect('/')
    if User.objects.get(email=request.POST['email']).user_level!=9:
        e.addMessage("User does not have admin privileges", "main_error")
        request.session['flash']=e.addToSession()
        return redirect('/')
    request.session['loggedIn']=True
    request.session['userID']=User.objects.get(email=request.POST['email']).id
    return redirect('/main')

def main(request):
    if 'loggedIn' not in request.session:
        return redirect('/')
    if 'userID' not in request.session:
        return redirect('/')
    if request.session['loggedIn']==False:
        return redirect('/')
    if len(User.objects.filter(id=request.session['userID']))==0:
        return redirect('/')
    if User.objects.get(id=request.session['userID']).user_level!=9:
        return redirect('/')
    context={
        'orgs': Organization.objects.filter(approved=False),
        'orgs_approved':Organization.objects.filter(approved=True)
        }
    return render(request, 'passenger_server/main.html', context)

def approvePost(request):
    if request.method!='POST':
        return redirect('/')
    if 'loggedIn' not in request.session:
        return redirect('/')
    if 'userID' not in request.session:
        return redirect('/')
    if request.session['loggedIn']==False:
        return redirect('/')
    if len(User.objects.filter(id=request.session['userID']))==0:
        return redirect('/')
    if User.objects.get(id=request.session['userID']).user_level!=9:
        return redirect('/')
    org = Organization.objects.get(id=request.POST['org_id'])
    org.approved=True
    org.save()
    return redirect('/main/')

def rejectPost(request):
    if request.method!='POST':
        return redirect('/')
    if 'loggedIn' not in request.session:
        return redirect('/')
    if 'userID' not in request.session:
        return redirect('/')
    if request.session['loggedIn']==False:
        return redirect('/')
    if len(User.objects.filter(id=request.session['userID']))==0:
        return redirect('/')
    if User.objects.get(id=request.session['userID']).user_level!=9:
        return redirect('/')
    org = Organization.objects.get(id=request.POST['org_id'])
    org.delete()
    return redirect('/main/')

def processAdminLogout(request):
    request.session.clear()
    return redirect('/')
