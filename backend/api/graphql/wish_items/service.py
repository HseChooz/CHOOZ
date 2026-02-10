from api.graphql.errors import gql_error
from api.models import WishItem


def get_owned_wish_item(user, wish_item_id: str) -> WishItem:
    try:
        return WishItem.objects.get(id=wish_item_id, owner=user)
    except WishItem.DoesNotExist:
        gql_error("WISH_ITEM_NOT_FOUND", "Wish item not found")


def to_wish_item_type(item, WishItemType):
    url = item.image.url if item.image else None
    return WishItemType(
        id=str(item.id),
        title=item.title,
        description=item.description,
        image_url=url,
    )