import mimetypes
from pathlib import Path

from django.http import FileResponse, Http404, HttpResponseRedirect
from django.shortcuts import render

from api.wishlist_share import (
    get_public_share_by_token,
    get_public_wishlist_items,
    public_display_name,
)
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


def public_wishlist(request, token: str):
    share_link = get_public_share_by_token(token)
    if share_link is None:
        return render(
            request,
            "wishlist/public.html",
            {
                "page_title": "Вишлист не найден",
                "status_title": "Ссылка недоступна",
                "status_description": "Проверь ссылку и попробуй открыть ее еще раз.",
                "is_error": True,
            },
            status=404,
        )

    if not share_link.is_enabled:
        return render(
            request,
            "wishlist/public.html",
            {
                "page_title": "Публичный доступ отключен",
                "status_title": "Ссылка отключена",
                "status_description": "Владелец вишлиста закрыл публичный доступ к этой странице.",
                "is_error": True,
            },
            status=410,
        )

    items = get_public_wishlist_items(share_link.owner, request=request)
    owner_name = public_display_name(share_link.owner)
    items_count = len(items)
    description = (
        "Вишлист пока пуст."
        if items_count == 0
        else f"Публичный вишлист {owner_name}. Сейчас в списке {items_count} желаний."
    )
    return render(
        request,
        "wishlist/public.html",
        {
            "page_title": f"Вишлист {owner_name}",
            "owner_name": owner_name,
            "items": items,
            "items_count": items_count,
            "share_description": description,
            "preview_image_url": next((item.image_url for item in items if item.image_url), None),
            "is_empty": items_count == 0,
            "is_error": False,
        },
    )
