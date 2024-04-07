# flake8: noqa
import os
import sys

if 'PRODUCTION' in os.environ:
    try:
        from .prod import *  # noqa
    except ImportError:
        raise Exception(f'The development settings could not be found in {os.path.dirname(__file__)}/prod')
else:
    try:
        from .dev import *  # noqa
    except ImportError:
        raise Exception(f'The development settings could not be found in {os.path.dirname(__file__)}/dev')
