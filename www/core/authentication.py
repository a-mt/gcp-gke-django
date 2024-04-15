from django.contrib.auth.models import AnonymousUser
from django.conf import settings

from rest_framework.authentication import (
    TokenAuthentication as BaseTokenAuthentication,
)
from rest_framework.exceptions import AuthenticationFailed


class TokenUser(AnonymousUser):
    is_authenticated = True


class TokenAuthentication(BaseTokenAuthentication):
    """
    Simple token based authentication.

    Clients should authenticate by passing the token key in the "Authorization"
    HTTP header, prepended with the string "Token ".  For example:

        Authorization: Token 401f7ac837da42b97f613d789819ff93537bee6a
    """
    """
    def authenticate(self, request):
        if settings.DEBUG:
            import ipaddress

            # When testing with swagger locally: allow 192.168.x.x
            if ipaddress.ip_address(request.META.get('REMOTE_ADDR')).is_private:
                return self.authenticate_credentials(settings.AUTH_API_TOKEN)

        return super().authenticate(request)
    """
    keyword = 'Token'

    def authenticate_credentials(self, key):
        if key != settings.AUTH_API_TOKEN:
            raise AuthenticationFailed()

        return (TokenUser(), key)
