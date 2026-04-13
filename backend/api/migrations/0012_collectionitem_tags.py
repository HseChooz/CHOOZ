from django.db import migrations, models

ITEM_TAGS_BY_COLLECTION = {
    "book-lovers": {
        "Kindle Paperwhite": ["Саморазвитие"],
        "Коллекционное издание 'Дюна'": ["Фантастика"],
        "Набор дизайнерских закладок": ["Для детей"],
        "Подписка на аудиокниги": ["Саморазвитие", "Фантастика"],
    },
    "top-24-hours": {
        "Беспроводные наушники": ["Хиты"],
        "Аромадиффузор": ["Тренды"],
        "Настольная лампа": ["Хиты", "Тренды"],
    },
    "recently-viewed": {
        "Термокружка": ["Популярное"],
        "Плед из микрофлиса": ["Популярное"],
        "Портативная колонка": ["Популярное"],
    },
    "eternal-kids": {
        "LEGO Botanical": ["Игры"],
        "Портативная игровая консоль": ["Игры"],
        "Набор для рисования маркерами": ["Творчество"],
    },
    "homebodies": {
        "Аромасвеча": ["Уют", "Дом"],
        "Чайный набор": ["Уют"],
        "Ночник с мягким светом": ["Релакс", "Дом"],
    },
    "spooky-seasons": {
        "Тыквенная гирлянда": ["Хэллоуин", "Декор"],
        "Набор тематических кружек": ["Хэллоуин", "Уют"],
    },
    "for-second-half": {
        "Тинт для губ": ["Женщине"],
        "Плетеная сумка": ["Женщине"],
        "Украшение с инициалом": ["Мужчине"],
        "Набор ухода за кожей": ["Мужчине"],
    },
}


def seed_collection_item_tags(apps, schema_editor):
    CollectionItem = apps.get_model("api", "CollectionItem")

    for collection_slug, items in ITEM_TAGS_BY_COLLECTION.items():
        for item_title, tags in items.items():
            CollectionItem.objects.filter(
                collection__slug=collection_slug,
                title=item_title,
            ).update(tags=tags)


def reset_collection_item_tags(apps, schema_editor):
    CollectionItem = apps.get_model("api", "CollectionItem")
    CollectionItem.objects.update(tags=[])


class Migration(migrations.Migration):
    dependencies = [
        ("api", "0011_merge_20260412_0001"),
    ]

    operations = [
        migrations.AddField(
            model_name="collectionitem",
            name="tags",
            field=models.JSONField(blank=True, default=list),
        ),
        migrations.RunPython(seed_collection_item_tags, reset_collection_item_tags),
    ]
