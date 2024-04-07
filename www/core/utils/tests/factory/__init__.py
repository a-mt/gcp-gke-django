# flake8: noqa
import factory

from factory import *

from .date import DateProvider


factory.Faker.add_provider(DateProvider)
