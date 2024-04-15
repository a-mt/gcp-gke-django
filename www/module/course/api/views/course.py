from rest_framework.viewsets import GenericViewSet
from rest_framework import mixins

from django_filters.filters import CharFilter
from django_filters.rest_framework import FilterSet, DjangoFilterBackend

from module.course.api.serializers.course import (
    CourseSerializer,
    CourseListSerializer,
)
from module.course.models.course import Course


class CourseFilterSet(FilterSet):
    """
    Fields we can filter our list on
    """
    name = CharFilter(method='filter_name')

    def filter_name(self, queryset, name, value):
        return queryset.filter(name__icontains=value)

    class Meta:
        model = Course
        fields = (
            'id',
            'name',
            'created_at',
            'updated_at',
        )


class CourseViewSet(
    mixins.CreateModelMixin,
    mixins.UpdateModelMixin,
    mixins.ListModelMixin,
    mixins.RetrieveModelMixin,
    GenericViewSet,
):
    """
    View to list/get/create/update a course
    """
    queryset = Course.objects.all()
    serializer_class = CourseSerializer

    filter_backends = (DjangoFilterBackend,)
    filterset_class = CourseFilterSet

    def get_permissions(self):

        # Anyone can see the list
        if self.action == 'list':
            return []

        # Fallback to the default permissions (is authenticated)
        return super().get_permissions()

    def get_serializer_class(self):
        if self.action == 'list':
            return CourseListSerializer

        return self.serializer_class
