import strawberry

from api.graphql.auth.mutations import AuthMutation
from api.graphql.auth.queries import AuthQuery
from api.graphql.wish_items.mutations import WishItemsMutation
from api.graphql.wish_items.queries import WishItemsQuery
from api.graphql.events.mutations import EventsMutation
from api.graphql.events.queries import EventsQuery


@strawberry.type
class Query(AuthQuery, WishItemsQuery, EventsQuery):
    pass


@strawberry.type
class Mutation(AuthMutation, WishItemsMutation, EventsMutation):
    pass


schema = strawberry.Schema(query=Query, mutation=Mutation)