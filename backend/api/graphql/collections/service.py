from collections import OrderedDict
from collections.abc import Iterable
from urllib.parse import urlsplit

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
HARDCODED_ASSET_ROUTE_PREFIX = "/api/assets/"
HARDCODED_COLLECTIONS_ASSET_PREFIX = "collections/"


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


def normalize_tags(tags: Iterable[str] | None) -> list[str]:
    normalized_tags: list[str] = []
    seen_tags: set[str] = set()

    for tag in tags or []:
        value = (tag or "").strip()
        if not value:
            continue
        key = value.casefold()
        if key in seen_tags:
            continue
        seen_tags.add(key)
        normalized_tags.append(value)

    return normalized_tags


def normalize_search_terms(search_query: str | None) -> list[str]:
    normalized_terms: list[str] = []
    seen_terms: set[str] = set()

    for part in (search_query or "").split():
        value = part.strip().casefold()
        if not value or value in seen_terms:
            continue
        seen_terms.add(value)
        normalized_terms.append(value)

    return normalized_terms


def matches_search_terms(search_terms: Iterable[str], values: Iterable[str | None]) -> bool:
    normalized_terms = list(search_terms)
    if not normalized_terms:
        return True

    haystack = " ".join(value.casefold() for value in values if value)
    return all(term in haystack for term in normalized_terms)


def resolve_collection_asset_url(
    value: str | None,
    *,
    request=None,
) -> str | None:
    raw_value = (value or "").strip()
    if not raw_value:
        return None

    parsed = urlsplit(raw_value)
    if parsed.scheme and parsed.netloc:
        return raw_value

    normalized_value = raw_value.lstrip("/")
    if normalized_value.startswith(HARDCODED_COLLECTIONS_ASSET_PREFIX):
        resolved_path = f"{HARDCODED_ASSET_ROUTE_PREFIX}{normalized_value}"
    else:
        resolved_path = f"/{normalized_value}"

    if request is None:
        return resolved_path

    return request.build_absolute_uri(resolved_path)


def collection_available_tags(
    collection: Collection,
    collection_items: Iterable[CollectionItem] | None = None,
) -> list[str]:
    available_tags = normalize_tags(collection.tags or [])
    if available_tags:
        return available_tags

    inferred_tags: list[str] = []
    seen_tags: set[str] = set()

    for item in collection_items or collection.items.all():
        for tag in normalize_tags(getattr(item, "tags", []) or []):
            key = tag.casefold()
            if key in seen_tags:
                continue
            seen_tags.add(key)
            inferred_tags.append(tag)

    return inferred_tags


def filter_collection_items_by_tags(
    collection_items: Iterable[CollectionItem],
    selected_tags: Iterable[str] | None,
    *,
    match_all_tags: bool = False,
) -> list[CollectionItem]:
    normalized_selected_tags = normalize_tags(selected_tags)
    if not normalized_selected_tags:
        return list(collection_items)

    selected_tag_keys = {tag.casefold() for tag in normalized_selected_tags}
    filtered_items: list[CollectionItem] = []

    for item in collection_items:
        item_tag_keys = {
            tag.casefold()
            for tag in normalize_tags(getattr(item, "tags", []) or [])
        }
        if not item_tag_keys:
            continue

        if match_all_tags and selected_tag_keys.issubset(item_tag_keys):
            filtered_items.append(item)
            continue

        if not match_all_tags and item_tag_keys.intersection(selected_tag_keys):
            filtered_items.append(item)

    return filtered_items


def filter_collection_items_by_search(
    collection_items: Iterable[CollectionItem],
    search_query: str | None,
) -> list[CollectionItem]:
    normalized_terms = normalize_search_terms(search_query)
    if not normalized_terms:
        return list(collection_items)

    filtered_items: list[CollectionItem] = []

    for item in collection_items:
        if matches_search_terms(
            normalized_terms,
            [
                item.title,
                item.description,
                item.link,
                *normalize_tags(getattr(item, "tags", []) or []),
            ],
        ):
            filtered_items.append(item)

    return filtered_items


def filter_collections_by_search(
    collections: Iterable[Collection],
    search_query: str | None,
) -> list[Collection]:
    normalized_terms = normalize_search_terms(search_query)
    if not normalized_terms:
        return list(collections)

    filtered_collections: list[Collection] = []

    for collection in collections:
        collection_items = list(collection.items.all())
        search_values = [
            collection.title,
            collection.subtitle,
            collection.description,
            collection.badge,
            *normalize_tags(collection.tags or []),
        ]
        for item in collection_items:
            search_values.extend(
                [
                    item.title,
                    item.description,
                    item.link,
                    *normalize_tags(getattr(item, "tags", []) or []),
                ]
            )

        if matches_search_terms(normalized_terms, search_values):
            filtered_collections.append(collection)

    return filtered_collections


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


def to_collection_preview_type(collection: Collection, *, request=None) -> CollectionPreviewType:
    return CollectionPreviewType(
        id=str(collection.id),
        slug=collection.slug,
        title=collection.title,
        subtitle=collection.subtitle,
        badge=collection.badge or None,
        cover_image_url=resolve_collection_asset_url(
            collection.cover_image_url,
            request=request,
        ),
        items_count=_items_count(collection),
    )


def to_collection_item_type(
    item: CollectionItem,
    wish_item: WishItem | None = None,
    *,
    request=None,
) -> CollectionItemType:
    return CollectionItemType(
        id=str(item.id),
        title=item.title,
        description=item.description,
        link=item.link or None,
        price=float(item.price) if item.price is not None else None,
        currency=item.currency or None,
        tags=normalize_tags(item.tags or []),
        image_url=resolve_collection_asset_url(item.image_url, request=request),
        is_added=wish_item is not None,
        wish_item_id=str(wish_item.id) if wish_item is not None else None,
    )


def to_collection_type(
    collection: Collection,
    user,
    *,
    request=None,
    selected_tags: Iterable[str] | None = None,
    match_all_tags: bool = False,
    search_query: str | None = None,
) -> CollectionType:
    all_items = list(collection.items.all())
    items = filter_collection_items_by_tags(
        all_items,
        selected_tags,
        match_all_tags=match_all_tags,
    )
    items = filter_collection_items_by_search(items, search_query)
    wish_map = build_collection_item_wish_map(user, items)
    return CollectionType(
        id=str(collection.id),
        slug=collection.slug,
        title=collection.title,
        subtitle=collection.subtitle,
        description=collection.description,
        badge=collection.badge or None,
        cover_image_url=resolve_collection_asset_url(
            collection.cover_image_url,
            request=request,
        ),
        section_key=collection.section,
        section_title=collection.get_section_display(),
        tags=collection_available_tags(collection, all_items),
        items_count=_items_count(collection),
        items=[
            to_collection_item_type(
                item,
                wish_map.get(item.id),
                request=request,
            )
            for item in items
        ],
    )


def to_collections_home_type(
    collections: Iterable[Collection],
    *,
    request=None,
    search_query: str | None = None,
) -> CollectionsHomeType:
    sections_map: OrderedDict[str, CollectionSectionType] = OrderedDict()
    filtered_collections = filter_collections_by_search(collections, search_query)

    for section in SECTION_ORDER:
        section_collections = [
            collection
            for collection in filtered_collections
            if collection.section == section
        ]
        if not section_collections:
            continue
        sections_map[str(section)] = CollectionSectionType(
            key=str(section),
            title=section.label,
            collections=[
                to_collection_preview_type(collection, request=request)
                for collection in section_collections
            ],
        )

    return CollectionsHomeType(sections=list(sections_map.values()))
