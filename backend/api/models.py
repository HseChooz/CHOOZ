from django.conf import settings
from django.db import models


class GoogleAccount(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="google_account")
    sub = models.CharField(max_length=64, unique=True)
    email = models.EmailField()

    def __str__(self):
        return f"{self.email} ({self.sub})"


class YandexAccount(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="yandex_account")
    yandex_id = models.CharField(max_length=32, unique=True)
    login = models.CharField(max_length=255, blank=True)
    email = models.EmailField(blank=True)

    def __str__(self):
        return f"{self.login or self.yandex_id}"


class WishItem(models.Model):
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="wish_items")
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    image_key = models.CharField(max_length=512, blank=True, default="")

    def __str__(self):
        return self.title