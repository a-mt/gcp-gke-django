# flake8: noqa
import os
import sys

if 'CI_PIPELINE' in os.environ:
    try:
        from .cicd import *  # noqa
    except ImportError:
        raise Exception(f'The CI/CD settings could not be found in {os.path.dirname(__file__)}/cicd')
elif 'PRODUCTION' in os.environ:
    try:
        from .prod import *  # noqa
    except ImportError:
        raise Exception(f'The development settings could not be found in {os.path.dirname(__file__)}/prod')
else:
    try:
        from .dev import *  # noqa
    except ImportError:
        raise Exception(f'The development settings could not be found in {os.path.dirname(__file__)}/dev')
