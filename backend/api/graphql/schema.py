import strawberry

from api.graphql.auth.mutations import AuthMutation
from api.graphql.auth.queries import AuthQuery
from api.graphql.wish_items.mutations import WishItemsMutation
from api.graphql.wish_items.queries import WishItemsQuery


@strawberry.type
class Query(AuthQuery, WishItemsQuery):
    pass


@strawberry.type
class Mutation(AuthMutation, WishItemsMutation):
    pass


schema = strawberry.Schema(query=Query, mutation=Mutation)