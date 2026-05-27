from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0017_sync_collections_from_spreadsheet"),
    ]

    operations = [
        migrations.CreateModel(
            name="WishlistShareLink",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True,
                        primary_key=True,
                        serialize=False,
                        verbose_name="ID",
                    ),
                ),
                ("token", models.CharField(db_index=True, max_length=64, unique=True)),
                ("is_enabled", models.BooleanField(default=True)),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "owner",
                    models.OneToOneField(
                        on_delete=models.deletion.CASCADE,
                        related_name="wishlist_share_link",
                        to=settings.AUTH_USER_MODEL,
                    ),
                ),
            ],
        ),
    ]
