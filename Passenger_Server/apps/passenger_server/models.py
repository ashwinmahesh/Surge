from django.db import models

class User(models.Model):
    first_name=models.CharField(max_length=255)
    last_name=models.CharField(max_length=255)
    email=models.CharField(max_length=255)
    phone_number=models.CharField(max_length=10)
    password=models.CharField(max_length=255)
    drivingFor_id=models.IntegerField(default=-1)

class Organization(models.Model):
    name = models.CharField(max_length=255)
    description=models.CharField(max_length=300)
    created_at=models.DateTimeField(auto_now_add=True)
    poster = models.ForeignKey(User, related_name="organizations")
    approved = models.BooleanField(default=False)

# Create your models here.
