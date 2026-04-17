from collections import OrderedDict
from collections.abc import Iterable

from django.db.models import Count

from api.graphql.errors import gql_error
from api.graphql.types import (
    CollectionItemType,
    CollectionPreviewType,
    CollectionSectionType,
    CollectionsHomeType,
    CollectionType,
)
from api.models import Collection, CollectionItem, WishItem

SECTION_ORDER = [
    Collection.Section.FOR_YOU,
    Collection.Section.BY_CHARACTER,
    Collection.Section.EDITORIAL,
]


def require_user(info):
    user = info.context.request.user
    if not user or not user.is_authenticated:
        gql_error("UNAUTHORIZED", "Unauthorized")
    return user


def collections_qs():
    return Collection.objects.annotate(items_count=Count("items")).prefetch_related("items")


def get_collection_by_slug(slug: str) -> Collection | None:
    return collections_qs().filter(slug=slug).first()


def get_collection_item(collection_item_id: str) -> CollectionItem:
    try:
        return CollectionItem.objects.select_related("collection").get(id=collection_item_id)
    except CollectionItem.DoesNotExist:
        gql_error("COLLECTION_ITEM_NOT_FOUND", "Collection item not found")


def build_collection_item_wish_map(
    user,
    collection_items: Iterable[CollectionItem],
) -> dict[int, WishItem]:
    collection_item_ids = [item.id for item in collection_items]
    if not collection_item_ids:
        return {}
    wish_items = WishItem.objects.filter(
        owner=user,
        collection_item_id__in=collection_item_ids,
    )
    return {
        wish_item.collection_item_id: wish_item
        for wish_item in wish_items
        if wish_item.collection_item_id
    }


def _items_count(collection: Collection) -> int:
    if collection.items_total:
        return collection.items_total
    annotated = getattr(collection, "items_count", None)
    if annotated is not None:
        return annotated
    prefetched = getattr(collection, "_prefetched_objects_cache", {})
    if "items" in prefetched:
        return len(prefetched["items"])
    return collection.items.count()


def to_collection_preview_type(collection: Collection) -> CollectionPreviewType:
    return CollectionPreviewType(
        id=str(collection.id),
        slug=collection.slug,
        title=collection.title,
        subtitle=collection.subtitle,
        badge=collection.badge or None,
        cover_image_url=collection.cover_image_url or None,
        items_count=_items_count(collection),
    )


def to_collection_item_type(
    item: CollectionItem,
    wish_item: WishItem | None = None,
) -> CollectionItemType:
    return CollectionItemType(
        id=str(item.id),
        title=item.title,
        description=item.description,
        link=item.link or None,
        price=float(item.price) if item.price is not None else None,
        currency=item.currency or None,
        image_url=item.image_url or None,
        is_added=wish_item is not None,
        wish_item_id=str(wish_item.id) if wish_item is not None else None,
    )


def to_collection_type(collection: Collection, user) -> CollectionType:
    items = list(collection.items.all())
    wish_map = build_collection_item_wish_map(user, items)
    return CollectionType(
        id=str(collection.id),
        slug=collection.slug,
        title=collection.title,
        subtitle=collection.subtitle,
        description=collection.description,
        badge=collection.badge or None,
        cover_image_url=collection.cover_image_url or None,
        section_key=collection.section,
        section_title=collection.get_section_display(),
        tags=[str(tag) for tag in (collection.tags or [])],
        items_count=_items_count(collection),
        items=[to_collection_item_type(item, wish_map.get(item.id)) for item in items],
    )


def to_collections_home_type(collections: Iterable[Collection]) -> CollectionsHomeType:
    sections_map: OrderedDict[str, CollectionSectionType] = OrderedDict()

    for section in SECTION_ORDER:
        section_collections = [
            collection
            for collection in collections
            if collection.section == section
        ]
        if not section_collections:
            continue
        sections_map[str(section)] = CollectionSectionType(
            key=str(section),
            title=section.label,
            collections=[
                to_collection_preview_type(collection)
                for collection in section_collections
            ],
        )

    return CollectionsHomeType(sections=list(sections_map.values()))
