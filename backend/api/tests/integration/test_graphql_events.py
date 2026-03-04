from datetime import date, timedelta

import pytest

from api.models import Event


pytestmark = pytest.mark.django_db


def test_events_default_returns_only_upcoming_sorted(gql, user, access_token):
    today = date.today()
    Event.objects.create(owner=user, title="Past", date=today - timedelta(days=1))
    Event.objects.create(owner=user, title="Later", date=today + timedelta(days=2))
    Event.objects.create(owner=user, title="Soon", date=today + timedelta(days=1))

    response = gql(
        """
        query {
          events {
            title
            date
          }
        }
        """,
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert [event["title"] for event in payload["data"]["events"]] == ["Soon", "Later"]


def test_event_hides_past_non_repeating_item(gql, user, access_token):
    past_event = Event.objects.create(
        owner=user,
        title="Old one-time event",
        date=date.today() - timedelta(days=2),
        repeat_yearly=False,
    )

    response = gql(
        """
        query($id: ID!) {
          event(id: $id) {
            id
            title
          }
        }
        """,
        variables={"id": str(past_event.id)},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"] is None
    assert payload["errors"][0]["extensions"]["code"] == "EVENT_NOT_FOUND"


def test_event_returns_past_repeating_item(gql, user, access_token):
    repeating = Event.objects.create(
        owner=user,
        title="Birthday",
        date=date.today() - timedelta(days=10),
        repeat_yearly=True,
    )

    response = gql(
        """
        query($id: ID!) {
          event(id: $id) {
            id
            title
            repeatYearly
          }
        }
        """,
        variables={"id": str(repeating.id)},
        token=access_token,
    )
    payload = response.json()

    assert response.status_code == 200
    assert payload["data"]["event"]["id"] == str(repeating.id)
    assert payload["data"]["event"]["repeatYearly"] is True
