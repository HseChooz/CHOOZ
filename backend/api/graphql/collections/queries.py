from typing import Annotated, Optional

import strawberry

from api.graphql.collections.service import (
    collections_qs,
    get_collection_by_slug,
    require_user,
    to_collection_type,
    to_collections_home_type,
)
from api.graphql.types import CollectionsHomeType, CollectionType


@strawberry.type
class CollectionsQuery:
    @strawberry.field(name="collectionsHome")
    def collections_home(self, info) -> CollectionsHomeType:
        require_user(info)
        collections = list(collections_qs().order_by("section", "sort_order", "id"))
        return to_collections_home_type(collections)

    @strawberry.field(name="collection")
    def collection(
        self,
        info,
        slug: str,
        tags: Annotated[Optional[list[str]], strawberry.argument(name="tags")] = None,
        match_all_tags: Annotated[
            bool,
            strawberry.argument(name="matchAllTags"),
        ] = False,
    ) -> Optional[CollectionType]:
        user = require_user(info)
        collection = get_collection_by_slug(slug)
        if collection is None:
            return None
        return to_collection_type(
            collection,
            user,
            selected_tags=tags,
            match_all_tags=match_all_tags,
        )
