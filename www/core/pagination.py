from rest_framework.pagination import PageNumberPagination as BasePageNumberPagination
from rest_framework.response import Response
from collections import OrderedDict


class PageNumberPagination(BasePageNumberPagination):
    page_query_param = 'page'
    page_query_description = 'A page number within the paginated result set.'

    page_size_query_param = 'pagesize'
    page_size_query_description = 'Number of results to return per page.'

    page_size = 10
    max_page_size = 50

    #+----------------------------------------------------
    #| Response
    #+----------------------------------------------------

    def get_paginated_response(self, data):
        return Response({
            'results': data,
            'meta': self.get_paginated_meta_response()
        })

    def get_paginated_meta_response(self):
        return {
            'pagination': {
                'page': self.page.number,
                'pages': self.page.paginator.num_pages,
                'count': self.page.paginator.count,
                'pagesize': self.page.paginator.per_page,
                'next': self.get_next_link(),
                'previous': self.get_previous_link(),
            }
        }

    #+----------------------------------------------------
    #| Schema
    #+----------------------------------------------------

    def get_paginated_response_schema(self, schema):
        return {
            'type': 'object',
            'properties': {
                'results': schema,
                'meta': self.get_paginated_response_meta_schema(),
            },
        }

    def get_paginated_response_meta_schema(self):
        return {
            'type': 'object',
            'properties': {
                'pagination': self.get_paginated_response_meta_pagination_schema(),
            }
        }

    def get_paginated_response_meta_pagination_schema(self):
        return {
            'type': 'object',
            'properties': {
                'page': {
                    'type': 'integer',
                    'example': 1,
                },
                'pages': {
                    'type': 'integer',
                    'example': 10,
                },
                'count': {
                    'type': 'integer',
                    'example': 90,
                },
                'pagesize': {
                    'type': 'integer',
                    'example': self.max_page_size,
                },
                'next': {
                    'type': 'string',
                    'nullable': True,
                    'format': 'uri',
                    'example': 'http://api.example.org/accounts/?{page_query_param}=4'.format(
                        page_query_param=self.page_query_param)
                },
                'previous': {
                    'type': 'string',
                    'nullable': True,
                    'format': 'uri',
                    'example': 'http://api.example.org/accounts/?{page_query_param}=2'.format(
                        page_query_param=self.page_query_param)
                },
            }
        }
