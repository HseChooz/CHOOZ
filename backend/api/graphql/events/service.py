from datetime import date

from django.utils.timezone import localdate

from api.graphql.errors import gql_error
from api.graphql.types import EventType
from api.models import Event


def require_user(info):
    user = info.context.request.user
    if not user or not user.is_authenticated:
        gql_error("UNAUTHORIZED", "Unauthorized")
    return user


def get_owned_event(user, event_id: str) -> Event:
    try:
        return Event.objects.get(id=event_id, owner=user)
    except Event.DoesNotExist:
        gql_error("EVENT_NOT_FOUND", "Event not found")


def to_event_type(event: Event) -> EventType:
    return EventType(
        id=str(event.id),
        title=event.title,
        description=event.description,
        date=event.date,
    )


def upcoming_events_qs(user, from_date: date | None = None):
    d = from_date or localdate()
    return Event.objects.filter(owner=user, date__gte=d).order_by("date", "id")