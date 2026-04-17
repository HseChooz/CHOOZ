import strawberry

from api.graphql.collections.service import (
    get_collection_item,
    require_user,
    to_collection_item_type,
)
from api.graphql.types import CollectionItemType
from api.models import WishItem


@strawberry.type
class CollectionsMutation:
    @strawberry.mutation(name="addCollectionItemToWishlist")
    def add_collection_item_to_wishlist(
        self,
        info,
        collection_item_id: strawberry.ID,
    ) -> CollectionItemType:
        user = require_user(info)
        collection_item = get_collection_item(str(collection_item_id))
        wish_item = WishItem.objects.filter(
            owner=user,
            collection_item=collection_item,
        ).first()
        if wish_item is None:
            wish_item = WishItem.objects.create(
                owner=user,
                collection_item=collection_item,
                title=collection_item.title,
                description=collection_item.description,
                link=collection_item.link,
                price=collection_item.price,
                currency=collection_item.currency,
            )
        return to_collection_item_type(collection_item, wish_item)

    @strawberry.mutation(name="removeCollectionItemFromWishlist")
    def remove_collection_item_from_wishlist(
        self,
        info,
        collection_item_id: strawberry.ID,
    ) -> CollectionItemType:
        user = require_user(info)
        collection_item = get_collection_item(str(collection_item_id))
        wish_item = WishItem.objects.filter(
            owner=user,
            collection_item=collection_item,
        ).first()
        if wish_item is not None:
            wish_item.delete()
        return to_collection_item_type(collection_item, None)
