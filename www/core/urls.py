"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from core.views import about
from django.conf import settings
from django.urls import path, include

urlpatterns = [
    path('about/', about),
    path('healthcheck/', include('core.healthcheck.urls')),
    path('api/', include(('core.api.urls', 'api'), namespace='api')),
]

# If DEBUG: list subpages, otherwise about page
if not settings.DEBUG:
    urlpatterns += [
        path('', about),
    ]

# Add Swagger
try:
    if not settings.SWAGGER_SETTINGS:
        raise AttributeError

    from rest_framework import permissions
    from drf_yasg.views import get_schema_view
    from drf_yasg import openapi
    from django.contrib.auth import views as auth_views

    schema_view = get_schema_view(
        openapi.Info(
            title='API',
            default_version='v1',
        ),
        public=True,
        permission_classes=[permissions.AllowAny],
    )
    urlpatterns += [
        path('swagger/', schema_view.with_ui('swagger', cache_timeout=0)),
        path('accounts/login/', auth_views.LoginView.as_view(), name='login'),
        path('accounts/logout/', auth_views.LogoutView.as_view(), name='logout'),
    ]

except AttributeError:
    pass
