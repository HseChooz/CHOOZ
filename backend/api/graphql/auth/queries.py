from typing import Optional

import strawberry
from strawberry.types import Info

from api.graphql.errors import gql_error
from api.graphql.types import UserType


def require_user(info: Info):
    user = info.context.request.user
    if not user or not user.is_authenticated:
        gql_error("UNAUTHORIZED", "Unauthorized")
    return user


def to_user_type(user) -> UserType:
    return UserType(
        id=strawberry.ID(str(user.id)),
        username=user.username,
        email=user.email,
        first_name=user.first_name,
        last_name=user.last_name,
    )


@strawberry.type
class AuthQuery:
    @strawberry.field()
    def me(self, info: Info) -> Optional[UserType]:
        user = info.context.request.user
        if not user or not user.is_authenticated:
            return None
        return to_user_type(user)
