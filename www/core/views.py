import json
import os

from django.conf import settings
from django.http import HttpResponse


def about(request):
    data = json.dumps({
        'env': 'prod' if 'PRODUCTION' in os.environ else 'dev',
        'debug': settings.DEBUG,
        'commit-sha': settings.COMMIT_SHA,
    })
    return HttpResponse(data, content_type='application/json')
