from django.conf import settings
from django.db import models


class AppleAccount(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="apple_account"
    )
    apple_user_id = models.CharField(max_length=255, unique=True)
    email = models.EmailField(blank=True)
    is_private_email = models.BooleanField(default=False)

    def __str__(self):
        return self.email or self.apple_user_id


class YandexAccount(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="yandex_account"
    )
    yandex_id = models.CharField(max_length=32, unique=True)
    login = models.CharField(max_length=255, blank=True)
    email = models.EmailField(blank=True)

    def __str__(self):
        return f"{self.login or self.yandex_id}"


class WishItem(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="wish_items"
    )

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
    link = models.URLField(max_length=2000, blank=True, default="")
    price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    currency = models.CharField(
        max_length=8,
        choices=Currency.choices,
        blank=True,
        default="",
    )
    image_key = models.CharField(max_length=512, blank=True, default="")
    collection_item = models.ForeignKey(
        "CollectionItem",
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name="wish_items",
    )

    def __str__(self):
        return self.title


class Note(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="notes"
    )
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    link = models.URLField(max_length=2000, blank=True, default="")
    is_favorite = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ["-updated_at", "-id"]
        indexes = [
            models.Index(fields=["owner", "is_favorite"]),
            models.Index(fields=["owner", "updated_at"]),
        ]

    def __str__(self):
        return self.title


class CollectionSection(models.Model):
    slug = models.SlugField(max_length=64, unique=True)
    title = models.CharField(max_length=255)
    sort_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["sort_order", "id"]

    def __str__(self):
        return self.title


class Collection(models.Model):
    class Section(models.TextChoices):
        FOR_YOU = "for_you", "Подборки для вас"
        BY_CHARACTER = "by_character", "Подборки по характеру"
        EDITORIAL = "editorial", "Редакторские подборки"
        GIFT_IDEAS = "gift_ideas", "Идеи подарков"

    slug = models.SlugField(max_length=128, unique=True)
    title = models.CharField(max_length=255)
    subtitle = models.CharField(max_length=255, blank=True)
    description = models.TextField(blank=True)
    section = models.CharField(max_length=32, choices=Section.choices)
    sections = models.ManyToManyField(
        CollectionSection,
        related_name="collections",
        blank=True,
    )
    badge = models.CharField(max_length=64, blank=True)
    cover_image_url = models.URLField(blank=True, default="")
    tags = models.JSONField(default=list, blank=True)
    items_total = models.PositiveIntegerField(default=0)
    sort_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["section", "sort_order", "id"]
        indexes = [
            models.Index(fields=["section", "sort_order"]),
        ]

    def __str__(self):
        return self.title


class CollectionItem(models.Model):
    collection = models.ForeignKey(Collection, on_delete=models.CASCADE, related_name="items")
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    link = models.URLField(max_length=2000, blank=True, default="")
    price = models.DecimalField(max_digits=12, decimal_places=2, null=True, blank=True)
    currency = models.CharField(
        max_length=8,
        choices=WishItem.Currency.choices,
        blank=True,
        default="",
    )
    image_url = models.URLField(blank=True, default="")
    tags = models.JSONField(default=list, blank=True)
    sort_order = models.PositiveIntegerField(default=0)

    class Meta:
        ordering = ["sort_order", "id"]
        indexes = [
            models.Index(fields=["collection", "sort_order"]),
        ]

    def __str__(self):
        return f"{self.collection.title}: {self.title}"


class Event(models.Model):
    owner = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="events"
    )
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    link = models.URLField(max_length=2000, blank=True, default="")
    notify_enabled = models.BooleanField(default=False)
    repeat_yearly = models.BooleanField(default=False)
    date = models.DateField()

    class Meta:
        indexes = [
            models.Index(fields=["owner", "date"]),
        ]

    def __str__(self):
        return f"{self.title} ({self.date})"
