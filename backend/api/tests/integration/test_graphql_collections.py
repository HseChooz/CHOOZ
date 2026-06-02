import pytest

from api.models import Collection, CollectionItem, CollectionSection, WishItem
from api.yandex_disk import encode_yandex_public_asset_url

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
    assert [section["key"] for section in sections] == [
        "for_you",
        "by_character",
        "editorial",
        "gift_ideas",
    ]
    sections_by_key = {section["key"]: section for section in sections}
    assert sections_by_key["for_you"]["title"] == "Подборки для вас"
    assert sections_by_key["for_you"]["collections"][0]["slug"] == "book-lovers"
    assert "book-lovers" in {
        collection["slug"]
        for collection in sections_by_key["gift_ideas"]["collections"]
    }


def test_collections_home_returns_sections_from_spreadsheet_seed(gql, access_token):
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
    assert [section["key"] for section in sections] == [
        "for_you",
        "by_character",
        "editorial",
        "gift_ideas",
    ]
    sections_by_key = {section["key"]: section for section in sections}
    assert sections_by_key["for_you"]["collections"][0]["slug"] == "book-lovers"
    assert sections_by_key["for_you"]["collections"][0]["itemsCount"] == 1
    assert sections_by_key["for_you"]["collections"][0]["coverImageUrl"].startswith(
        "http://testserver/api/assets/yandex-public/"
    )
    assert sections_by_key["editorial"]["collections"][0]["slug"] == "egor"
    assert "romantic" in {
        collection["slug"]
        for collection in sections_by_key["gift_ideas"]["collections"]
    }


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
        variables={"search": "  орден феникса "},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    sections = payload["data"]["collectionsHome"]["sections"]
    assert [section["key"] for section in sections] == ["for_you", "gift_ideas"]
    for section in sections:
        assert [collection["slug"] for collection in section["collections"]] == ["book-lovers"]


def test_collection_query_returns_items_and_added_state(gql, access_token, user):
    collection = Collection.objects.get(slug="book-lovers")
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
            sectionTitle
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
        variables={"slug": "book-lovers"},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    result = payload["data"]["collection"]
    assert result["slug"] == "book-lovers"
    assert result["title"] == "Книголюбы"
    assert result["coverImageUrl"].startswith("http://testserver/api/assets/yandex-public/")
    assert result["sectionKey"] == "for_you"
    assert result["sectionTitle"] == "Подборки для вас"
    assert result["itemsCount"] == 1
    assert result["tags"] == ["Саморазвитие", "Книги"]
    assert result["items"][0]["id"] == str(first_item.id)
    assert result["items"][0]["tags"] == ["Саморазвитие", "Книги"]
    assert result["items"][0]["imageUrl"].startswith("http://testserver/api/assets/yandex-public/")
    assert result["items"][0]["isAdded"] is True
    assert result["items"][0]["wishItemId"] == str(linked_wish.id)


def test_collection_query_filters_items_by_single_tag(gql, access_token):
    section = CollectionSection.objects.get(slug="for_you")
    collection = Collection.objects.create(
        slug="filter-tags",
        title="Filter Tags",
        description="Testing tags",
        section=Collection.Section.FOR_YOU,
    )
    collection.sections.add(section)
    CollectionItem.objects.create(
        collection=collection,
        title="Mindset book",
        tags=["Саморазвитие"],
        sort_order=10,
    )
    CollectionItem.objects.create(
        collection=collection,
        title="Toy robot",
        tags=["Игрушки"],
        sort_order=20,
    )
    CollectionItem.objects.create(
        collection=collection,
        title="Audio guide",
        tags=["Саморазвитие", "Игрушки"],
        sort_order=30,
    )

    response = gql(
        """
        query($slug: String!, $tags: [String!]) {
          collection(slug: $slug, tags: $tags) {
            items {
              title
              tags
            }
          }
        }
        """,
        variables={"slug": "filter-tags", "tags": ["Саморазвитие"]},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert [item["title"] for item in payload["data"]["collection"]["items"]] == [
        "Mindset book",
        "Audio guide",
    ]


def test_collection_query_supports_match_all_tags(gql, access_token):
    section = CollectionSection.objects.get(slug="gift_ideas")
    collection = Collection.objects.create(
        slug="filter-all-tags",
        title="Filter All Tags",
        description="Testing match all",
        section=Collection.Section.GIFT_IDEAS,
    )
    collection.sections.add(section)
    CollectionItem.objects.create(
        collection=collection,
        title="Only care",
        tags=["Забота"],
        sort_order=10,
    )
    CollectionItem.objects.create(
        collection=collection,
        title="Care and relax",
        tags=["Забота", "Релакс"],
        sort_order=20,
    )

    response = gql(
        """
        query($slug: String!, $tags: [String!], $matchAllTags: Boolean!) {
          collection(slug: $slug, tags: $tags, matchAllTags: $matchAllTags) {
            items {
              title
            }
          }
        }
        """,
        variables={
            "slug": "filter-all-tags",
            "tags": ["Забота", "Релакс"],
            "matchAllTags": True,
        },
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert [item["title"] for item in payload["data"]["collection"]["items"]] == [
        "Care and relax",
    ]


def test_collection_query_filters_items_by_search_query(gql, access_token):
    section = CollectionSection.objects.get(slug="by_character")
    collection = Collection.objects.create(
        slug="filter-search",
        title="Filter Search",
        description="Testing search",
        section=Collection.Section.BY_CHARACTER,
    )
    collection.sections.add(section)
    CollectionItem.objects.create(
        collection=collection,
        title="SPA set",
        description="Домашний spa набор",
        sort_order=10,
    )
    CollectionItem.objects.create(
        collection=collection,
        title="Cinema ticket",
        description="Билет в кино",
        sort_order=20,
    )

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
        variables={"slug": "filter-search", "search": " spa "},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    assert [item["title"] for item in payload["data"]["collection"]["items"]] == [
        "SPA set",
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
    assert result["imageUrl"].startswith("http://testserver/api/assets/yandex-public/")
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
    assert list_payload["data"]["wishItems"][0]["imageUrl"].startswith(
        "http://testserver/api/assets/yandex-public/"
    )


def test_hardcoded_asset_endpoint_serves_collection_png(client):
    response = client.get("/api/assets/collections/shared/funny-cat.png")

    assert response.status_code == 200
    assert response["Content-Type"] == "image/png"
    body = b"".join(response.streaming_content)
    assert body.startswith(b"\x89PNG\r\n\x1a\n")


def test_yandex_public_asset_endpoint_redirects_to_download_url(client, monkeypatch):
    monkeypatch.setattr(
        "api.views.resolve_yandex_public_download_url",
        lambda _value: "https://cdn.example.com/collection.jpg",
    )
    token = encode_yandex_public_asset_url("https://disk.yandex.ru/i/example-public-image")

    response = client.get(f"/api/assets/yandex-public/{token}")

    assert response.status_code == 302
    assert response["Location"] == "https://cdn.example.com/collection.jpg"


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
