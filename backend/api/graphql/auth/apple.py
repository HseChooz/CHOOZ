import logging
import os

import jwt
from django.contrib.auth import get_user_model
from jwt import PyJWKClient
from jwt.exceptions import (
    DecodeError,
    ExpiredSignatureError,
    InvalidAudienceError,
    InvalidIssuerError,
    InvalidSignatureError,
    InvalidTokenError,
    PyJWKClientConnectionError,
)

from api.graphql.errors import gql_error
from api.models import AppleAccount

APPLE_ISSUER = "https://appleid.apple.com"
APPLE_JWKS_URL = "https://appleid.apple.com/auth/keys"
APPLE_JWK_CLIENT = PyJWKClient(APPLE_JWKS_URL, cache_jwk_set=True, lifespan=300, timeout=10)

UserModel = get_user_model()
logger = logging.getLogger(__name__)


def _to_bool(value) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, str):
        return value.lower() == "true"
    return bool(value)


def get_apple_client_ids() -> list[str]:
    client_ids = [
        value.strip() for value in os.getenv("APPLE_CLIENT_IDS", "").split(",") if value.strip()
    ]

    single_client_id = os.getenv("APPLE_CLIENT_ID", "").strip()
    if single_client_id and single_client_id not in client_ids:
        client_ids.append(single_client_id)

    if not client_ids:
        gql_error("SERVER_MISCONFIGURED", "APPLE_CLIENT_ID is not set")

    return client_ids


def verify_apple_identity_token(identity_token: str) -> dict:
    identity_token = (identity_token or "").strip()
    client_ids = get_apple_client_ids()

    try:
        signing_key = APPLE_JWK_CLIENT.get_signing_key_from_jwt(identity_token)
    except PyJWKClientConnectionError:
        gql_error("APPLE_UNAVAILABLE", "Apple is unavailable")
    except DecodeError:
        gql_error("INVALID_APPLE_TOKEN", "Apple identity token is malformed")
    except Exception as exc:
        logger.warning("Failed to read Apple signing key: %s", exc.__class__.__name__)
        gql_error("INVALID_APPLE_TOKEN", "Invalid Apple token")

    try:
        payload = jwt.decode(
            identity_token,
            signing_key.key,
            algorithms=["RS256"],
            audience=client_ids,
            issuer=APPLE_ISSUER,
        )
    except InvalidAudienceError:
        gql_error("INVALID_APPLE_AUDIENCE", "Apple token audience does not match APPLE_CLIENT_ID")
    except InvalidIssuerError:
        gql_error("INVALID_APPLE_ISSUER", "Apple token issuer is invalid")
    except ExpiredSignatureError:
        gql_error("EXPIRED_APPLE_TOKEN", "Apple token has expired")
    except InvalidSignatureError:
        gql_error("INVALID_APPLE_SIGNATURE", "Apple token signature is invalid")
    except DecodeError:
        gql_error("INVALID_APPLE_TOKEN", "Apple identity token is malformed")
    except InvalidTokenError:
        gql_error("INVALID_APPLE_TOKEN", "Invalid Apple token")

    if not payload.get("sub"):
        gql_error("INVALID_APPLE_TOKEN", "Invalid Apple token")

    return payload


def get_or_create_user_from_apple(payload: dict) -> UserModel:
    apple_user_id = str(payload["sub"]).strip()
    email = (payload.get("email") or "").strip().lower()
    is_private_email = _to_bool(payload.get("is_private_email"))

    if email and not _to_bool(payload.get("email_verified", True)):
        gql_error("EMAIL_NOT_VERIFIED", "Email is not verified")

    apple_account = (
        AppleAccount.objects.select_related("user").filter(apple_user_id=apple_user_id).first()
    )
    if apple_account:
        user = apple_account.user
        user_fields_to_update = []
        account_fields_to_update = []

        if email and user.email != email:
            user.email = email
            user_fields_to_update.append("email")

        if email and apple_account.email != email:
            apple_account.email = email
            account_fields_to_update.append("email")

        if "is_private_email" in payload and apple_account.is_private_email != is_private_email:
            apple_account.is_private_email = is_private_email
            account_fields_to_update.append("is_private_email")

        if user_fields_to_update:
            user.save(update_fields=user_fields_to_update)
        if account_fields_to_update:
            apple_account.save(update_fields=account_fields_to_update)

        return user

    user = UserModel.objects.filter(email=email).first() if email else None
    if not user:
        base_username = email.split("@")[0] if email else f"apple_{apple_user_id[:12]}"
        username = base_username
        i = 1
        while UserModel.objects.filter(username=username).exists():
            i += 1
            username = f"{base_username}{i}"

        user = UserModel.objects.create(
            username=username,
            email=email,
        )

    AppleAccount.objects.create(
        user=user,
        apple_user_id=apple_user_id,
        email=email,
        is_private_email=is_private_email,
    )
    return user
