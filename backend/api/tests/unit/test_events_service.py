from datetime import date, timedelta

import pytest
from graphql import GraphQLError

from api.graphql.events.service import get_owned_event, sorted_events_qs, upcoming_events_qs
from api.models import Event


pytestmark = pytest.mark.django_db


def test_upcoming_events_qs_filters_and_orders(user):
    today = date.today()
    Event.objects.create(owner=user, title="Past", date=today - timedelta(days=1))
    e2 = Event.objects.create(owner=user, title="Soon", date=today + timedelta(days=1))
    e3 = Event.objects.create(owner=user, title="Later", date=today + timedelta(days=5))

    results = list(upcoming_events_qs(user, from_date=today))

    assert [event.id for event in results] == [e2.id, e3.id]


def test_sorted_events_qs_returns_all_events_sorted(user):
    today = date.today()
    e1 = Event.objects.create(owner=user, title="Later", date=today + timedelta(days=3))
    e2 = Event.objects.create(owner=user, title="Earlier", date=today - timedelta(days=2))

    results = list(sorted_events_qs(user))

    assert [event.id for event in results] == [e2.id, e1.id]


def test_get_owned_event_raises_for_not_owner(user, another_user):
    event = Event.objects.create(owner=user, title="Birthday", date=date.today())

    with pytest.raises(GraphQLError) as exc:
        get_owned_event(another_user, str(event.id))

    assert exc.value.extensions["code"] == "EVENT_NOT_FOUND"
