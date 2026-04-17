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
        mutation($identityToken: String!, $firstName: String, $lastName: String) {
          loginWithApple(
            identityToken: $identityToken
            firstName: $firstName
            lastName: $lastName
          ) {
            accessToken
            refreshToken
            user {
              email
              username
              firstName
              lastName
            }
          }
        }
        """,
        variables={
            "identityToken": "valid-apple-token",
            "firstName": "Alex",
            "lastName": "Parker",
        },
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert payload["data"]["loginWithApple"]["accessToken"]
    assert payload["data"]["loginWithApple"]["refreshToken"]
    assert payload["data"]["loginWithApple"]["user"]["email"] == "relay@privaterelay.appleid.com"
    assert payload["data"]["loginWithApple"]["user"]["firstName"] == "Alex"
    assert payload["data"]["loginWithApple"]["user"]["lastName"] == "Parker"

    user = User.objects.get(email="relay@privaterelay.appleid.com")
    apple_account = AppleAccount.objects.get(user=user)
    assert apple_account.apple_user_id == "apple-user-123"
    assert apple_account.is_private_email is True
    assert user.first_name == "Alex"
    assert user.last_name == "Parker"


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


def test_login_with_apple_updates_names_from_client_payload(gql, monkeypatch, user):
    user.first_name = ""
    user.last_name = ""
    user.save(update_fields=["first_name", "last_name"])

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
        mutation($identityToken: String!, $firstName: String, $lastName: String) {
          loginWithApple(
            identityToken: $identityToken
            firstName: $firstName
            lastName: $lastName
          ) {
            user {
              id
              firstName
              lastName
            }
          }
        }
        """,
        variables={
            "identityToken": "valid-apple-token",
            "firstName": "Taylor",
            "lastName": "Stone",
        },
    )
    payload = response.json()

    user.refresh_from_db()

    assert response.status_code == 200
    assert "errors" not in payload
    assert payload["data"]["loginWithApple"]["user"]["id"] == str(user.id)
    assert payload["data"]["loginWithApple"]["user"]["firstName"] == "Taylor"
    assert payload["data"]["loginWithApple"]["user"]["lastName"] == "Stone"
    assert user.first_name == "Taylor"
    assert user.last_name == "Stone"


def test_login_with_apple_updates_existing_user_found_by_email(gql, monkeypatch, user):
    user.first_name = ""
    user.last_name = ""
    user.save(update_fields=["first_name", "last_name"])

    monkeypatch.setattr(
        apple_auth,
        "verify_apple_identity_token",
        lambda _token: {
            "sub": "apple-user-123",
            "email": user.email,
            "email_verified": "true",
        },
    )

    response = gql(
        """
        mutation($identityToken: String!, $firstName: String, $lastName: String) {
          loginWithApple(
            identityToken: $identityToken
            firstName: $firstName
            lastName: $lastName
          ) {
            user {
              id
              email
              firstName
              lastName
            }
          }
        }
        """,
        variables={
            "identityToken": "valid-apple-token",
            "firstName": "Jordan",
            "lastName": "Lee",
        },
    )
    payload = response.json()

    user.refresh_from_db()
    apple_account = AppleAccount.objects.get(user=user)

    assert response.status_code == 200
    assert "errors" not in payload
    assert payload["data"]["loginWithApple"]["user"]["id"] == str(user.id)
    assert payload["data"]["loginWithApple"]["user"]["email"] == user.email
    assert payload["data"]["loginWithApple"]["user"]["firstName"] == "Jordan"
    assert payload["data"]["loginWithApple"]["user"]["lastName"] == "Lee"
    assert user.first_name == "Jordan"
    assert user.last_name == "Lee"
    assert apple_account.apple_user_id == "apple-user-123"


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
