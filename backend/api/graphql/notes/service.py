import re

from api.graphql.errors import gql_error
from api.graphql.types import NoteType
from api.models import Note

INLINE_URL_RE = re.compile(r"https?://[^\s]+", re.IGNORECASE)
TRAILING_URL_PUNCTUATION = ".,!?;:)]}>"


def require_user(info):
    user = info.context.request.user
    if not user or not user.is_authenticated:
        gql_error("UNAUTHORIZED", "Unauthorized")
    return user


def get_owned_note(user, note_id: str) -> Note:
    try:
        return Note.objects.get(id=note_id, owner=user)
    except Note.DoesNotExist:
        gql_error("NOTE_NOT_FOUND", "Note not found")


def normalize_note_fields(description: str, link: str | None) -> tuple[str, str]:
    normalized_description = (description or "").strip()
    normalized_link = (link or "").strip()

    if normalized_link:
        return normalized_description, normalized_link

    match = INLINE_URL_RE.search(normalized_description)
    if match is None:
        return normalized_description, ""

    extracted_link = match.group(0).rstrip(TRAILING_URL_PUNCTUATION)
    description_without_link = (
        f"{normalized_description[:match.start()]}"
        f"{normalized_description[match.end():]}"
    )

    cleaned_description = re.sub(r"[ \t]{2,}", " ", description_without_link)
    cleaned_description = re.sub(r" *([,.!?;:])", r"\1", cleaned_description)
    cleaned_description = re.sub(r"\n{3,}", "\n\n", cleaned_description)

    return cleaned_description.strip(), extracted_link


def notes_qs(user, only_favorites: bool = False):
    qs = Note.objects.filter(owner=user)
    if only_favorites:
        qs = qs.filter(is_favorite=True)
    return qs.order_by("-updated_at", "-id")


def to_note_type(note: Note) -> NoteType:
    return NoteType(
        id=str(note.id),
        title=note.title,
        description=note.description,
        link=note.link or None,
        is_favorite=note.is_favorite,
        created_at=note.created_at,
        updated_at=note.updated_at,
    )
