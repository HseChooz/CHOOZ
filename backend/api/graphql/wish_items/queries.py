from typing import List

import strawberry

from api.graphql.types import WishItemType
from api.models import WishItem
from .service import get_owned_wish_item, require_user, to_wish_item_type


@strawberry.type
class WishItemsQuery:
    @strawberry.field(name="wishItems")
    def wish_items(self, info) -> List[WishItemType]:
        user = require_user(info)
        return [to_wish_item_type(item) for item in WishItem.objects.filter(owner=user).order_by("-id")]

    @strawberry.field(name="wishItem")
    def wish_item(self, info, id: strawberry.ID) -> WishItemType:
        user = require_user(info)
        item = get_owned_wish_item(user, str(id))
        return to_wish_item_type(item)