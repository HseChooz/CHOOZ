from typing import List

import strawberry

from .models import WishItem


@strawberry.type
class WishItemType:
    id: strawberry.ID
    title: str
    description: str


@strawberry.type
class Query:
    @strawberry.field
    def hello(self) -> str:
        return "world"

    @strawberry.field
    def wish_items(self) -> List[WishItemType]:
        return [
            WishItemType(
                id=str(item.id),
                title=item.title,
                description=item.description,
            )
            for item in WishItem.objects.all()
        ]


@strawberry.type
class Mutation:
    @strawberry.mutation
    def create_wish_item(self, title: str, description: str = "") -> WishItemType:
        wish_item = WishItem.objects.create(title=title, description=description)
        return WishItemType(
            id=str(wish_item.id),
            title=wish_item.title,
            description=wish_item.description,
        )


schema = strawberry.Schema(query=Query, mutation=Mutation)