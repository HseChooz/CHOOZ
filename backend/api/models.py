from django.conf import settings
from django.db import models


class GoogleAccount(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="google_account"
    )
    sub = models.CharField(max_length=64, unique=True)
    email = models.EmailField()

    def __str__(self):
        return f"{self.email} ({self.sub})"


class WishItem(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="wish_items"
    )
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)

    def __str__(self):
        return self.title
