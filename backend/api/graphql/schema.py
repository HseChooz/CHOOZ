import strawberry

from api.graphql.auth.mutations import AuthMutation
from api.graphql.auth.queries import AuthQuery
from api.graphql.collections.mutations import CollectionsMutation
from api.graphql.collections.queries import CollectionsQuery
from api.graphql.events.mutations import EventsMutation
from api.graphql.events.queries import EventsQuery
from api.graphql.notes.mutations import NotesMutation
from api.graphql.notes.queries import NotesQuery
from api.graphql.wish_items.mutations import WishItemsMutation
from api.graphql.wish_items.queries import WishItemsQuery
from api.graphql.wishlist_share.mutations import WishlistShareMutation
from api.graphql.wishlist_share.queries import WishlistShareQuery


@strawberry.type
class Query(
    AuthQuery,
    WishItemsQuery,
    WishlistShareQuery,
    NotesQuery,
    EventsQuery,
    CollectionsQuery,
):
    pass


@strawberry.type
class Mutation(
    AuthMutation,
    WishItemsMutation,
    WishlistShareMutation,
    NotesMutation,
    EventsMutation,
    CollectionsMutation,
):
    pass


schema = strawberry.Schema(query=Query, mutation=Mutation)
