from rest_framework_json_api.exceptions import exception_handler as base_exception_handler
from rest_framework import exceptions, status


def exception_handler(exc, context):
    """
    Undo APIView.handle_exception's bullshit
    Note: Although the HTTP standard specifies "401 unauthorized",
    semantically this response means "unauthenticated"
    """
    if isinstance(exc, (exceptions.NotAuthenticated,
                        exceptions.AuthenticationFailed)):
        # exc.detail = 'Authentication Failed'
        exc.status_code = status.HTTP_401_UNAUTHORIZED

    return base_exception_handler(exc, context)
