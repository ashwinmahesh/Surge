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
]