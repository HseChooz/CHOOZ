from api.graphql.errors import gql_error
from api.graphql.types import WishItemType
from api.models import WishItem
from api.storage.minio import presigned_get_url


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


def to_wish_item_type(item: WishItem) -> WishItemType:
    key = (getattr(item, "image_key", "") or "").strip()
    url = presigned_get_url(key) if key else None
    return WishItemType(
        id=str(item.id),
        title=item.title,
        description=item.description,
        image_url=url,
    )