import pytest

from api.models import Collection, CollectionItem, WishItem

pytestmark = pytest.mark.django_db


def test_collection_sections_returns_sections_without_home_wrapper(gql, access_token):
    response = gql(
        """
        query {
          collectionSections {
            key
            title
            collections {
              slug
              title
            }
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    sections = payload["data"]["collectionSections"]
    assert [section["key"] for section in sections] == ["for_you", "by_character", "editorial"]
    assert sections[0]["title"] == "Подборки для вас"
    assert sections[0]["collections"][0]["slug"] == "book-lovers"


def test_collections_home_returns_sections_with_hardcoded_collections(gql, access_token):
    response = gql(
        """
        query {
          collectionsHome {
            sections {
              key
              title
              collections {
                slug
                title
                coverImageUrl
                itemsCount
              }
            }
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    sections = payload["data"]["collectionsHome"]["sections"]
    assert [section["key"] for section in sections] == ["for_you", "by_character", "editorial"]
    assert sections[0]["collections"][0]["slug"] == "book-lovers"
    assert sections[0]["collections"][0]["coverImageUrl"] == (
        "http://testserver/api/assets/collections/shared/funny-cat.png"
    )
    assert sections[0]["collections"][0]["itemsCount"] == 15
    assert sections[2]["collections"][0]["title"] == "Spooky Seasons"


def test_collections_home_filters_collections_by_search_query(gql, access_token):
    response = gql(
        """
        query($search: String) {
          collectionsHome(search: $search) {
            sections {
              key
              collections {
                slug
                title
              }
            }
          }
        }
        """,
        variables={"search": "  paperwhite "},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    sections = payload["data"]["collectionsHome"]["sections"]
    assert [section["key"] for section in sections] == ["for_you"]
    assert [collection["slug"] for collection in sections[0]["collections"]] == ["book-lovers"]


def test_collection_query_returns_items_and_added_state(gql, access_token, user):
    collection = Collection.objects.get(slug="for-second-half")
    first_item = collection.items.order_by("sort_order", "id").first()
    assert first_item is not None

    linked_wish = WishItem.objects.create(
        owner=user,
        collection_item=first_item,
        title=first_item.title,
        description=first_item.description,
        link=first_item.link,
        price=first_item.price,
        currency=first_item.currency,
    )

    response = gql(
        """
        query($slug: String!) {
          collection(slug: $slug) {
            slug
            title
            coverImageUrl
            sectionKey
            itemsCount
            tags
            items {
              id
              title
              tags
              imageUrl
              isAdded
              wishItemId
            }
          }
        }
        """,
        variables={"slug": "for-second-half"},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    result = payload["data"]["collection"]
    assert result["slug"] == "for-second-half"
    assert result["coverImageUrl"] == (
        "http://testserver/api/assets/collections/shared/funny-cat.png"
    )
    assert result["sectionKey"] == "editorial"
    assert result["itemsCount"] == 18
    assert result["tags"] == ["Женщине", "Мужчине"]
    assert result["items"][0]["id"] == str(first_item.id)
    assert result["items"][0]["tags"] == ["Женщине"]
    assert result["items"][0]["imageUrl"] == (
        "http://testserver/api/assets/collections/shared/funny-cat.png"
    )
    assert result["items"][0]["isAdded"] is True
    assert result["items"][0]["wishItemId"] == str(linked_wish.id)


def test_collection_query_filters_items_by_single_tag(gql, access_token):
    response = gql(
        """
        query($slug: String!, $tags: [String!]) {
          collection(slug: $slug, tags: $tags) {
            tags
            items {
              title
              tags
            }
          }
        }
        """,
        variables={"slug": "book-lovers", "tags": ["Саморазвитие"]},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    result = payload["data"]["collection"]
    assert result["tags"] == ["Саморазвитие", "Для детей", "Фантастика"]
    assert [item["title"] for item in result["items"]] == [
        "Kindle Paperwhite",
        "Подписка на аудиокниги",
    ]


def test_collection_query_supports_match_all_tags(gql, access_token):
    response = gql(
        """
        query($slug: String!, $tags: [String!], $matchAllTags: Boolean!) {
          collection(slug: $slug, tags: $tags, matchAllTags: $matchAllTags) {
            items {
              title
              tags
            }
          }
        }
        """,
        variables={
            "slug": "book-lovers",
            "tags": ["Саморазвитие", "Фантастика"],
            "matchAllTags": True,
        },
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert [item["title"] for item in payload["data"]["collection"]["items"]] == [
        "Подписка на аудиокниги",
    ]


def test_collection_query_filters_items_by_search_query(gql, access_token):
    response = gql(
        """
        query($slug: String!, $search: String) {
          collection(slug: $slug, search: $search) {
            items {
              title
            }
          }
        }
        """,
        variables={"slug": "for-second-half", "search": " spa "},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert [item["title"] for item in payload["data"]["collection"]["items"]] == [
        "Набор ухода за кожей",
    ]


def test_add_collection_item_to_wishlist_creates_linked_wish_item(gql, access_token, user):
    collection_item = (
        CollectionItem.objects.filter(collection__slug="book-lovers")
        .order_by("sort_order", "id")
        .first()
    )
    assert collection_item is not None

    response = gql(
        """
        mutation($collectionItemId: ID!) {
          addCollectionItemToWishlist(collectionItemId: $collectionItemId) {
            id
            title
            imageUrl
            isAdded
            wishItemId
          }
        }
        """,
        variables={"collectionItemId": str(collection_item.id)},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    result = payload["data"]["addCollectionItemToWishlist"]
    wish_item = WishItem.objects.get(owner=user, collection_item=collection_item)
    assert result["id"] == str(collection_item.id)
    assert result["title"] == collection_item.title
    assert result["imageUrl"] == (
        "http://testserver/api/assets/collections/shared/funny-cat.png"
    )
    assert result["isAdded"] is True
    assert result["wishItemId"] == str(wish_item.id)
    assert wish_item.title == collection_item.title
    assert wish_item.link == collection_item.link

    list_response = gql(
        """
        query {
          wishItems {
            id
            title
            imageUrl
          }
        }
        """,
        token=access_token,
    )
    list_payload = list_response.json()

    assert list_response.status_code == 200
    assert "errors" not in list_payload
    assert list_payload["data"]["wishItems"][0]["imageUrl"] == (
        "/api/assets/collections/shared/funny-cat.png"
    )


def test_hardcoded_asset_endpoint_serves_collection_png(client):
    response = client.get("/api/assets/collections/shared/funny-cat.png")

    assert response.status_code == 200
    assert response["Content-Type"] == "image/png"
    body = b"".join(response.streaming_content)
    assert body.startswith(b"\x89PNG\r\n\x1a\n")


def test_remove_collection_item_from_wishlist_deletes_linked_wish_item(gql, access_token, user):
    collection_item = (
        CollectionItem.objects.filter(collection__slug="book-lovers")
        .order_by("sort_order", "id")
        .first()
    )
    assert collection_item is not None
    wish_item = WishItem.objects.create(
        owner=user,
        collection_item=collection_item,
        title=collection_item.title,
        description=collection_item.description,
        link=collection_item.link,
        price=collection_item.price,
        currency=collection_item.currency,
    )

    response = gql(
        """
        mutation($collectionItemId: ID!) {
          removeCollectionItemFromWishlist(collectionItemId: $collectionItemId) {
            id
            isAdded
            wishItemId
          }
        }
        """,
        variables={"collectionItemId": str(collection_item.id)},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    result = payload["data"]["removeCollectionItemFromWishlist"]
    assert result["id"] == str(collection_item.id)
    assert result["isAdded"] is False
    assert result["wishItemId"] is None
    assert WishItem.objects.filter(id=wish_item.id).exists() is False
