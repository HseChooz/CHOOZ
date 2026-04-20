from typing import List

import strawberry
from django.contrib.auth import get_user_model
from strawberry.types import Info

from api.graphql.types import UserType, UserWishItemsResult, WishItemType
from api.models import WishItem

from .service import get_owned_wish_item, require_user, to_wish_item_type

User = get_user_model()


@strawberry.type
class WishItemsQuery:
    @strawberry.field(name="wishItems")
    def wish_items(self, info: Info) -> List[WishItemType]:
        user = require_user(info)
        wishes = WishItem.objects.filter(owner=user).order_by("-id")
        return [to_wish_item_type(item) for item in wishes]

    @strawberry.field(name="wishItem")
    def wish_item(self, info: Info, id: strawberry.ID) -> WishItemType:
        user = require_user(info)
        item = get_owned_wish_item(user, str(id))
        return to_wish_item_type(item)

    @strawberry.field(name="userWishItems")
    def user_wish_items(self, info: Info, user_id: strawberry.ID) -> UserWishItemsResult | None:
        require_user(info)
        target_user = User.objects.filter(id=str(user_id)).first()
        if target_user is None:
            return None
        wishes = WishItem.objects.filter(owner=target_user).order_by("-id")
        items = [to_wish_item_type(item) for item in wishes]
        return UserWishItemsResult(
            user=UserType(
                id=strawberry.ID(str(target_user.id)),
                username=target_user.username,
                email=target_user.email,
                first_name=target_user.first_name,
                last_name=target_user.last_name,
            ),
            items=items
        )
