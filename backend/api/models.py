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

    class Currency(models.TextChoices):
        RUB = "rub", "RUB"
        USD = "usd", "USD"
        EUR = "eur", "EUR"
        BYN = "byn", "BYN"
        KZT = "kzt", "KZT"
        JPY = "jpy", "JPY"
        KRW = "krw", "KRW"
        TRY = "try", "TRY"
        AED = "aed", "AED"
        ILS = "ils", "ILS"
        UZS = "uzs", "UZS"
        KGS = "kgs", "KGS"
        GBP = "gbp", "GBP"
        CHF = "chf", "CHF"
        UAH = "uah", "UAH"
        PLN = "pln", "PLN"

    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    link = models.URLField(blank=True, default="")
    price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    currency = models.CharField(max_length=8, choices=Currency.choices, blank=True, default="")
    image_key = models.CharField(max_length=512, blank=True, default="")

    def __str__(self):
        return self.title


class Event(models.Model):
    owner = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="events")
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    link = models.URLField(blank=True, default="")
    notify_enabled = models.BooleanField(default=False)
    repeat_yearly = models.BooleanField(default=False)
    date = models.DateField()

    class Meta:
        indexes = [
            models.Index(fields=["owner", "date"]),
        ]

    def __str__(self):
        return f"{self.title} ({self.date})"