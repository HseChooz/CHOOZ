from django.contrib.auth.models import AnonymousUser
from rest_framework_simplejwt.authentication import JWTAuthentication


class JWTAuthMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response
        self.auth = JWTAuthentication()

    def __call__(self, request):
        try:
            res = self.auth.authenticate(request)
            if res:
                user, token = res
                request.user = user
                request.auth = token
        except Exception:
            request.user = getattr(request, "user", AnonymousUser())
        return self.get_response(request)
