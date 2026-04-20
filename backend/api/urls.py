from django.urls import path
from django.views.decorators.csrf import csrf_exempt
from rest_framework_simplejwt.authentication import JWTAuthentication
from strawberry.django.views import GraphQLView

from api.graphql.schema import schema
from api.views import hardcoded_asset


class AuthGraphQLView(GraphQLView):
    def dispatch(self, request, *args, **kwargs):
        try:
            res = JWTAuthentication().authenticate(request)
            if res:
                user, token = res
                request.user = user
                request.auth = token
        except Exception:
            pass
        return super().dispatch(request, *args, **kwargs)


urlpatterns = [
    path("assets/<path:asset_path>", hardcoded_asset),
    path(
        "graphql/",
        csrf_exempt(
            AuthGraphQLView.as_view(schema=schema, graphql_ide="graphiql")
        ),
    ),
]
