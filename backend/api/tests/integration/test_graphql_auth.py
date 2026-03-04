import pytest


pytestmark = pytest.mark.django_db


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
