import pytest

from api.models import Note

pytestmark = pytest.mark.django_db


def test_notes_require_auth(gql):
    response = gql(
        """
        query {
          notes {
            id
          }
        }
        """
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "UNAUTHORIZED"


def test_create_and_list_notes_for_current_user_only(gql, user, another_user, access_token):
    Note.objects.create(owner=another_user, title="Other user note")

    create_response = gql(
        """
        mutation {
          createNote(
            title: "Steam Deck"
            description: "Посмотреть тут https://example.com/deck"
          ) {
            id
            title
            description
            link
            isFavorite
          }
        }
        """,
        token=access_token,
    )
    create_payload = create_response.json()

    assert create_response.status_code == 200
    assert "errors" not in create_payload
    created = create_payload["data"]["createNote"]
    assert created["title"] == "Steam Deck"
    assert created["description"] == "Посмотреть тут"
    assert created["link"] == "https://example.com/deck"
    assert created["isFavorite"] is False

    list_response = gql(
        """
        query {
          notes {
            id
            title
          }
        }
        """,
        token=access_token,
    )
    list_payload = list_response.json()

    assert list_response.status_code == 200
    assert [item["title"] for item in list_payload["data"]["notes"]] == ["Steam Deck"]


def test_notes_query_supports_only_favorites_filter(gql, user, access_token):
    Note.objects.create(owner=user, title="Regular")
    Note.objects.create(owner=user, title="Favorite", is_favorite=True)

    response = gql(
        """
        query {
          notes(onlyFavorites: true) {
            title
            isFavorite
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["notes"] == [{"title": "Favorite", "isFavorite": True}]


def test_update_note_extracts_link_and_toggles_favorite(gql, user, access_token):
    note = Note.objects.create(owner=user, title="Book")

    response = gql(
        f"""
        mutation {{
          updateNote(
            id: "{note.id}"
            description: "Заказать здесь https://example.com/book"
            isFavorite: true
          ) {{
            id
            description
            link
            isFavorite
          }}
        }}
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert "errors" not in payload
    updated = payload["data"]["updateNote"]
    assert updated["id"] == str(note.id)
    assert updated["description"] == "Заказать здесь"
    assert updated["link"] == "https://example.com/book"
    assert updated["isFavorite"] is True


def test_delete_note_removes_item(gql, user, access_token):
    note = Note.objects.create(owner=user, title="Gift idea")

    response = gql(
        """
        mutation($id: ID!) {
          deleteNote(id: $id)
        }
        """,
        variables={"id": str(note.id)},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["deleteNote"] is True
    assert Note.objects.filter(id=note.id).exists() is False
