from django.urls import path

from core.routers import noindex
from . import views

urlpatterns = [
    path('ack', views.ack),
    path('error', views.trigger_error),
    path('error-logger', views.trigger_error_with_extra),
]
