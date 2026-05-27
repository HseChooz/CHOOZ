import strawberry
from strawberry.types import Info

from api.graphql.types import WishlistShareLinkType
from api.graphql.wish_items.service import require_user
from api.models import WishlistShareLink
from api.wishlist_share import build_share_url


def to_wishlist_share_link_type(
    share_link: WishlistShareLink,
    *,
    request,
) -> WishlistShareLinkType:
    return WishlistShareLinkType(
        url=build_share_url(request, share_link.token),
        is_enabled=share_link.is_enabled,
    )


@strawberry.type
class WishlistShareQuery:
    @strawberry.field(name="myWishlistShareLink")
    def my_wishlist_share_link(self, info: Info) -> WishlistShareLinkType | None:
        user = require_user(info)
        share_link = WishlistShareLink.objects.filter(owner=user).first()
        if share_link is None:
            return None
        return to_wishlist_share_link_type(
            share_link,
            request=info.context.request,
        )
