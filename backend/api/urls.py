from django.urls import path
from strawberry.django.views import GraphQLView
from .graphql_schema import schema
from .views import PingView

urlpatterns = [
    path("ping/", PingView.as_view(), name="ping"),
    path("graphql/", GraphQLView.as_view(schema=schema, graphiql=True)),
]