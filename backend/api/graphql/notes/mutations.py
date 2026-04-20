from typing import Annotated, Optional

import strawberry
from strawberry.types import Info

from api.graphql.notes.service import (
    get_owned_note,
    normalize_note_fields,
    require_user,
    to_note_type,
)
from api.graphql.types import NoteType
from api.models import Note


@strawberry.type
class NotesMutation:
    @strawberry.mutation(name="createNote")
    def create_note(
        self,
        info: Info,
        title: str,
        description: str = "",
        link: str = "",
        is_favorite: Annotated[bool, strawberry.argument(name="isFavorite")] = False,
    ) -> NoteType:
        user = require_user(info)
        normalized_description, normalized_link = normalize_note_fields(description, link)
        note = Note.objects.create(
            owner=user,
            title=title,
            description=normalized_description,
            link=normalized_link,
            is_favorite=is_favorite,
        )
        return to_note_type(note)

    @strawberry.mutation(name="updateNote")
    def update_note(
        self,
        info: Info,
        id: strawberry.ID,
        title: Optional[str] = None,
        description: Optional[str] = None,
        link: Optional[str] = None,
        is_favorite: Annotated[Optional[bool], strawberry.argument(name="isFavorite")] = None,
    ) -> NoteType:
        user = require_user(info)
        note = get_owned_note(user, str(id))

        updated_fields = []
        if title is not None:
            note.title = title
            updated_fields.append("title")
        if description is not None:
            normalized_description, normalized_link = normalize_note_fields(description, link)
            note.description = normalized_description
            updated_fields.append("description")

            if normalized_link != note.link:
                note.link = normalized_link
                updated_fields.append("link")
        elif link is not None:
            note.link = (link or "").strip()
            updated_fields.append("link")
        if is_favorite is not None:
            note.is_favorite = is_favorite
            updated_fields.append("is_favorite")

        if updated_fields:
            updated_fields.append("updated_at")
            note.save(update_fields=updated_fields)

        return to_note_type(note)

    @strawberry.mutation(name="deleteNote")
    def delete_note(self, info: Info, id: strawberry.ID) -> bool:
        user = require_user(info)
        note = get_owned_note(user, str(id))
        note.delete()
        return True
