import datetime
import random

from faker.providers import BaseProvider


randgen = random.Random()
randgen.state_set = False

PAST_DATE = datetime.date(1950, 1, 1)


class DateProvider(BaseProvider):
    """
    Date provider

    To add this provider to faker:
        factory.Faker.add_provider(DateProvider)

    To create a date using this provider:
        factory.Faker("date_between")
    """

    @classmethod
    def date_between(cls, start_date, end_date=None):
        if end_date is None:
            end_date = datetime.date.today()

        rand = randgen.randint(start_date.toordinal(), end_date.toordinal())
        return datetime.date.fromordinal(rand)

    @classmethod
    def past_date(cls):
        return cls.date_between(PAST_DATE)
