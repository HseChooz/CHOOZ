from datetime import date
from typing import Optional

import strawberry

from api.graphql.types import EventType
from api.models import Event
from .service import get_owned_event, require_user, to_event_type


@strawberry.type
class EventsMutation:
    @strawberry.mutation(name="createEvent")
    def create_event(
        self,
        info,
        title: str,
        date: date,
        description: str = "",
        link: str = "",
        notify_enabled: bool = False,
        repeat_yearly: bool = False,
    ) -> EventType:
        user = require_user(info)
        e = Event.objects.create(
            owner=user,
            title=title,
            description=description,
            link=(link or "").strip(),
            notify_enabled=notify_enabled,
            repeat_yearly=repeat_yearly,
            date=date,
        )
        return to_event_type(e)

    @strawberry.mutation(name="updateEvent")
    def update_event(
        self,
        info,
        id: strawberry.ID,
        title: Optional[str] = None,
        description: Optional[str] = None,
        link: Optional[str] = None,
        date: Optional[date] = None,
        notify_enabled: Optional[bool] = None,
        repeat_yearly: Optional[bool] = None,
    ) -> EventType:
        user = require_user(info)
        e = get_owned_event(user, str(id))

        updated = []
        if title is not None:
            e.title = title
            updated.append("title")
        if description is not None:
            e.description = description
            updated.append("description")
        if link is not None:
            e.link = (link or "").strip()
            updated.append("link")
        if date is not None:
            e.date = date
            updated.append("date")
        if notify_enabled is not None:
            e.notify_enabled = notify_enabled
            updated.append("notify_enabled")
        if repeat_yearly is not None:
            e.repeat_yearly = repeat_yearly
            updated.append("repeat_yearly")

        if updated:
            e.save(update_fields=updated)

        return to_event_type(e)

    @strawberry.mutation(name="deleteEvent")
    def delete_event(self, info, id: strawberry.ID) -> bool:
        user = require_user(info)
        e = get_owned_event(user, str(id))
        e.delete()
        return True