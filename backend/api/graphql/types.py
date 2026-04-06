from datetime import date
from typing import Optional

import strawberry


@strawberry.type
class UserType:
    id: strawberry.ID
    username: str
    email: str
    first_name: str
    last_name: str


@strawberry.type
class WishItemType:
    id: strawberry.ID
    title: str
    description: str
    link: Optional[str]
    price: Optional[float]
    currency: Optional[str]
    image_url: Optional[str] = strawberry.field(name="imageUrl")


@strawberry.type
class UserWishItemsResult:
    user: UserType
    items: list[WishItemType]


@strawberry.type
class EventType:
    id: strawberry.ID
    title: str
    description: str
    link: Optional[str]
    notify_enabled: bool = strawberry.field(name="notifyEnabled")
    repeat_yearly: bool = strawberry.field(name="repeatYearly")
    date: date


@strawberry.type
class PresignedUpload:
    key: str
    upload_url: str = strawberry.field(name="uploadUrl")


@strawberry.type
class AuthPayload:
    access_token: str = strawberry.field(name="accessToken")
    refresh_token: str = strawberry.field(name="refreshToken")
    user: UserType


@strawberry.type
class TokenPair:
    access_token: str = strawberry.field(name="accessToken")
    refresh_token: str = strawberry.field(name="refreshToken")


@strawberry.type
class CollectionPreviewType:
    id: strawberry.ID
    slug: str
    title: str
    subtitle: str
    badge: Optional[str]
    cover_image_url: Optional[str] = strawberry.field(name="coverImageUrl")
    items_count: int = strawberry.field(name="itemsCount")


@strawberry.type
class CollectionSectionType:
    key: str
    title: str
    collections: list[CollectionPreviewType]


@strawberry.type
class CollectionsHomeType:
    sections: list[CollectionSectionType]


@strawberry.type
class CollectionItemType:
    id: strawberry.ID
    title: str
    description: str
    link: Optional[str]
    price: Optional[float]
    currency: Optional[str]
    image_url: Optional[str] = strawberry.field(name="imageUrl")
    is_added: bool = strawberry.field(name="isAdded")
    wish_item_id: Optional[strawberry.ID] = strawberry.field(name="wishItemId")


@strawberry.type
class CollectionType:
    id: strawberry.ID
    slug: str
    title: str
    subtitle: str
    description: str
    badge: Optional[str]
    cover_image_url: Optional[str] = strawberry.field(name="coverImageUrl")
    section_key: str = strawberry.field(name="sectionKey")
    section_title: str = strawberry.field(name="sectionTitle")
    tags: list[str]
    items_count: int = strawberry.field(name="itemsCount")
    items: list[CollectionItemType]
