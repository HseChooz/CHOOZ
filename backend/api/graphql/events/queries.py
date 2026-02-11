from datetime import date
from typing import Annotated, List, Optional

import strawberry

from api.graphql.types import EventType
from api.models import Event
from .service import get_owned_event, require_user, to_event_type, upcoming_events_qs


@strawberry.type
class EventsQuery:
    @strawberry.field(name="events")
    def events(self, info) -> List[EventType]:
        user = require_user(info)
        return [to_event_type(e) for e in Event.objects.filter(owner=user).order_by("date", "id")]

    @strawberry.field(name="event")
    def event(self, info, id: strawberry.ID) -> EventType:
        user = require_user(info)
        e = get_owned_event(user, str(id))
        return to_event_type(e)

    @strawberry.field(name="upcomingEvents")
    def upcoming_events(
        self,
        info,
        from_date: Annotated[Optional[date], strawberry.argument(name="fromDate")] = None,
        limit: int = 20,
    ) -> List[EventType]:
        user = require_user(info)
        limit = max(1, min(limit, 200))
        qs = upcoming_events_qs(user, from_date=from_date)[:limit]
        return [to_event_type(e) for e in qs]