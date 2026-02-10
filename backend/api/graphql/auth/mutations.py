from django.conf import settings
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken
import strawberry

from api.graphql.auth.google import verify_google_id_token, get_or_create_user_from_google
from api.graphql.auth.yandex import fetch_yandex_user_info, get_or_create_user_from_yandex
from api.graphql.errors import gql_error
from api.graphql.types import AuthPayload, TokenPair
from api.graphql.auth.queries import to_user_type

UserModel = get_user_model()


@strawberry.type
class AuthMutation:
    @strawberry.mutation(name="loginWithGoogle")
    def login_with_google(
        self, info, id_token: str = strawberry.argument(name="idToken")
    ) -> AuthPayload:
        idinfo = verify_google_id_token(id_token)
        user = get_or_create_user_from_google(idinfo)

        refresh = RefreshToken.for_user(user)
        access = refresh.access_token

        return AuthPayload(
            access_token=str(access),
            refresh_token=str(refresh),
            user=to_user_type(user),
        )

    @strawberry.mutation(name="loginWithYandex")
    def login_with_yandex(
        self, info, oauth_token: str = strawberry.argument(name="oauthToken")
    ) -> AuthPayload:
        data = fetch_yandex_user_info(oauth_token)
        user = get_or_create_user_from_yandex(data)

        refresh = RefreshToken.for_user(user)
        access = refresh.access_token

        return AuthPayload(
            access_token=str(access),
            refresh_token=str(refresh),
            user=to_user_type(user),
        )

    @strawberry.mutation(name="refreshToken")
    def refresh_token(
        self, info, refresh_token: str = strawberry.argument(name="refreshToken")
    ) -> TokenPair:
        try:
            old_refresh = RefreshToken(refresh_token)
        except Exception:
            gql_error("INVALID_REFRESH_TOKEN", "Invalid refresh token")

        user_id = old_refresh.get("user_id")
        if not user_id:
            gql_error("INVALID_REFRESH_TOKEN", "Invalid refresh token")

        try:
            user = UserModel.objects.get(id=user_id)
        except UserModel.DoesNotExist:
            gql_error("INVALID_REFRESH_TOKEN", "Invalid refresh token")

        new_refresh = RefreshToken.for_user(user)

        if "rest_framework_simplejwt.token_blacklist" in settings.INSTALLED_APPS:
            try:
                old_refresh.blacklist()
            except Exception:
                gql_error("TOKEN_BLACKLIST_FAILED", "Failed to blacklist refresh token")

        return TokenPair(
            access_token=str(new_refresh.access_token),
            refresh_token=str(new_refresh),
        )