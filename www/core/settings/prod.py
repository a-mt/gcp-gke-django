# flake8: noqa
import sys
from .defaults import *

# .myproject.local
if cookie_domain := os.getenv('COOKIE_DOMAIN', None):
    ALLOWED_HOSTS.append(cookie_domain)
    SESSION_COOKIE_DOMAIN = cookie_domain
    CSRF_COOKIE_DOMAIN = cookie_domain

# http://www.myproject.local
if hosts := os.getenv('CSRF_TRUSTED_ORIGINS', None):
    for x in hosts.split(','):
        CSRF_TRUSTED_ORIGINS.append(x)

# Just in case
if hosts := os.getenv('ADDITIONAL_ALLOWED_HOSTS', None):
    for x in hosts.split(','):
        ALLOWED_HOSTS.append(x)
