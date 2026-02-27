import os

import requests
from django.contrib.auth import get_user_model

from api.models import YandexAccount
from api.graphql.errors import gql_error

UserModel = get_user_model()


def fetch_yandex_user_info(oauth_token: str) -> dict:
    client_id = os.getenv("YANDEX_CLIENT_ID")
    if not client_id:
        gql_error("SERVER_MISCONFIGURED", "YANDEX_CLIENT_ID is not set")

    try:
        resp = requests.get(
            "https://login.yandex.ru/info?format=json",
            headers={"Authorization": f"OAuth {oauth_token}"},
            timeout=10,
        )
    except Exception:
        gql_error("YANDEX_UNAVAILABLE", "Yandex is unavailable")

    if resp.status_code != 200:
        gql_error("INVALID_YANDEX_TOKEN", "Invalid Yandex token")

    try:
        data = resp.json()
    except Exception:
        gql_error("INVALID_YANDEX_TOKEN", "Invalid Yandex token")

    if data.get("client_id") != client_id or not data.get("id"):
        gql_error("INVALID_YANDEX_TOKEN", "Invalid Yandex token")

    return data


def get_or_create_user_from_yandex(data: dict) -> UserModel:
    yandex_id = str(data.get("id"))
    login = (data.get("login") or "").strip()

    email = (data.get("default_email") or "").strip().lower()
    if not email:
        emails = data.get("emails") or []
        if isinstance(emails, list) and emails:
            email = (emails[0] or "").strip().lower()

    ya = YandexAccount.objects.select_related("user").filter(yandex_id=yandex_id).first()
    if ya:
        user = ya.user
        if email and user.email != email:
            user.email = email
            user.save(update_fields=["email"])
        if login and ya.login != login:
            ya.login = login
        if email and ya.email != email:
            ya.email = email
        if login or email:
            ya.save(update_fields=["login", "email"])
        return user

    user = UserModel.objects.filter(email=email).first() if email else None
    if not user:
        base_username = login or f"yandex_{yandex_id}"
        username = base_username
        i = 1
        while UserModel.objects.filter(username=username).exists():
            i += 1
            username = f"{base_username}{i}"
        user = UserModel.objects.create(
            username=username,
            email=email,
            first_name=(data.get("first_name") or ""),
            last_name=(data.get("last_name") or ""),
        )

    YandexAccount.objects.create(user=user, yandex_id=yandex_id, login=login, email=email)
    return user