import sys

from django.conf import settings


def confirm_testset(command):
    if not settings.DEBUG:
        msg = 'You’re launching a testset command but DEBUG is disabled. Continue anyway [y/N]? '
        command.stdout.write(msg, command.style.WARNING, ending='')

        confirm = input('')
        if confirm != 'y':
            sys.exit(1)
