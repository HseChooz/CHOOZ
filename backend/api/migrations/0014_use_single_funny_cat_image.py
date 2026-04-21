from django.db import migrations

FUNNY_CAT_ASSET = "collections/shared/funny-cat.png"

COLLECTION_SLUGS = [
    "book-lovers",
    "top-24-hours",
    "recently-viewed",
    "eternal-kids",
    "homebodies",
    "spooky-seasons",
    "for-second-half",
]


def apply_single_funny_cat_image(apps, schema_editor):
    Collection = apps.get_model("api", "Collection")
    CollectionItem = apps.get_model("api", "CollectionItem")

    Collection.objects.filter(slug__in=COLLECTION_SLUGS).update(cover_image_url=FUNNY_CAT_ASSET)
    CollectionItem.objects.filter(collection__slug__in=COLLECTION_SLUGS).update(image_url=FUNNY_CAT_ASSET)


def revert_single_funny_cat_image(apps, schema_editor):
    Collection = apps.get_model("api", "Collection")
    CollectionItem = apps.get_model("api", "CollectionItem")

    Collection.objects.filter(slug__in=COLLECTION_SLUGS, cover_image_url=FUNNY_CAT_ASSET).update(
        cover_image_url=""
    )
    CollectionItem.objects.filter(
        collection__slug__in=COLLECTION_SLUGS,
        image_url=FUNNY_CAT_ASSET,
    ).update(image_url="")


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0013_hardcoded_collection_images"),
    ]

    operations = [
        migrations.RunPython(
            apply_single_funny_cat_image,
            revert_single_funny_cat_image,
        ),
    ]
