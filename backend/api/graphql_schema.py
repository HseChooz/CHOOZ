import os
from typing import List, Optional

import strawberry
from django.conf import settings
from django.contrib.auth import get_user_model
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token
from graphql import GraphQLError
from rest_framework_simplejwt.tokens import RefreshToken

from .models import GoogleAccount, WishItem

UserModel = get_user_model()


def _raise(code: str, message: str) -> None:
    raise GraphQLError(message, extensions={"code": code})


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


@strawberry.type
class TokenPair:
    access_token: str = strawberry.field(name="accessToken")
    refresh_token: str = strawberry.field(name="refreshToken")


def _verify_google_id_token(token: str) -> dict:
    client_id = os.getenv("GOOGLE_CLIENT_ID")
    if not client_id:
        _raise("SERVER_MISCONFIGURED", "GOOGLE_CLIENT_ID is not set")
    try:
        return google_id_token.verify_oauth2_token(token, google_requests.Request(), client_id)
    except Exception:
        _raise("INVALID_GOOGLE_TOKEN", "Invalid Google token")


def _get_or_create_user_from_google(idinfo: dict) -> UserModel:
    sub = idinfo["sub"]
    email = (idinfo.get("email") or "").lower().strip()
    email_verified = bool(idinfo.get("email_verified", False))

    if not email_verified:
        _raise("EMAIL_NOT_VERIFIED", "Email is not verified")

    if not email:
        _raise("INVALID_GOOGLE_TOKEN", "Email is missing")

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
        _raise("UNAUTHORIZED", "Unauthorized")
    return user


def _to_user_type(user: UserModel) -> UserType:
    return UserType(
        id=strawberry.ID(str(user.id)),
        username=user.username,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
    )


@strawberry.type
class Query:
    @strawberry.field()
    def me(self, info) -> Optional[UserType]:
        user = info.context.request.user
        if not user or not user.is_authenticated:
            return None
        return _to_user_type(user)

    @strawberry.field(name="wishItems")
    def wish_items(self, info) -> List[WishItemType]:
        user = _require_user(info)
        return [
            WishItemType(
                id=strawberry.ID(str(item.id)),
                title=item.title,
                description=item.description,
            )
            for item in WishItem.objects.filter(owner=user).order_by("-id")
        ]


@strawberry.type
class Mutation:
    @strawberry.mutation(name="loginWithGoogle")
    def login_with_google(
        self, info, id_token: str = strawberry.argument(name="idToken")
    ) -> AuthPayload:
        idinfo = _verify_google_id_token(id_token)
        user = _get_or_create_user_from_google(idinfo)

        refresh = RefreshToken.for_user(user)
        access = refresh.access_token

        return AuthPayload(
            access_token=str(access),
            refresh_token=str(refresh),
            user=_to_user_type(user),
        )

    @strawberry.mutation(name="refreshToken")
    def refresh_token(
        self, info, refresh_token: str = strawberry.argument(name="refreshToken")
    ) -> TokenPair:
        try:
            old_refresh = RefreshToken(refresh_token)
        except Exception:
            _raise("INVALID_REFRESH_TOKEN", "Invalid refresh token")

        user_id = old_refresh.get("user_id")
        if not user_id:
            _raise("INVALID_REFRESH_TOKEN", "Invalid refresh token")

        try:
            user = UserModel.objects.get(id=user_id)
        except UserModel.DoesNotExist:
            _raise("INVALID_REFRESH_TOKEN", "Invalid refresh token")

        new_refresh = RefreshToken.for_user(user)

        if "rest_framework_simplejwt.token_blacklist" in settings.INSTALLED_APPS:
            try:
                old_refresh.blacklist()
            except Exception:
                _raise("TOKEN_BLACKLIST_FAILED", "Failed to blacklist refresh token")

        return TokenPair(
            access_token=str(new_refresh.access_token),
            refresh_token=str(new_refresh),
        )

    @strawberry.mutation(name="createWishItem")
    def create_wish_item(self, info, title: str, description: str = "") -> WishItemType:
        user = _require_user(info)
        wish_item = WishItem.objects.create(owner=user, title=title, description=description)
        return WishItemType(
            id=strawberry.ID(str(wish_item.id)),
            title=wish_item.title,
            description=wish_item.description,
        )


schema = strawberry.Schema(query=Query, mutation=Mutation)
