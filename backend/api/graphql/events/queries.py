from datetime import date
from typing import Annotated, List, Optional

import strawberry

from api.graphql.types import EventType
from .service import get_owned_event, require_user, to_event_type, upcoming_events_qs, sorted_events_qs


@strawberry.type
class EventsQuery:
    @strawberry.field(name="events")
    def events(
        self,
        info,
        only_upcoming: Annotated[bool, strawberry.argument(name="onlyUpcoming")] = True,
        from_date: Annotated[Optional[date], strawberry.argument(name="fromDate")] = None,
        limit: int = 200,
    ) -> List[EventType]:
        user = require_user(info)
        if only_upcoming:
            limit = max(1, min(limit, 200))
            qs = upcoming_events_qs(user, from_date=from_date)[:limit]
            return [to_event_type(e) for e in qs]
        return [to_event_type(e) for e in sorted_events_qs(user)]

    @strawberry.field(name="event")
    def event(self, info, id: strawberry.ID) -> EventType:
        from datetime import date
        user = require_user(info)
        e = get_owned_event(user, str(id))
        if e.date < date.today() and not e.repeat_yearly:
            from api.graphql.errors import gql_error
            gql_error("EVENT_NOT_FOUND", "Event not found")
        return to_event_type(e)
