from django.db import migrations

COLLECTION_COVER_ASSETS = {
    "book-lovers": "collections/book-lovers/cover.svg",
    "top-24-hours": "collections/top-24-hours/cover.svg",
    "recently-viewed": "collections/recently-viewed/cover.svg",
    "eternal-kids": "collections/eternal-kids/cover.svg",
    "homebodies": "collections/homebodies/cover.svg",
    "spooky-seasons": "collections/spooky-seasons/cover.svg",
    "for-second-half": "collections/for-second-half/cover.svg",
}

COLLECTION_ITEM_ASSETS = {
    "book-lovers": {
        "Kindle Paperwhite": "collections/book-lovers/kindle-paperwhite.svg",
        "Коллекционное издание 'Дюна'": "collections/book-lovers/dune-collectors-edition.svg",
        "Набор дизайнерских закладок": "collections/book-lovers/designer-bookmarks.svg",
        "Подписка на аудиокниги": "collections/book-lovers/audiobooks-subscription.svg",
    },
    "top-24-hours": {
        "Беспроводные наушники": "collections/top-24-hours/wireless-headphones.svg",
        "Аромадиффузор": "collections/top-24-hours/aroma-diffuser.svg",
        "Настольная лампа": "collections/top-24-hours/desk-lamp.svg",
    },
    "recently-viewed": {
        "Термокружка": "collections/recently-viewed/thermal-mug.svg",
        "Плед из микрофлиса": "collections/recently-viewed/microfleece-blanket.svg",
        "Портативная колонка": "collections/recently-viewed/portable-speaker.svg",
    },
    "eternal-kids": {
        "LEGO Botanical": "collections/eternal-kids/lego-botanical.svg",
        "Портативная игровая консоль": "collections/eternal-kids/portable-console.svg",
        "Набор для рисования маркерами": "collections/eternal-kids/marker-art-set.svg",
    },
    "homebodies": {
        "Аромасвеча": "collections/homebodies/aroma-candle.svg",
        "Чайный набор": "collections/homebodies/tea-set.svg",
        "Ночник с мягким светом": "collections/homebodies/night-light.svg",
    },
    "spooky-seasons": {
        "Тыквенная гирлянда": "collections/spooky-seasons/pumpkin-garland.svg",
        "Набор тематических кружек": "collections/spooky-seasons/themed-mugs.svg",
    },
    "for-second-half": {
        "Тинт для губ": "collections/for-second-half/lip-tint.svg",
        "Плетеная сумка": "collections/for-second-half/woven-bag.svg",
        "Украшение с инициалом": "collections/for-second-half/initial-jewelry.svg",
        "Набор ухода за кожей": "collections/for-second-half/skincare-set.svg",
    },
}


def apply_hardcoded_collection_images(apps, schema_editor):
    Collection = apps.get_model("api", "Collection")
    CollectionItem = apps.get_model("api", "CollectionItem")

    for slug, cover_asset in COLLECTION_COVER_ASSETS.items():
        Collection.objects.filter(slug=slug).update(cover_image_url=cover_asset)

    for collection_slug, items in COLLECTION_ITEM_ASSETS.items():
        for title, image_asset in items.items():
            CollectionItem.objects.filter(
                collection__slug=collection_slug,
                title=title,
            ).update(image_url=image_asset)


def revert_to_placeholder_collection_images(apps, schema_editor):
    Collection = apps.get_model("api", "Collection")
    CollectionItem = apps.get_model("api", "CollectionItem")

    Collection.objects.filter(slug__in=COLLECTION_COVER_ASSETS).update(cover_image_url="")

    for collection_slug, items in COLLECTION_ITEM_ASSETS.items():
        CollectionItem.objects.filter(
            collection__slug=collection_slug,
            title__in=list(items),
        ).update(image_url="")


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0012_collectionitem_tags"),
    ]

    operations = [
        migrations.RunPython(
            apply_hardcoded_collection_images,
            revert_to_placeholder_collection_images,
        ),
    ]
