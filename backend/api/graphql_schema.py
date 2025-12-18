import os
from typing import List, Optional

import strawberry
from django.contrib.auth import get_user_model
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from rest_framework_simplejwt.tokens import RefreshToken

from .models import GoogleAccount, WishItem

UserModel = get_user_model()


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


@strawberry.type
class AuthPayload:
    access_token: str = strawberry.field(name="accessToken")
    refresh_token: str = strawberry.field(name="refreshToken")
    user: UserType


def _verify_google_id_token(token: str) -> dict:
    client_id = os.getenv("GOOGLE_CLIENT_ID", "")
    return google_id_token.verify_oauth2_token(token, google_requests.Request(), client_id)


def _get_or_create_user_from_google(idinfo: dict) -> UserModel:
    sub = idinfo["sub"]
    email = (idinfo.get("email") or "").lower().strip()
    email_verified = bool(idinfo.get("email_verified", False))

    if not email or not email_verified:
        raise ValueError("Email is not verified")

    google_account = GoogleAccount.objects.select_related("user").filter(sub=sub).first()
    if google_account:
        user = google_account.user
        if user.email != email:
            user.email = email
            user.save(update_fields=["email"])
        return user

    user = UserModel.objects.filter(email=email).first()
    if not user:
        base_username = email.split("@")[0]
        username = base_username
        i = 1
        while UserModel.objects.filter(username=username).exists():
            i += 1
            username = f"{base_username}{i}"
        user = UserModel.objects.create(
            username=username,
            email=email,
            first_name=idinfo.get("given_name") or "",
            last_name=idinfo.get("family_name") or "",
        )

    GoogleAccount.objects.create(user=user, sub=sub, email=email)
    return user


def _require_user(info) -> UserModel:
    user = info.context.request.user
    if not user or not user.is_authenticated:
        raise ValueError("Unauthorized")
    return user


@strawberry.type
class Query:
    @strawberry.field
    def me(self, info) -> Optional[UserType]:
        user = info.context.request.user
        if not user or not user.is_authenticated:
            return None
        return UserType(
            id=str(user.id),
            username=user.username,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
        )

    @strawberry.field(name="wishItems")
    def wish_items(self, info) -> List[WishItemType]:
        user = _require_user(info)
        return [
            WishItemType(
                id=str(item.id),
                title=item.title,
                description=item.description,
            )
            for item in WishItem.objects.filter(owner=user).order_by("-id")
        ]


@strawberry.type
class Mutation:
    @strawberry.mutation(name="loginWithGoogle")
    def login_with_google(self, info, id_token: str = strawberry.argument(name="idToken")) -> AuthPayload:
        idinfo = _verify_google_id_token(id_token)
        user = _get_or_create_user_from_google(idinfo)

        refresh = RefreshToken.for_user(user)
        access = refresh.access_token

        return AuthPayload(
            access_token=str(access),
            refresh_token=str(refresh),
            user=UserType(
                id=str(user.id),
                username=user.username,
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
            ),
        )

    @strawberry.mutation(name="refreshToken")
    def refresh_token(self, info, refresh_token: str = strawberry.argument(name="refreshToken")) -> str:
        refresh = RefreshToken(refresh_token)
        return str(refresh.access_token)

    @strawberry.mutation(name="createWishItem")
    def create_wish_item(self, info, title: str, description: str = "") -> WishItemType:
        user = _require_user(info)
        wish_item = WishItem.objects.create(owner=user, title=title, description=description)
        return WishItemType(
            id=str(wish_item.id),
            title=wish_item.title,
            description=wish_item.description,
        )


schema = strawberry.Schema(query=Query, mutation=Mutation)