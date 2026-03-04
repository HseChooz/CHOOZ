import json

import pytest
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken


User = get_user_model()


@pytest.fixture
def user(db):
    return User.objects.create_user(
        username="alice",
        email="alice@example.com",
        password="password123",
    )


@pytest.fixture
def another_user(db):
    return User.objects.create_user(
        username="bob",
        email="bob@example.com",
        password="password123",
    )


@pytest.fixture
def access_token(user):
    return str(RefreshToken.for_user(user).access_token)


@pytest.fixture
def gql(client):
    def _execute(query: str, variables: dict | None = None, token: str | None = None):
        payload = {"query": query}
        if variables is not None:
            payload["variables"] = variables

        headers = {}
        if token:
            headers["HTTP_AUTHORIZATION"] = f"Bearer {token}"

        response = client.post(
            "/api/graphql/",
            data=json.dumps(payload),
            content_type="application/json",
            **headers,
        )
        return response

    return _execute
