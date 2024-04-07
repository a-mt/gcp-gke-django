import datetime

from django.test import TestCase
from django.db.models import F

from module.course.factories.course import CourseFactory


class CourseTest(TestCase):
    def test_factory(self):
        course = CourseFactory()
        self.assertIsNotNone(course.created_at)
        self.assertIsNotNone(course.name)
