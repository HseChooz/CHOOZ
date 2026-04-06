import strawberry

from api.graphql.auth.mutations import AuthMutation
from api.graphql.auth.queries import AuthQuery
from api.graphql.collections.mutations import CollectionsMutation
from api.graphql.collections.queries import CollectionsQuery
from api.graphql.events.mutations import EventsMutation
from api.graphql.events.queries import EventsQuery
from api.graphql.wish_items.mutations import WishItemsMutation
from api.graphql.wish_items.queries import WishItemsQuery


@strawberry.type
class Query(AuthQuery, WishItemsQuery, EventsQuery, CollectionsQuery):
    pass


@strawberry.type
class Mutation(AuthMutation, WishItemsMutation, EventsMutation, CollectionsMutation):
    pass


schema = strawberry.Schema(query=Query, mutation=Mutation)
