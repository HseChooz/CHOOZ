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
class EventType:
    id: strawberry.ID
    title: str
    description: str
    link: Optional[str]
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