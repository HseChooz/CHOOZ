import secrets
from dataclasses import dataclass

from django.urls import reverse

from api.graphql.wish_items.service import to_wish_item_type
from api.models import WishItem, WishlistShareLink


def _generate_token() -> str:
    return secrets.token_urlsafe(24)


def build_share_path(token: str) -> str:
    return reverse("public-wishlist", kwargs={"token": token})


def build_share_url(request, token: str) -> str:
    return request.build_absolute_uri(build_share_path(token))


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


@dataclass(frozen=True)
class PublicWishlistItem:
    title: str
    description: str
    link: str | None
    price: object | None
    currency_label: str | None
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
                price=item.price,
                currency_label=item.get_currency_display() if item.currency else None,
                image_url=wish_item.image_url,
            )
        )
    return result
