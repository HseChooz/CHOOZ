import secrets
from dataclasses import dataclass
from decimal import Decimal

from django.urls import reverse

from api.graphql.wish_items.service import to_wish_item_type
from api.models import WishItem, WishlistShareLink


def _generate_token() -> str:
    return secrets.token_urlsafe(24)


def build_share_path(token: str) -> str:
    return reverse("public-wishlist", kwargs={"token": token})


def build_share_url(request, token: str) -> str:
    return request.build_absolute_uri(build_share_path(token))


def build_app_open_url(token: str) -> str:
    return f"chooz://wishlist/{token}"


def get_or_create_share_link(user) -> WishlistShareLink:
    share_link, created = WishlistShareLink.objects.get_or_create(
        owner=user,
        defaults={
            "token": _generate_token(),
            "is_enabled": True,
        },
    )
    if created:
        return share_link

    if not share_link.token:
        share_link.token = _generate_token()
        share_link.save(update_fields=["token", "updated_at"])
    return share_link


def get_or_create_enabled_share_link(user, request) -> WishlistShareLink:
    share_link = get_or_create_share_link(user)
    if not share_link.is_enabled:
        share_link.is_enabled = True
        share_link.save(update_fields=["is_enabled", "updated_at"])
    return share_link


def disable_share_link(user, request) -> WishlistShareLink:
    share_link = get_or_create_share_link(user)
    if share_link.is_enabled:
        share_link.is_enabled = False
        share_link.save(update_fields=["is_enabled", "updated_at"])
    return share_link


def regenerate_share_link(user, request) -> WishlistShareLink:
    share_link = get_or_create_share_link(user)
    share_link.token = _generate_token()
    share_link.is_enabled = True
    share_link.save(update_fields=["token", "is_enabled", "updated_at"])
    return share_link


def get_public_share_by_token(token: str) -> WishlistShareLink | None:
    return WishlistShareLink.objects.select_related("owner").filter(token=token).first()


def public_display_name(user) -> str:
    full_name = " ".join(
        part.strip()
        for part in [user.first_name, user.last_name]
        if part and part.strip()
    )
    return full_name or user.username


CURRENCY_SYMBOLS = {
    "rub": "₽",
    "usd": "$",
    "eur": "€",
    "byn": "Br",
    "kzt": "₸",
    "jpy": "¥",
    "krw": "₩",
    "try": "₺",
    "aed": "د.إ",
    "ils": "₪",
    "uzs": "сўм",
    "kgs": "с",
    "gbp": "£",
    "chf": "CHF",
    "uah": "₴",
    "pln": "zł",
}


def public_currency_symbol(currency: str | None) -> str | None:
    key = (currency or "").strip().casefold()
    if not key:
        return None
    return CURRENCY_SYMBOLS.get(key)


def format_public_price(value) -> str | None:
    if value is None:
        return None

    formatted = f"{Decimal(value):.2f}".rstrip("0")
    if formatted.endswith("."):
        formatted += "0"
    return formatted


@dataclass(frozen=True)
class PublicWishlistItem:
    title: str
    description: str
    link: str | None
    price_display: str | None
    currency_symbol: str | None
    image_url: str | None


def get_public_wishlist_items(user, *, request=None) -> list[PublicWishlistItem]:
    items = (
        WishItem.objects.filter(owner=user)
        .select_related("collection_item")
        .order_by("-id")
    )
    result: list[PublicWishlistItem] = []
    for item in items:
        wish_item = to_wish_item_type(item, request=request)
        result.append(
            PublicWishlistItem(
                title=wish_item.title,
                description=wish_item.description,
                link=wish_item.link,
                price_display=format_public_price(item.price),
                currency_symbol=public_currency_symbol(item.currency),
                image_url=wish_item.image_url,
            )
        )
    return result
