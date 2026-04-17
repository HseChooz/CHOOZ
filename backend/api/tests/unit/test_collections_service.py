import pytest

from api.graphql.collections.service import (
    filter_collection_items_by_search,
    filter_collection_items_by_tags,
    to_collection_item_type,
    to_collection_type,
    to_collections_home_type,
)
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
    assert result.tags == []


def test_filter_collection_items_by_tags_matches_any_selected_tag():
    collection = Collection.objects.create(
        slug="filter-books",
        title="Filter Books",
        section=Collection.Section.FOR_YOU,
    )
    first = CollectionItem.objects.create(
        collection=collection,
        title="Reader",
        tags=["Саморазвитие"],
    )
    second = CollectionItem.objects.create(
        collection=collection,
        title="Novel",
        tags=["Фантастика"],
    )
    third = CollectionItem.objects.create(
        collection=collection,
        title="Audio",
        tags=["Саморазвитие", "Фантастика"],
    )

    result = filter_collection_items_by_tags(
        [first, second, third],
        ["саморазвитие", "Фантастика"],
    )

    assert [item.title for item in result] == ["Reader", "Novel", "Audio"]


def test_filter_collection_items_by_search_matches_title_description_and_tags():
    collection = Collection.objects.create(
        slug="search-books",
        title="Search Books",
        section=Collection.Section.FOR_YOU,
    )
    first = CollectionItem.objects.create(
        collection=collection,
        title="Чайный набор",
        description="Для неспешных домашних вечеров",
        tags=["Уют"],
    )
    second = CollectionItem.objects.create(
        collection=collection,
        title="Настольная лампа",
        description="Мягкий свет для работы",
        tags=["Дом"],
    )

    result = filter_collection_items_by_search(
        [first, second],
        "  чай   уют ",
    )

    assert [item.title for item in result] == ["Чайный набор"]


def test_to_collection_type_can_filter_items_by_all_selected_tags(user):
    collection = Collection.objects.create(
        slug="filter-all-books",
        title="Filter All Books",
        section=Collection.Section.FOR_YOU,
        tags=["Саморазвитие", "Фантастика"],
        items_total=12,
    )
    CollectionItem.objects.create(
        collection=collection,
        title="Reader",
        tags=["Саморазвитие"],
        sort_order=10,
    )
    matching_item = CollectionItem.objects.create(
        collection=collection,
        title="Audio",
        tags=["Саморазвитие", "Фантастика"],
        sort_order=20,
    )

    result = to_collection_type(
        collection,
        user,
        selected_tags=["Саморазвитие", "Фантастика"],
        match_all_tags=True,
    )

    assert result.tags == ["Саморазвитие", "Фантастика"]
    assert result.items_count == 12
    assert [item.id for item in result.items] == [str(matching_item.id)]


def test_to_collections_home_type_can_filter_by_search_query_using_item_data():
    matching = Collection.objects.create(
        slug="reader-picks",
        title="Reader Picks",
        section=Collection.Section.FOR_YOU,
        sort_order=10,
    )
    CollectionItem.objects.create(
        collection=matching,
        title="Редкий ридер Aurora",
    )
    Collection.objects.create(
        slug="home-picks",
        title="Home Picks",
        section=Collection.Section.BY_CHARACTER,
        sort_order=10,
    )

    result = to_collections_home_type(
        Collection.objects.order_by("section", "sort_order", "id"),
        search_query="aurora",
    )

    assert [section.key for section in result.sections] == ["for_you"]
    assert [collection.slug for collection in result.sections[0].collections] == ["reader-picks"]
