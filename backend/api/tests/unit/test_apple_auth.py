import pytest
from graphql import GraphQLError
from jwt import DecodeError, ExpiredSignatureError, InvalidAudienceError

from api.graphql.auth import apple as apple_auth

pytestmark = pytest.mark.django_db


def test_verify_apple_identity_token_reports_invalid_audience(monkeypatch):
    monkeypatch.setenv("APPLE_CLIENT_ID", "com.chooz.app")
    monkeypatch.setattr(
        apple_auth.APPLE_JWK_CLIENT,
        "get_signing_key_from_jwt",
        lambda _token: type("SigningKey", (), {"key": "stub-key"})(),
    )

    def raise_invalid_audience(*_args, **_kwargs):
        raise InvalidAudienceError("bad aud")

    monkeypatch.setattr(apple_auth.jwt, "decode", raise_invalid_audience)

    with pytest.raises(GraphQLError) as exc_info:
        apple_auth.verify_apple_identity_token("header.payload.signature")

    assert exc_info.value.extensions["code"] == "INVALID_APPLE_AUDIENCE"
    assert exc_info.value.message == "Apple token audience does not match APPLE_CLIENT_ID"


def test_verify_apple_identity_token_reports_expired_token(monkeypatch):
    monkeypatch.setenv("APPLE_CLIENT_ID", "com.chooz.app")
    monkeypatch.setattr(
        apple_auth.APPLE_JWK_CLIENT,
        "get_signing_key_from_jwt",
        lambda _token: type("SigningKey", (), {"key": "stub-key"})(),
    )

    def raise_expired(*_args, **_kwargs):
        raise ExpiredSignatureError("expired")

    monkeypatch.setattr(apple_auth.jwt, "decode", raise_expired)

    with pytest.raises(GraphQLError) as exc_info:
        apple_auth.verify_apple_identity_token("header.payload.signature")

    assert exc_info.value.extensions["code"] == "EXPIRED_APPLE_TOKEN"
    assert exc_info.value.message == "Apple token has expired"


def test_verify_apple_identity_token_reports_malformed_token(monkeypatch):
    monkeypatch.setenv("APPLE_CLIENT_ID", "com.chooz.app")

    def raise_decode_error(_token):
        raise DecodeError("not a jwt")

    monkeypatch.setattr(apple_auth.APPLE_JWK_CLIENT, "get_signing_key_from_jwt", raise_decode_error)

    with pytest.raises(GraphQLError) as exc_info:
        apple_auth.verify_apple_identity_token("not-a-jwt")

    assert exc_info.value.extensions["code"] == "INVALID_APPLE_TOKEN"
    assert exc_info.value.message == "Apple identity token is malformed"
