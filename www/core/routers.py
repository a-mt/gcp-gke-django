from django.http import Http404
from django.urls import path

from rest_framework import routers


def noindex(request):
    raise Http404


class SimpleRouter(routers.SimpleRouter):
    root_view_name = 'api-noindex'
    include_root_view = True

    def __init__(self, *args, **kwargs):
        kwargs.setdefault('trailing_slash', False)

        super().__init__(*args, **kwargs)

    def get_urls(self):
        urls = super().get_urls()

        if self.include_root_view:
            root_url = path(r'', noindex, name=self.root_view_name)
            urls.append(root_url)

        return urls
