from strawberry.types import Info

from api.graphql.collections.service import resolve_collection_asset_url
from api.graphql.errors import gql_error
from api.graphql.types import WishItemType
from api.models import WishItem
from api.storage.minio import presigned_get_url


def require_user(info: Info):
    user = info.context.request.user
    if not user or not user.is_authenticated:
        gql_error("UNAUTHORIZED", "Unauthorized")
    return user


def get_owned_wish_item(user, wish_item_id: str) -> WishItem:
    try:
        return WishItem.objects.get(id=wish_item_id, owner=user)
    except WishItem.DoesNotExist:
        gql_error("WISH_ITEM_NOT_FOUND", "Wish item not found")


def to_wish_item_type(item: WishItem, *, request=None) -> WishItemType:
    key = (getattr(item, "image_key", "") or "").strip()
    url = presigned_get_url(key) if key else None
    is_from_collection = bool(getattr(item, "collection_item_id", None))
    if url is None and getattr(item, "collection_item_id", None):
        collection_item = getattr(item, "collection_item", None)
        if collection_item is None:
            collection_item = item.collection_item
        url = resolve_collection_asset_url(collection_item.image_url, request=request)
    return WishItemType(
        id=str(item.id),
        title=item.title,
        description=item.description,
        link=item.link,
        price=float(item.price) if item.price is not None else None,
        currency=item.currency or None,
        image_url=url,
        is_from_collection=is_from_collection,
    )
