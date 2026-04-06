import pytest

from api.graphql.collections.service import to_collection_item_type, to_collections_home_type
from api.models import Collection, CollectionItem, WishItem

pytestmark = pytest.mark.django_db


def test_to_collections_home_type_groups_sections_in_fixed_order():
    editorial = Collection.objects.create(
        slug="editorial-first",
        title="Editorial",
        section=Collection.Section.EDITORIAL,
        sort_order=10,
    )
    for_you = Collection.objects.create(
        slug="for-you-first",
        title="For You",
        section=Collection.Section.FOR_YOU,
        sort_order=10,
    )

    result = to_collections_home_type([editorial, for_you])

    assert [section.key for section in result.sections] == ["for_you", "editorial"]
    assert result.sections[0].collections[0].slug == "for-you-first"


def test_to_collection_item_type_marks_item_as_added_when_linked_wish_exists(user):
    collection = Collection.objects.create(
        slug="service-books",
        title="Service Books",
        section=Collection.Section.FOR_YOU,
    )
    collection_item = CollectionItem.objects.create(
        collection=collection,
        title="Reader",
        price="14990.00",
        currency="rub",
    )
    wish_item = WishItem.objects.create(
        owner=user,
        collection_item=collection_item,
        title=collection_item.title,
    )

    result = to_collection_item_type(collection_item, wish_item)

    assert result.id == str(collection_item.id)
    assert result.is_added is True
    assert result.wish_item_id == str(wish_item.id)
    assert result.price == 14990.0
