import datetime
from dateutil.relativedelta import relativedelta

from django.db import models
from django.utils.translation import gettext_lazy as _


class Course(
    models.Model,
):
    created_at = models.DateTimeField(auto_now_add=True, db_index=True)
    updated_at = models.DateTimeField(auto_now=True)

    name = models.CharField(
        _('name'),
        max_length=255,
        blank=False,
        null=False,
    )

    class Meta:
        ordering = ['created_at']