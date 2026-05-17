import mimetypes
from pathlib import Path

from django.http import FileResponse, Http404, HttpResponseRedirect

from api.yandex_disk import (
    decode_yandex_public_asset_token,
    is_yandex_public_asset_url,
    resolve_yandex_public_download_url,
)

HARDCODED_ASSETS_ROOT = (Path(__file__).resolve().parent / "hardcoded_assets").resolve()


def hardcoded_asset(_request, asset_path: str) -> FileResponse:
    candidate = (HARDCODED_ASSETS_ROOT / asset_path).resolve()

    if HARDCODED_ASSETS_ROOT not in candidate.parents or not candidate.is_file():
        raise Http404("Asset not found")

    content_type, _encoding = mimetypes.guess_type(candidate.name)
    response = FileResponse(
        candidate.open("rb"),
        content_type=content_type or "application/octet-stream",
    )
    response["Cache-Control"] = "public, max-age=86400"
    return response


def yandex_public_asset(_request, token: str) -> HttpResponseRedirect:
    try:
        public_url = decode_yandex_public_asset_token(token)
    except Exception as exc:
        raise Http404("Asset not found") from exc

    if not is_yandex_public_asset_url(public_url):
        raise Http404("Asset not found")

    try:
        download_url = resolve_yandex_public_download_url(public_url)
    except Exception as exc:
        raise Http404("Asset not found") from exc

    response = HttpResponseRedirect(download_url)
    response["Cache-Control"] = "public, max-age=300"
    return response
