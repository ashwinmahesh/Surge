from django.conf.urls import url
from . import views

urlpatterns=[
    url(r'^$', views.index),
    url(r'^processRegister/$', views.processRegister),
    url(r'^processLogin/$', views.processLogin),
    url(r'^processOrgRegister/$', views.processOrgRegister),
    url(r'^getYourOrganizations/$', views.getYourOrganizations),
    url(r'^deleteOrganization/$', views.deleteOrganization),
    url(r'^assignDriver/$', views.assignDriver),
    url(r'^getOrgDrivers/$', views.getOrgDrivers),
    url(r'^removeDriver/$', views.removeDriver),
    url(r'^fetchAllActive/$', views.fetchAllActive),
    url(r'^searchFor/$', views.searchFor),
    url(r'^joinQueue/$', views.joinQueue),
    url(r'^getQueuePosition/$', views.getQueuePos),
    url(r'^getQueuedOrganization/$', views.getQueuedOrganization),
    url(r'^removeFromQueue/$', views.removeFromQueue),
    url(r'^getDrivingForId/$', views.getDrivingForId),
    url(r'^fetchQueue/$', views.fetchQueue),
    url(r'^assignPassengerDriver/$', views.assignPassengerDriver),
    url(r'^removePassengerDriver/$', views.removePassengerDriver),
    url(r'^processAdminLogin/$', views.processAdminLogin)
]