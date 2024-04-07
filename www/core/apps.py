from django.apps import AppConfig


class CoreConfig(AppConfig):
    """
    Handles core functionalities
    - users and authentication
    - pretty abstract code, transverse to many functionalities
    """
    name = 'core'
    label = 'core'
