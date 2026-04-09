from django.db import migrations


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0008_event_notify_enabled_event_repeat_yearly"),
    ]

    operations = [
        migrations.DeleteModel(
            name="GoogleAccount",
        ),
    ]
