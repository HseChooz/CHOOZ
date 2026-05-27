import strawberry
from strawberry.types import Info

from api.graphql.types import WishlistShareLinkType
from api.graphql.wish_items.service import require_user
from api.wishlist_share import (
    disable_share_link,
    get_or_create_enabled_share_link,
    regenerate_share_link,
)

from .queries import to_wishlist_share_link_type


@strawberry.type
class WishlistShareMutation:
    @strawberry.mutation(name="prepareWishlistShareLink")
    def prepare_wishlist_share_link(self, info: Info) -> WishlistShareLinkType:
        user = require_user(info)
        share_link = get_or_create_enabled_share_link(user, info.context.request)
        return to_wishlist_share_link_type(
            share_link,
            request=info.context.request,
        )

    @strawberry.mutation(name="disableWishlistShareLink")
    def disable_wishlist_share_link(self, info: Info) -> WishlistShareLinkType:
        user = require_user(info)
        share_link = disable_share_link(user, info.context.request)
        return to_wishlist_share_link_type(
            share_link,
            request=info.context.request,
        )

    @strawberry.mutation(name="regenerateWishlistShareLink")
    def regenerate_wishlist_share_link(self, info: Info) -> WishlistShareLinkType:
        user = require_user(info)
        share_link = regenerate_share_link(user, info.context.request)
        return to_wishlist_share_link_type(
            share_link,
            request=info.context.request,
        )
