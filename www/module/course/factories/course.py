from core.utils.tests import factory

from module.course.models.course import Course



class CourseFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Course

    created_at = factory.Faker('past_date')
    name = factory.Faker('word')

    @factory.post_generation
    def post_generation(obj, create, extracted, **kwargs):
        obj.updated_at = obj.created_at
