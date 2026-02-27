import os

from django.contrib.auth import get_user_model
from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token

from api.models import GoogleAccount
from api.graphql.errors import gql_error

UserModel = get_user_model()


def verify_google_id_token(token: str) -> dict:
    client_id = os.getenv("GOOGLE_CLIENT_ID")
    if not client_id:
        gql_error("SERVER_MISCONFIGURED", "GOOGLE_CLIENT_ID is not set")
    try:
        return google_id_token.verify_oauth2_token(token, google_requests.Request(), client_id)
    except Exception:
        gql_error("INVALID_GOOGLE_TOKEN", "Invalid Google token")


def get_or_create_user_from_google(idinfo: dict) -> UserModel:
    sub = idinfo["sub"]
    email = (idinfo.get("email") or "").lower().strip()
    email_verified = bool(idinfo.get("email_verified", False))

    if not email_verified:
        gql_error("EMAIL_NOT_VERIFIED", "Email is not verified")

    if not email:
        gql_error("INVALID_GOOGLE_TOKEN", "Email is missing")

    google_account = GoogleAccount.objects.select_related("user").filter(sub=sub).first()
    if google_account:
        user = google_account.user
        if user.email != email:
            user.email = email
            user.save(update_fields=["email"])
        return user

    user = UserModel.objects.filter(email=email).first()
    if not user:
        base_username = email.split("@")[0]
        username = base_username
        i = 1
        while UserModel.objects.filter(username=username).exists():
            i += 1
            username = f"{base_username}{i}"
        user = UserModel.objects.create(
            username=username,
            email=email,
            first_name=idinfo.get("given_name") or "",
            last_name=idinfo.get("family_name") or "",
        )

    GoogleAccount.objects.create(user=user, sub=sub, email=email)
    return user