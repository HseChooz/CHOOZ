from graphql import GraphQLError


def gql_error(code: str, message: str) -> None:
    raise GraphQLError(message, extensions={"code": code})