from django.conf.urls import url
from . import views

urlpatterns=[
    url(r'^$', views.index),
    url(r'^processRegister/$', views.processRegister),
    url(r'^processLogin/$', views.processLogin),
]