import uuid

import boto3
from botocore.config import Config
from django.conf import settings

from api.graphql.errors import gql_error


_s3_client = None


def _configured() -> bool:
    return bool(
        getattr(settings, "MINIO_ENDPOINT", "")
        and getattr(settings, "MINIO_ROOT_USER", "")
        and getattr(settings, "MINIO_ROOT_PASSWORD", "")
        and getattr(settings, "MINIO_BUCKET", "")
    )


def get_s3_client():
    global _s3_client
    if _s3_client is not None:
        return _s3_client

    if not _configured():
        gql_error("SERVER_MISCONFIGURED", "MinIO is not configured")

    scheme = "https" if getattr(settings, "MINIO_USE_SSL", False) else "http"
    endpoint_url = f"{scheme}://{settings.MINIO_ENDPOINT}"

    _s3_client = boto3.client(
        "s3",
        endpoint_url=endpoint_url,
        aws_access_key_id=settings.MINIO_ROOT_USER,
        aws_secret_access_key=settings.MINIO_ROOT_PASSWORD,
        region_name=getattr(settings, "MINIO_REGION", "us-east-1"),
        config=Config(signature_version="s3v4"),
    )
    return _s3_client


def sanitize_filename(filename: str) -> str:
    name = (filename or "").strip().replace("\\", "/")
    name = name.split("/")[-1]
    return name or "upload"


def make_image_key(user_id: str, wish_item_id: str, filename: str) -> str:
    safe = sanitize_filename(filename)
    return f"wish_items/{user_id}/{wish_item_id}/{uuid.uuid4().hex}_{safe}"


def presigned_put_url(key: str, content_type: str, expires_in: int = 900) -> str:
    client = get_s3_client()
    try:
        return client.generate_presigned_url(
            "put_object",
            Params={"Bucket": settings.MINIO_BUCKET, "Key": key, "ContentType": content_type},
            ExpiresIn=expires_in,
        )
    except Exception:
        gql_error("MINIO_ERROR", "Failed to generate upload URL")


def presigned_get_url(key: str, expires_in: int = 3600) -> str:
    base = (getattr(settings, "MINIO_PUBLIC_BASE_URL", "") or "").strip()
    bucket = settings.MINIO_BUCKET
    if base:
        return f"{base.rstrip('/')}/{bucket}/{key.lstrip('/')}"

    client = get_s3_client()
    try:
        return client.generate_presigned_url(
            "get_object",
            Params={"Bucket": settings.MINIO_BUCKET, "Key": key},
            ExpiresIn=expires_in,
        )
    except Exception:
        gql_error("MINIO_ERROR", "Failed to generate image URL")