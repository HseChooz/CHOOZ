from base64 import b64encode

import pytest
from graphql import GraphQLError
from jwt import (
    DecodeError,
    ExpiredSignatureError,
    InvalidAlgorithmError,
    InvalidAudienceError,
    PyJWKClientError,
)
from jwt.exceptions import MissingCryptographyError

from api.graphql.auth import apple as apple_auth

pytestmark = pytest.mark.django_db


def test_normalize_apple_identity_token_accepts_raw_jwt():
    token = "header.payload.signature"

    assert apple_auth.normalize_apple_identity_token(token) == token


def test_normalize_apple_identity_token_decodes_base64_wrapped_jwt():
    token = "header.payload.signature"
    wrapped = b64encode(token.encode("utf-8")).decode("utf-8")

    assert apple_auth.normalize_apple_identity_token(wrapped) == token


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


def test_verify_apple_identity_token_reports_unknown_kid(monkeypatch):
    monkeypatch.setenv("APPLE_CLIENT_ID", "com.chooz.app")

    def raise_jwk_error(_token):
        raise PyJWKClientError('Unable to find a signing key that matches: "test-kid"')

    monkeypatch.setattr(apple_auth.APPLE_JWK_CLIENT, "get_signing_key_from_jwt", raise_jwk_error)

    with pytest.raises(GraphQLError) as exc_info:
        apple_auth.verify_apple_identity_token("header.payload.signature")

    assert exc_info.value.extensions["code"] == "INVALID_APPLE_KID"
    assert exc_info.value.message == "Apple token signing key was not recognized"


def test_verify_apple_identity_token_reports_invalid_algorithm(monkeypatch):
    monkeypatch.setenv("APPLE_CLIENT_ID", "com.chooz.app")
    monkeypatch.setattr(
        apple_auth.APPLE_JWK_CLIENT,
        "get_signing_key_from_jwt",
        lambda _token: type("SigningKey", (), {"key": "stub-key"})(),
    )

    def raise_invalid_algorithm(*_args, **_kwargs):
        raise InvalidAlgorithmError("bad alg")

    monkeypatch.setattr(apple_auth.jwt, "decode", raise_invalid_algorithm)

    with pytest.raises(GraphQLError) as exc_info:
        apple_auth.verify_apple_identity_token("header.payload.signature")

    assert exc_info.value.extensions["code"] == "INVALID_APPLE_ALGORITHM"
    assert exc_info.value.message == "Apple token algorithm is invalid"


def test_verify_apple_identity_token_reports_missing_cryptography(monkeypatch):
    monkeypatch.setenv("APPLE_CLIENT_ID", "com.chooz.app")
    monkeypatch.setattr(
        apple_auth.APPLE_JWK_CLIENT,
        "get_signing_key_from_jwt",
        lambda _token: type("SigningKey", (), {"key": "stub-key"})(),
    )

    def raise_missing_crypto(*_args, **_kwargs):
        raise MissingCryptographyError("cryptography is required")

    monkeypatch.setattr(apple_auth.jwt, "decode", raise_missing_crypto)

    with pytest.raises(GraphQLError) as exc_info:
        apple_auth.verify_apple_identity_token("header.payload.signature")

    assert exc_info.value.extensions["code"] == "SERVER_MISCONFIGURED"
    assert exc_info.value.message == "Apple token verification is not available on the server"
