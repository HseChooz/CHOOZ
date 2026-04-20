import mimetypes
from pathlib import Path

from django.http import FileResponse, Http404

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
