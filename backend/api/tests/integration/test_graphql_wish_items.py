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
            isFromCollection
          }
        }
        """,
        token=access_token,
    )
    list_payload = list_response.json()

    assert list_response.status_code == 200
    assert [item["title"] for item in list_payload["data"]["wishItems"]] == ["Steam Deck"]
    assert list_payload["data"]["wishItems"][0]["isFromCollection"] is False


def test_wish_items_marks_items_added_from_collection(gql, user, access_token):
    from api.models import Collection, CollectionItem

    collection = Collection.objects.create(
        slug="wishlist-source",
        title="Wishlist Source",
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
        collection_item=collection_item,
    )

    response = gql(
        """
        query {
          wishItems {
            title
            imageUrl
            isFromCollection
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["wishItems"] == [
        {
            "title": "Collection Lamp",
            "imageUrl": "http://testserver/api/assets/collections/shared/funny-cat.png",
            "isFromCollection": True,
        }
    ]
