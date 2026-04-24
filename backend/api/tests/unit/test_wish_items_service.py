from decimal import Decimal

import pytest
from graphql import GraphQLError

from api.graphql.wish_items.service import get_owned_wish_item, to_wish_item_type
from api.models import WishItem

pytestmark = pytest.mark.django_db


def test_get_owned_wish_item_returns_item_for_owner(user):
    item = WishItem.objects.create(owner=user, title="Steam Deck")

    found = get_owned_wish_item(user, str(item.id))

    assert found.id == item.id


def test_get_owned_wish_item_raises_for_not_owner(user, another_user):
    item = WishItem.objects.create(owner=user, title="PS5")

    with pytest.raises(GraphQLError) as exc:
        get_owned_wish_item(another_user, str(item.id))

    assert exc.value.extensions["code"] == "WISH_ITEM_NOT_FOUND"


def test_to_wish_item_type_generates_presigned_image_url(user, monkeypatch):
    item = WishItem.objects.create(
        owner=user,
        title="Camera",
        description="Mirrorless",
        link="https://example.com/camera",
        price=Decimal("999.90"),
        currency="usd",
        image_key="  images/camera.png  ",
    )

    def fake_presigned_get_url(key: str) -> str:
        return f"https://cdn.local/{key}"

    monkeypatch.setattr(
        "api.graphql.wish_items.service.presigned_get_url",
        fake_presigned_get_url,
    )

    result = to_wish_item_type(item)

    assert result.id == str(item.id)
    assert result.price == 999.9
    assert result.currency == "usd"
    assert result.image_url == "https://cdn.local/images/camera.png"


def test_to_wish_item_type_skips_presigned_url_when_no_image_key(user, monkeypatch):
    item = WishItem.objects.create(owner=user, title="Book", image_key="   ")
    calls: list[str] = []

    def fake_presigned_get_url(key: str) -> str:
        calls.append(key)
        return "unused"

    monkeypatch.setattr(
        "api.graphql.wish_items.service.presigned_get_url",
        fake_presigned_get_url,
    )

    result = to_wish_item_type(item)

    assert result.image_url is None
    assert calls == []


def test_to_wish_item_type_falls_back_to_collection_item_image(user, monkeypatch):
    from api.models import Collection, CollectionItem

    collection = Collection.objects.create(
        slug="service-collection",
        title="Service Collection",
        section=Collection.Section.FOR_YOU,
    )
    collection_item = CollectionItem.objects.create(
        collection=collection,
        title="Cat card",
        image_url="collections/shared/funny-cat.png",
    )
    item = WishItem.objects.create(
        owner=user,
        title="Cat card",
        image_key="",
        collection_item=collection_item,
    )
    calls: list[str] = []

    def fake_presigned_get_url(key: str) -> str:
        calls.append(key)
        return "unused"

    monkeypatch.setattr(
        "api.graphql.wish_items.service.presigned_get_url",
        fake_presigned_get_url,
    )

    result = to_wish_item_type(item)

    assert result.image_url == "/api/assets/collections/shared/funny-cat.png"
    assert calls == []
