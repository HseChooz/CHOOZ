import pytest
from django.contrib.auth import get_user_model

from api.graphql.auth import apple as apple_auth
from api.models import AppleAccount

pytestmark = pytest.mark.django_db

User = get_user_model()


def test_me_returns_null_for_anonymous(gql):
    response = gql(
        """
        query {
          me {
            id
            email
          }
        }
        """
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["me"] is None
    assert "errors" not in payload


def test_me_returns_current_user_for_authenticated_request(gql, user, access_token):
    response = gql(
        """
        query {
          me {
            id
            username
            email
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["me"]["id"] == str(user.id)
    assert payload["data"]["me"]["username"] == user.username
    assert payload["data"]["me"]["email"] == user.email


def test_login_with_apple_creates_user_and_returns_tokens(gql, monkeypatch):
    monkeypatch.setattr(
        apple_auth,
        "verify_apple_identity_token",
        lambda _token: {
            "sub": "apple-user-123",
            "email": "relay@privaterelay.appleid.com",
            "email_verified": "true",
            "is_private_email": "true",
        },
    )

    response = gql(
        """
        mutation($identityToken: String!) {
          loginWithApple(identityToken: $identityToken) {
            accessToken
            refreshToken
            user {
              email
              username
            }
          }
        }
        """,
        variables={"identityToken": "valid-apple-token"},
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert payload["data"]["loginWithApple"]["accessToken"]
    assert payload["data"]["loginWithApple"]["refreshToken"]
    assert payload["data"]["loginWithApple"]["user"]["email"] == "relay@privaterelay.appleid.com"

    user = User.objects.get(email="relay@privaterelay.appleid.com")
    apple_account = AppleAccount.objects.get(user=user)
    assert apple_account.apple_user_id == "apple-user-123"
    assert apple_account.is_private_email is True


def test_login_with_apple_reuses_existing_account_without_email_claim(gql, monkeypatch, user):
    AppleAccount.objects.create(
        user=user,
        apple_user_id="apple-user-123",
        email=user.email,
        is_private_email=False,
    )

    monkeypatch.setattr(
        apple_auth,
        "verify_apple_identity_token",
        lambda _token: {
            "sub": "apple-user-123",
        },
    )

    response = gql(
        """
        mutation($identityToken: String!) {
          loginWithApple(identityToken: $identityToken) {
            user {
              id
              email
            }
          }
        }
        """,
        variables={"identityToken": "valid-apple-token"},
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert payload["data"]["loginWithApple"]["user"]["id"] == str(user.id)
    assert payload["data"]["loginWithApple"]["user"]["email"] == user.email


def test_google_login_mutation_is_not_exposed_in_schema(gql):
    response = gql(
        """
        query {
          __type(name: "Mutation") {
            fields {
              name
            }
          }
        }
        """
    )
    payload = response.json()

    assert response.status_code == 200
    mutation_fields = {field["name"] for field in payload["data"]["__type"]["fields"]}
    assert "loginWithApple" in mutation_fields
    assert "loginWithGoogle" not in mutation_fields
