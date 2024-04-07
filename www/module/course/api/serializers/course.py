from rest_framework_json_api import serializers

from module.course.models.course import Course


class CourseListSerializer(serializers.ModelSerializer):
    class Meta:
        ordering = ['-id']
        model = Course
        fields = (
            'id',
            'name',
            'created_at',
            'updated_at',
        )


class CourseSerializer(serializers.ModelSerializer):
    class Meta:
        ordering = ['-id']
        model = Course
        fields = (
            'id',
            'name',
            'created_at',
            'updated_at',
        )
