import logging

from django.http import HttpResponse


logger = logging.getLogger('core')


def ack(request):
    """
    Check if the app is up and running
    """
    return HttpResponse(status=204)


def trigger_error(request):
    """
    Check that an uncaught error is send to sentry
    """
    return 1 / 0


def trigger_error_with_extra(request):
    """
    Check that a logged error is send to sentry
    """
    try:
        return 1 / 0
    except Exception:
        logger.error(
            "Can't do division by zero",
            exc_info=True,
            extra={'data': {'number': 1, 'divider': 0}},
        )
    return HttpResponse('ok')
