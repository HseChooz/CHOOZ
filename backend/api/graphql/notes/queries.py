from typing import Annotated, List

import strawberry

from api.graphql.types import NoteType

from .service import get_owned_note, notes_qs, require_user, to_note_type


@strawberry.type
class NotesQuery:
    @strawberry.field(name="notes")
    def notes(
        self,
        info,
        only_favorites: Annotated[bool, strawberry.argument(name="onlyFavorites")] = False,
    ) -> List[NoteType]:
        user = require_user(info)
        return [to_note_type(note) for note in notes_qs(user, only_favorites=only_favorites)]

    @strawberry.field(name="note")
    def note(self, info, id: strawberry.ID) -> NoteType:
        user = require_user(info)
        note = get_owned_note(user, str(id))
        return to_note_type(note)
