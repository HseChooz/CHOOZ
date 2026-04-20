import re

from api.graphql.errors import gql_error
from api.graphql.types import WishItemType
from api.models import WishItem
from api.storage.minio import presigned_get_url

INLINE_URL_RE = re.compile(r"https?://[^\s]+", re.IGNORECASE)
TRAILING_URL_PUNCTUATION = ".,!?;:)]}>"


def require_user(info):
    user = info.context.request.user
    if not user or not user.is_authenticated:
        gql_error("UNAUTHORIZED", "Unauthorized")
    return user


def get_owned_wish_item(user, wish_item_id: str) -> WishItem:
    try:
        return WishItem.objects.get(id=wish_item_id, owner=user)
    except WishItem.DoesNotExist:
        gql_error("WISH_ITEM_NOT_FOUND", "Wish item not found")


def normalize_wish_note_fields(description: str, link: str | None) -> tuple[str, str]:
    normalized_description = (description or "").strip()
    normalized_link = (link or "").strip()

    if normalized_link:
        return normalized_description, normalized_link

    match = INLINE_URL_RE.search(normalized_description)
    if match is None:
        return normalized_description, ""

    extracted_link = match.group(0).rstrip(TRAILING_URL_PUNCTUATION)
    description_without_link = (
        f"{normalized_description[:match.start()]}"
        f"{normalized_description[match.end():]}"
    )

    cleaned_description = re.sub(r"[ \t]{2,}", " ", description_without_link)
    cleaned_description = re.sub(r" *([,.!?;:])", r"\1", cleaned_description)
    cleaned_description = re.sub(r"\n{3,}", "\n\n", cleaned_description)

    return cleaned_description.strip(), extracted_link


def to_wish_item_type(item: WishItem) -> WishItemType:
    key = (getattr(item, "image_key", "") or "").strip()
    url = presigned_get_url(key) if key else None
    return WishItemType(
        id=str(item.id),
        title=item.title,
        description=item.description,
        link=item.link,
        price=float(item.price) if item.price is not None else None,
        currency=item.currency or None,
        image_url=url,
    )
