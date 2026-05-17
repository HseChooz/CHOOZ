import base64
import json
from urllib.parse import quote, urlsplit
from urllib.request import urlopen


YANDEX_PUBLIC_HOSTS = {
    "disk.yandex.ru",
    "disk.360.yandex.ru",
    "yadi.sk",
}


def is_yandex_public_asset_url(value: str | None) -> bool:
    raw_value = (value or "").strip()
    if not raw_value:
        return False

    parsed = urlsplit(raw_value)
    return parsed.scheme in {"http", "https"} and parsed.netloc in YANDEX_PUBLIC_HOSTS


def encode_yandex_public_asset_url(value: str) -> str:
    encoded = base64.urlsafe_b64encode(value.encode("utf-8")).decode("ascii")
    return encoded.rstrip("=")


def decode_yandex_public_asset_token(token: str) -> str:
    normalized_token = token + "=" * (-len(token) % 4)
    return base64.urlsafe_b64decode(normalized_token.encode("ascii")).decode("utf-8")


def build_yandex_public_asset_path(value: str) -> str:
    return f"/api/assets/yandex-public/{encode_yandex_public_asset_url(value)}"


def resolve_yandex_public_download_url(value: str) -> str:
    api_url = (
        "https://cloud-api.yandex.net/v1/disk/public/resources/download"
        f"?public_key={quote(value, safe='')}"
    )
    with urlopen(api_url, timeout=20) as response:
        payload = json.load(response)

    href = (payload.get("href") or "").strip()
    if not href:
        raise ValueError("Yandex public download URL was not returned")

    return href
