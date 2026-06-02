import pytest
from django.test import override_settings

from api.models import Collection, CollectionItem, WishItem, WishlistShareLink

pytestmark = pytest.mark.django_db


def test_my_wishlist_share_link_returns_none_when_link_not_created(gql, access_token):
    response = gql(
        """
        query {
          myWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["myWishlistShareLink"] is None


def test_my_wishlist_share_link_requires_auth(gql):
    response = gql(
        """
        query {
          myWishlistShareLink {
            url
            isEnabled
          }
        }
        """
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["myWishlistShareLink"] is None
    assert payload["errors"][0]["extensions"]["code"] == "UNAUTHORIZED"


def test_prepare_wishlist_share_link_creates_link(gql, access_token, user):
    response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    share_link = WishlistShareLink.objects.get(owner=user)
    assert response.status_code == 200
    assert payload["data"]["prepareWishlistShareLink"] == {
        "url": f"http://testserver/wishlist/{share_link.token}/",
        "isEnabled": True,
    }


def test_wishlist_share_target_returns_owner_user_id_for_active_token(
    gql,
    access_token,
    user,
):
    WishlistShareLink.objects.create(owner=user, token="public-target", is_enabled=True)

    response = gql(
        """
        query WishlistShareTarget($token: String!) {
          wishlistShareTarget(token: $token) {
            userId
          }
        }
        """,
        variables={"token": "public-target"},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["wishlistShareTarget"] == {"userId": str(user.id)}


def test_wishlist_share_target_requires_auth(gql, user):
    WishlistShareLink.objects.create(owner=user, token="public-target", is_enabled=True)

    response = gql(
        """
        query WishlistShareTarget($token: String!) {
          wishlistShareTarget(token: $token) {
            userId
          }
        }
        """,
        variables={"token": "public-target"},
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "UNAUTHORIZED"


def test_wishlist_share_target_returns_not_found_for_unknown_token(gql, access_token):
    response = gql(
        """
        query WishlistShareTarget($token: String!) {
          wishlistShareTarget(token: $token) {
            userId
          }
        }
        """,
        variables={"token": "missing"},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "WISHLIST_SHARE_NOT_FOUND"


def test_wishlist_share_target_returns_disabled_for_disabled_token(
    gql,
    access_token,
    user,
):
    WishlistShareLink.objects.create(owner=user, token="disabled-target", is_enabled=False)

    response = gql(
        """
        query WishlistShareTarget($token: String!) {
          wishlistShareTarget(token: $token) {
            userId
          }
        }
        """,
        variables={"token": "disabled-target"},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "WISHLIST_SHARE_DISABLED"


def test_prepare_wishlist_share_link_reuses_existing_enabled_link(gql, access_token, user):
    first_response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    first_payload = first_response.json()

    second_response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    second_payload = second_response.json()

    assert second_response.status_code == 200
    assert (
        second_payload["data"]["prepareWishlistShareLink"]
        == first_payload["data"]["prepareWishlistShareLink"]
    )
    assert WishlistShareLink.objects.filter(owner=user).count() == 1


def test_prepare_wishlist_share_link_reenables_disabled_link(gql, access_token, user):
    prepare_response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    prepared = prepare_response.json()["data"]["prepareWishlistShareLink"]

    disable_response = gql(
        """
        mutation {
          disableWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    disabled = disable_response.json()["data"]["disableWishlistShareLink"]

    second_prepare_response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    second_prepared = second_prepare_response.json()["data"]["prepareWishlistShareLink"]

    assert disabled["url"] == prepared["url"]
    assert disabled["isEnabled"] is False
    assert second_prepared == prepared
    assert WishlistShareLink.objects.get(owner=user).is_enabled is True


def test_regenerate_wishlist_share_link_rotates_token(gql, access_token, user):
    prepare_response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    first_url = prepare_response.json()["data"]["prepareWishlistShareLink"]["url"]

    regenerate_response = gql(
        """
        mutation {
          regenerateWishlistShareLink {
            url
            isEnabled
          }
        }
        """,
        token=access_token,
    )
    regenerated = regenerate_response.json()["data"]["regenerateWishlistShareLink"]

    assert regenerate_response.status_code == 200
    assert regenerated["isEnabled"] is True
    assert regenerated["url"] != first_url
    assert regenerated["url"] == f"http://testserver/wishlist/{WishlistShareLink.objects.get(owner=user).token}/"


def test_wishlist_share_mutations_require_auth(gql):
    response = gql(
        """
        mutation {
          prepareWishlistShareLink {
            url
            isEnabled
          }
        }
        """
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "UNAUTHORIZED"


def test_public_wishlist_page_renders_items(client, user):
    user.first_name = "Alice"
    user.last_name = "Stone"
    user.save(update_fields=["first_name", "last_name"])
    collection = Collection.objects.create(
        slug="wishlist-public",
        title="Wishlist Public",
        section=Collection.Section.FOR_YOU,
    )
    collection_item = CollectionItem.objects.create(
        collection=collection,
        title="Collection Lamp",
        image_url="collections/shared/funny-cat.png",
    )
    WishItem.objects.create(
        owner=user,
        title="Collection Lamp",
        description="Warm light for the room",
        link="https://example.com/lamp",
        price="12990.00",
        currency="rub",
        collection_item=collection_item,
    )
    share_link = WishlistShareLink.objects.create(owner=user, token="public-token", is_enabled=True)

    response = client.get(f"/wishlist/{share_link.token}/")
    content = response.content.decode("utf-8")

    assert response.status_code == 200
    assert "Alice Stone" in content
    assert "Collection Lamp" in content
    assert "Warm light for the room" in content
    assert "12990.0" in content
    assert "₽" in content
    assert "/api/assets/collections/shared/funny-cat.png" in content
    assert 'meta name="robots" content="noindex, nofollow"' in content
    assert 'name="apple-itunes-app"' in content
    assert 'content="app-id=6760219704, app-argument=chooz://wishlist/public-token"' in content
    assert 'property="og:title"' in content
    assert 'href="chooz://wishlist/public-token"' in content
    assert 'data-app-store-url="https://apps.apple.com/kz/app/chooz/id6760219704"' in content
    assert 'href="https://apps.apple.com/kz/app/chooz/id6760219704"' in content
    assert "wishlist-count" not in content
    assert 'class="modal-button' not in content
    assert user.email not in content
    assert "accessToken" not in content
    assert "refreshToken" not in content
    assert "Bearer" not in content


def test_public_wishlist_page_uses_empty_state(client, user):
    share_link = WishlistShareLink.objects.create(owner=user, token="empty-token", is_enabled=True)

    response = client.get(f"/wishlist/{share_link.token}/")
    content = response.content.decode("utf-8")

    assert response.status_code == 200
    assert "Вишлист пока пуст" in content
    assert user.username in content


def test_public_wishlist_page_returns_404_for_unknown_token(client):
    response = client.get("/wishlist/missing-token/")
    content = response.content.decode("utf-8")

    assert response.status_code == 404
    assert "Ссылка недоступна" in content


def test_public_wishlist_page_returns_410_for_disabled_link(client, user):
    share_link = WishlistShareLink.objects.create(
        owner=user,
        token="disabled-token",
        is_enabled=False,
    )

    response = client.get(f"/wishlist/{share_link.token}/")
    content = response.content.decode("utf-8")

    assert response.status_code == 410
    assert "Ссылка отключена" in content


@override_settings(
    APP_STORE_URL="https://apps.apple.com/app/id1234567890",
    APPLE_APP_SITE_ASSOCIATION_APP_ID="TEAMID.com.chooz.app",
)
def test_public_wishlist_page_renders_install_cta(client, user):
    share_link = WishlistShareLink.objects.create(owner=user, token="cta-token", is_enabled=True)

    response = client.get(f"/wishlist/{share_link.token}/")
    content = response.content.decode("utf-8")

    assert response.status_code == 200
    assert 'href="https://apps.apple.com/app/id1234567890"' in content
    assert 'data-app-store-url="https://apps.apple.com/app/id1234567890"' in content
    assert 'content="app-id=1234567890, app-argument=chooz://wishlist/cta-token"' in content
    assert "Установить CHOOZ" in content


@override_settings(APPLE_APP_SITE_ASSOCIATION_APP_ID="TEAMID.com.chooz.app")
@pytest.mark.parametrize(
    "path",
    [
        "/.well-known/apple-app-site-association",
        "/apple-app-site-association",
    ],
)
def test_apple_app_site_association_endpoints_render_expected_payload(client, path):
    response = client.get(path)
    payload = response.json()

    assert response.status_code == 200
    assert payload == {
        "applinks": {
            "apps": [],
            "details": [
                {
                    "appID": "TEAMID.com.chooz.app",
                    "paths": ["/wishlist/*"],
                }
            ],
        }
    }
