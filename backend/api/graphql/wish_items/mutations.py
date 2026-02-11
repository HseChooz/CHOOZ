from typing import Optional

import strawberry

from api.graphql.types import PresignedUpload, WishItemType
from api.graphql.wish_items.service import get_owned_wish_item, require_user, to_wish_item_type
from api.models import WishItem
from api.storage.minio import make_image_key, presigned_put_url


@strawberry.type
class WishItemsMutation:
    @strawberry.mutation(name="createWishItem")
    def create_wish_item(self, info, title: str, description: str = "") -> WishItemType:
        user = require_user(info)
        item = WishItem.objects.create(owner=user, title=title, description=description)
        return to_wish_item_type(item)

    @strawberry.mutation(name="createWishItemImageUpload")
    def create_wish_item_image_upload(
        self,
        info,
        id: strawberry.ID,
        filename: str,
        content_type: str = strawberry.argument(name="contentType"),
    ) -> PresignedUpload:
        user = require_user(info)
        item = get_owned_wish_item(user, str(id))
        key = make_image_key(str(user.id), str(item.id), filename)
        upload_url = presigned_put_url(key, content_type)
        return PresignedUpload(key=key, upload_url=upload_url)

    @strawberry.mutation(name="attachWishItemImage")
    def attach_wish_item_image(self, info, id: strawberry.ID, key: str) -> WishItemType:
        user = require_user(info)
        item = get_owned_wish_item(user, str(id))
        item.image_key = (key or "").strip()
        item.save(update_fields=["image_key"])
        return to_wish_item_type(item)

    @strawberry.mutation(name="updateWishItem")
    def update_wish_item(
        self,
        info,
        id: strawberry.ID,
        title: Optional[str] = None,
        description: Optional[str] = None,
    ) -> WishItemType:
        user = require_user(info)
        item = get_owned_wish_item(user, str(id))

        updated_fields = []
        if title is not None:
            item.title = title
            updated_fields.append("title")
        if description is not None:
            item.description = description
            updated_fields.append("description")

        if updated_fields:
            item.save(update_fields=updated_fields)

        return to_wish_item_type(item)

    @strawberry.mutation(name="deleteWishItem")
    def delete_wish_item(self, info, id: strawberry.ID) -> bool:
        user = require_user(info)
        item = get_owned_wish_item(user, str(id))
        item.delete()
        return True