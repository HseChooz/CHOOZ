from time import sleep

import pytest
from graphql import GraphQLError

from api.graphql.notes.service import (
    get_owned_note,
    normalize_note_fields,
    notes_qs,
    to_note_type,
)
from api.models import Note

pytestmark = pytest.mark.django_db


def test_notes_qs_filters_favorites_and_sorts_by_recent_update(user):
    older = Note.objects.create(owner=user, title="Older")
    favorite = Note.objects.create(owner=user, title="Favorite", is_favorite=True)

    sleep(0.01)
    older.title = "Older updated"
    older.save()

    results = list(notes_qs(user, only_favorites=False))
    favorite_results = list(notes_qs(user, only_favorites=True))

    assert [note.id for note in results] == [older.id, favorite.id]
    assert [note.id for note in favorite_results] == [favorite.id]


def test_get_owned_note_raises_for_not_owner(user, another_user):
    note = Note.objects.create(owner=user, title="Idea")

    with pytest.raises(GraphQLError) as exc:
        get_owned_note(another_user, str(note.id))

    assert exc.value.extensions["code"] == "NOTE_NOT_FOUND"


def test_normalize_note_fields_extracts_link_from_description():
    description, link = normalize_note_fields(
        "Посмотреть тут https://example.com/deck",
        "",
    )

    assert description == "Посмотреть тут"
    assert link == "https://example.com/deck"


def test_normalize_note_fields_keeps_explicit_link_priority():
    description, link = normalize_note_fields(
        "Посмотреть тут https://example.com/deck",
        "  https://example.com/explicit  ",
    )

    assert description == "Посмотреть тут https://example.com/deck"
    assert link == "https://example.com/explicit"


def test_to_note_type_returns_graphql_shape(user):
    note = Note.objects.create(
        owner=user,
        title="Camera",
        description="Mirrorless",
        link="https://example.com/camera",
        is_favorite=True,
    )

    result = to_note_type(note)

    assert result.id == str(note.id)
    assert result.title == "Camera"
    assert result.description == "Mirrorless"
    assert result.link == "https://example.com/camera"
    assert result.is_favorite is True
