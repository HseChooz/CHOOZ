import json
from decimal import Decimal
from pathlib import Path

from django.db import migrations

DATA_FILE = Path(__file__).resolve().parent / "data" / "collections_spreadsheet_seed_20260602.json"


def load_seed_payload():
    return json.loads(DATA_FILE.read_text(encoding="utf-8"))


def to_decimal(value: str | None):
    raw_value = (value or "").strip()
    if not raw_value:
        return None
    return Decimal(raw_value)


def sync_updated_spreadsheet_collections(apps, schema_editor):
    Collection = apps.get_model("api", "Collection")
    CollectionItem = apps.get_model("api", "CollectionItem")
    CollectionSection = apps.get_model("api", "CollectionSection")

    payload = load_seed_payload()
    section_ids_by_slug: dict[str, int] = {}

    for section_data in payload["sections"]:
        section, _created = CollectionSection.objects.update_or_create(
            slug=section_data["slug"],
            defaults={
                "title": section_data["title"],
                "sort_order": section_data["sort_order"],
            },
        )
        section_ids_by_slug[section.slug] = section.id

    kept_collection_ids: list[int] = []
    for collection_data in payload["collections"]:
        section_slugs = collection_data["section_slugs"]
        collection, _created = Collection.objects.update_or_create(
            slug=collection_data["slug"],
            defaults={
                "title": collection_data["title"],
                "subtitle": collection_data["subtitle"],
                "description": collection_data["description"],
                "section": collection_data["section"],
                "badge": collection_data["badge"],
                "cover_image_url": collection_data["cover_image_url"],
                "tags": collection_data["tags"],
                "items_total": collection_data["items_total"],
                "sort_order": collection_data["sort_order"],
            },
        )
        kept_collection_ids.append(collection.id)

        section_ids = [
            section_ids_by_slug[section_slug]
            for section_slug in section_slugs
            if section_slug in section_ids_by_slug
        ]
        collection.sections.set(section_ids)

        kept_item_ids: list[int] = []
        for item_data in collection_data["items"]:
            item, _created = CollectionItem.objects.update_or_create(
                collection=collection,
                title=item_data["title"],
                defaults={
                    "description": item_data["description"],
                    "link": item_data["link"],
                    "price": to_decimal(item_data["price"]),
                    "currency": item_data["currency"],
                    "image_url": item_data["image_url"],
                    "tags": item_data["tags"],
                    "sort_order": item_data["sort_order"],
                },
            )
            kept_item_ids.append(item.id)

        CollectionItem.objects.filter(collection=collection).exclude(id__in=kept_item_ids).delete()

    Collection.objects.exclude(id__in=kept_collection_ids).delete()
    CollectionSection.objects.exclude(id__in=section_ids_by_slug.values()).delete()


class Migration(migrations.Migration):

    dependencies = [
        ("api", "0018_wishlistsharelink"),
    ]

    operations = [
        migrations.RunPython(
            sync_updated_spreadsheet_collections,
            migrations.RunPython.noop,
        ),
    ]
