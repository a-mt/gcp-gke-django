import time
import sys

from psycopg2 import OperationalError as Psycopg2Error
from django.db.utils import OperationalError
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    """
    Wait for default database.
    """
    TIMEOUT = 30

    def handle(self, *args, **kwargs):
        db_up = False
        c = 0

        while db_up is False:
            try:
                self.check(databases=['default'])
                db_up = True
            except (Psycopg2Error, OperationalError):
                c += 1

                if c == self.TIMEOUT:
                    self.stdout.write('Timeout! Exiting...', self.style.ERROR)
                    sys.exit(1)

                self.stdout.write('Database unavailable, waiting 1 second...')
                time.sleep(1)

        self.stdout.write('Database available!', self.style.SUCCESS)
