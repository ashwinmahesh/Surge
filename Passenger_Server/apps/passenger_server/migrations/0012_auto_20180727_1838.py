# -*- coding: utf-8 -*-
# Generated by Django 1.10 on 2018-07-27 18:38
from __future__ import unicode_literals

import datetime
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('passenger_server', '0011_user_queue_at'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='user',
            name='queue_at',
        ),
        migrations.AddField(
            model_name='user',
            name='queued_at',
            field=models.DateTimeField(default=datetime.datetime(2018, 7, 27, 18, 38, 38, 909871), null=True),
        ),
    ]
