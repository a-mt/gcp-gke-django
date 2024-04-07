from rest_framework_json_api.exceptions import exception_handler as base_exception_handler
from rest_framework import exceptions, status

from django.utils.translation import gettext_lazy as _


def exception_handler(exc, context):
    """
    Undo APIView.handle_exception's bullshit
    Note: Although the HTTP standard specifies "401 unauthorized",
    semantically this response means "unauthenticated"
    """
    if isinstance(exc, (exceptions.NotAuthenticated,
                        exceptions.AuthenticationFailed)):
        exc.detail = "La force n’est pas avec toi!"
        exc.status_code = status.HTTP_401_UNAUTHORIZED

    return base_exception_handler(exc, context)
