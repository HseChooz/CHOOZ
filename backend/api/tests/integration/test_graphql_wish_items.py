import pytest

from api.models import WishItem

pytestmark = pytest.mark.django_db


def test_create_wish_item_requires_auth(gql):
    response = gql(
        """
        mutation {
          createWishItem(title: "Nintendo Switch") {
            id
            title
          }
        }
        """
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "UNAUTHORIZED"


def test_create_and_list_wish_items_for_current_user_only(gql, user, another_user, access_token):
    WishItem.objects.create(owner=another_user, title="Other user item")

    create_response = gql(
        """
        mutation {
          createWishItem(title: "Steam Deck", link: "  https://example.com/deck  ") {
            id
            title
            link
          }
        }
        """,
        token=access_token,
    )
    create_payload = create_response.json()

    assert create_response.status_code == 200
    assert "errors" not in create_payload
    created = create_payload["data"]["createWishItem"]
    assert created["title"] == "Steam Deck"
    assert created["link"] == "https://example.com/deck"

    list_response = gql(
        """
        query {
          wishItems {
            id
            title
          }
        }
        """,
        token=access_token,
    )
    list_payload = list_response.json()

    assert list_response.status_code == 200
    assert [item["title"] for item in list_payload["data"]["wishItems"]] == ["Steam Deck"]


def test_create_wish_item_extracts_inline_link_from_description(gql, access_token):
    response = gql(
        """
        mutation {
          createWishItem(
            title: "Steam Deck"
            description: "Посмотреть тут https://example.com/deck"
          ) {
            title
            description
            link
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    created = payload["data"]["createWishItem"]
    assert created["title"] == "Steam Deck"
    assert created["description"] == "Посмотреть тут"
    assert created["link"] == "https://example.com/deck"


def test_update_wish_item_extracts_inline_link_from_description(gql, user, access_token):
    item = WishItem.objects.create(owner=user, title="Book")

    response = gql(
        f"""
        mutation {{
          updateWishItem(
            id: "{item.id}"
            description: "Заказать здесь https://example.com/book"
          ) {{
            id
            description
            link
          }}
        }}
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    updated = payload["data"]["updateWishItem"]
    assert updated["id"] == str(item.id)
    assert updated["description"] == "Заказать здесь"
    assert updated["link"] == "https://example.com/book"
