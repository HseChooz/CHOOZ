import pytest
from django.contrib.auth.models import AnonymousUser
from django.http import HttpResponse
from django.test import RequestFactory

from api.middleware import JWTAuthMiddleware


pytestmark = pytest.mark.django_db


def test_middleware_sets_user_and_auth_on_success(user, monkeypatch):
    request = RequestFactory().get("/")
    token = object()
    middleware = JWTAuthMiddleware(lambda _request: HttpResponse("ok"))

    monkeypatch.setattr(middleware.auth, "authenticate", lambda _request: (user, token))

    response = middleware(request)

    assert response.status_code == 200
    assert request.user == user
    assert request.auth is token


def test_middleware_keeps_existing_user_when_auth_fails(user, monkeypatch):
    request = RequestFactory().get("/")
    request.user = user

    middleware = JWTAuthMiddleware(lambda _request: HttpResponse("ok"))

    def _raise(_request):
        raise RuntimeError("boom")

    monkeypatch.setattr(middleware.auth, "authenticate", _raise)

    middleware(request)

    assert request.user == user


def test_middleware_sets_anonymous_when_auth_fails_without_user(monkeypatch):
    request = RequestFactory().get("/")
    middleware = JWTAuthMiddleware(lambda _request: HttpResponse("ok"))

    def _raise(_request):
        raise RuntimeError("boom")

    monkeypatch.setattr(middleware.auth, "authenticate", _raise)

    middleware(request)

    assert isinstance(request.user, AnonymousUser)
