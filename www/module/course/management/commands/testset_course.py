from core.utils.commands import confirm_testset

from django.core.management.base import BaseCommand

from module.course.models.course import Course
from module.course.factories.course import CourseFactory


class Command(BaseCommand):
    help = 'Populate the database with test data for courses.'

    def handle(self, *args, **options):
        confirm_testset(self)

        # Delete existing objects
        Course.objects.all().delete()

        # Create 10 random courses
        n = 30
        for i in range(n):
            CourseFactory()
            self.stdout.write('.', ending='')

        self.stdout.write(f'\nCreated {n} courses', self.style.SUCCESS)
