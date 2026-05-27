from __future__ import annotations

import html
import re
import subprocess
import urllib.error
import urllib.request
import zipfile
from dataclasses import dataclass
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parent
RAW_SVG = ROOT / "svg" / "raw"
WHITE_SVG = ROOT / "svg" / "white"
COLOR_SVG = ROOT / "svg" / "color"
WHITE_PNG = ROOT / "png" / "white"
COLOR_PNG = ROOT / "png" / "color"
RAW_PNG = ROOT / "png" / "raw"
ARCHIVE = ROOT / "backend-tech-icons.zip"
SOURCES = ROOT / "sources.txt"
COLOR_PREVIEW = ROOT / "preview-color.png"
WHITE_PREVIEW = ROOT / "preview-white-on-blue.png"

SIMPLE_ICONS_RAW = "https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/{slug}.svg"


@dataclass(frozen=True)
class Icon:
    file_name: str
    title: str
    slugs: tuple[str, ...] = ()
    color: str = "222222"
    badge: bool = False


ICONS = [
    Icon("python", "Python", ("python",), "3776AB"),
    Icon("django", "Django", ("django",), "092E20"),
    Icon("django-orm", "Django ORM", color="092E20", badge=True),
    Icon("strawberry-graphql", "Strawberry GraphQL", color="E83E8C", badge=True),
    Icon("graphql", "GraphQL", ("graphql",), "E10098"),
    Icon("postgresql", "PostgreSQL", ("postgresql",), "4169E1"),
    Icon("simplejwt", "SimpleJWT", ("jsonwebtokens",), "000000"),
    Icon("yandex-id", "Yandex ID", color="FC3F1D", badge=True),
    Icon("sign-in-with-apple", "Sign in with Apple", ("apple",), "000000"),
    Icon("s3", "S3 Storage", color="FF9900", badge=True),
    Icon("minio", "MinIO", ("minio",), "C72E49"),
    Icon("boto3", "boto3", color="FF9900", badge=True),
    Icon("docker", "Docker", ("docker",), "2496ED"),
    Icon("docker-compose", "Docker Compose", color="2496ED", badge=True),
    Icon("gunicorn", "Gunicorn", ("gunicorn",), "499848"),
    Icon("uvicorn", "Uvicorn", color="2094F3", badge=True),
    Icon("pytest", "pytest", ("pytest",), "0A9EDC"),
    Icon("pytest-django", "pytest-django", color="0A9EDC", badge=True),
    Icon("ruff", "Ruff", ("ruff",), "D7FF64"),
    Icon("uv", "uv", ("uv", "astral"), "DE5FE9"),
]


def ensure_dirs() -> None:
    for directory in (RAW_SVG, WHITE_SVG, COLOR_SVG, WHITE_PNG, COLOR_PNG, RAW_PNG):
        directory.mkdir(parents=True, exist_ok=True)


def download_svg(icon: Icon) -> tuple[str, str] | None:
    headers = {"User-Agent": "CHOOZ presentation asset downloader"}
    for slug in icon.slugs:
        url = SIMPLE_ICONS_RAW.format(slug=slug)
        request = urllib.request.Request(url, headers=headers)
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                return response.read().decode("utf-8"), url
        except urllib.error.HTTPError:
            continue
        except urllib.error.URLError:
            continue
    return None


def add_root_fill(svg: str, fill: str) -> str:
    svg = re.sub(r"\sfill=\"#[0-9A-Fa-f]{3,8}\"", "", svg, count=1)
    return svg.replace("<svg ", f'<svg fill="#{fill}" ', 1)


def make_badge_svg(title: str, fill: str, text_fill: str = "FFFFFF") -> str:
    escaped = html.escape(title)
    words = escaped.split()
    if len(words) > 1:
        midpoint = (len(words) + 1) // 2
        lines = [" ".join(words[:midpoint]), " ".join(words[midpoint:])]
    else:
        lines = [escaped]

    font_size = 58 if max(len(line) for line in lines) <= 12 else 48
    if len(lines) == 1:
        text_nodes = f'<text x="256" y="282">{lines[0]}</text>'
    else:
        text_nodes = (
            f'<text x="256" y="238">{lines[0]}</text>'
            f'<text x="256" y="304">{lines[1]}</text>'
        )

    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" role="img" aria-label="{escaped}">
  <rect x="24" y="96" width="464" height="320" rx="56" fill="#{fill}"/>
  <g font-family="Vela Sans GX, Inter, Arial, sans-serif" font-size="{font_size}" font-weight="800" text-anchor="middle" fill="#{text_fill}">{text_nodes}</g>
</svg>
'''


def make_text_only_svg(title: str) -> str:
    escaped = html.escape(title)
    words = escaped.split()
    if len(words) > 1:
        midpoint = (len(words) + 1) // 2
        lines = [" ".join(words[:midpoint]), " ".join(words[midpoint:])]
    else:
        lines = [escaped]
    font_size = 62 if max(len(line) for line in lines) <= 12 else 50
    if len(lines) == 1:
        text_nodes = f'<text x="256" y="282">{lines[0]}</text>'
    else:
        text_nodes = (
            f'<text x="256" y="238">{lines[0]}</text>'
            f'<text x="256" y="304">{lines[1]}</text>'
        )
    return f'''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512" role="img" aria-label="{escaped}">
  <g font-family="Vela Sans GX, Inter, Arial, sans-serif" font-size="{font_size}" font-weight="800" text-anchor="middle" fill="#FFFFFF">{text_nodes}</g>
</svg>
'''


def write_icon(icon: Icon) -> str:
    downloaded = None if icon.badge else download_svg(icon)
    raw_path = RAW_SVG / f"{icon.file_name}.svg"
    white_path = WHITE_SVG / f"{icon.file_name}.svg"
    color_path = COLOR_SVG / f"{icon.file_name}.svg"

    if downloaded:
        svg, source = downloaded
        raw_path.write_text(svg, encoding="utf-8")
        white_path.write_text(add_root_fill(svg, "FFFFFF"), encoding="utf-8")
        color_path.write_text(add_root_fill(svg, icon.color), encoding="utf-8")
        return f"{icon.title}: {source}"

    raw_path.write_text(make_badge_svg(icon.title, icon.color), encoding="utf-8")
    white_path.write_text(make_badge_svg(icon.title, "FFFFFF", "0058FF"), encoding="utf-8")
    color_path.write_text(make_badge_svg(icon.title, icon.color), encoding="utf-8")
    return f"{icon.title}: generated text badge"


def render_png(svg_path: Path, png_path: Path) -> None:
    subprocess.run(
        ["/opt/homebrew/bin/rsvg-convert", "-w", "512", "-h", "512", "-o", str(png_path), str(svg_path)],
        check=True,
    )


def render_all_pngs() -> None:
    for svg_path in RAW_SVG.glob("*.svg"):
        render_png(svg_path, RAW_PNG / f"{svg_path.stem}.png")
    for svg_path in WHITE_SVG.glob("*.svg"):
        render_png(svg_path, WHITE_PNG / f"{svg_path.stem}.png")
    for svg_path in COLOR_SVG.glob("*.svg"):
        render_png(svg_path, COLOR_PNG / f"{svg_path.stem}.png")


def make_archive() -> None:
    if ARCHIVE.exists():
        ARCHIVE.unlink()
    with zipfile.ZipFile(ARCHIVE, "w", compression=zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(ROOT.rglob("*")):
            if path == ARCHIVE or path.name == ".DS_Store" or path.is_dir():
                continue
            zf.write(path, path.relative_to(ROOT))


def load_font(size: int) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    for path in (
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ):
        try:
            return ImageFont.truetype(path, size=size)
        except OSError:
            continue
    return ImageFont.load_default()


def make_contact_sheet(source_dir: Path, output: Path, background: str, text: str) -> None:
    icons = [(icon, source_dir / f"{icon.file_name}.png") for icon in ICONS]
    columns = 5
    cell_w = 280
    cell_h = 236
    top = 96
    rows = (len(icons) + columns - 1) // columns
    sheet = Image.new("RGB", (columns * cell_w, top + rows * cell_h + 48), background)
    draw = ImageDraw.Draw(sheet)
    title_font = load_font(44)
    label_font = load_font(25)
    draw.text((48, 28), "Backend technologies", fill=text, font=title_font)

    for index, (icon, path) in enumerate(icons):
        row, col = divmod(index, columns)
        x = col * cell_w
        y = top + row * cell_h
        image = Image.open(path).convert("RGBA")
        image.thumbnail((132, 132), Image.LANCZOS)
        sheet.paste(image, (x + (cell_w - image.width) // 2, y + 16), image)
        bbox = draw.textbbox((0, 0), icon.title, font=label_font)
        draw.text(
            (x + (cell_w - (bbox[2] - bbox[0])) // 2, y + 164),
            icon.title,
            fill=text,
            font=label_font,
        )
    sheet.save(output)


def main() -> None:
    ensure_dirs()
    source_lines = [
        "Backend technology icons for CHOOZ presentation",
        "Generated assets: raw SVG/PNG, white SVG/PNG, color SVG/PNG.",
        "",
    ]
    for icon in ICONS:
        source_lines.append(write_icon(icon))
    SOURCES.write_text("\n".join(source_lines) + "\n", encoding="utf-8")
    render_all_pngs()
    make_contact_sheet(COLOR_PNG, COLOR_PREVIEW, "#FFFFFF", "#222222")
    make_contact_sheet(WHITE_PNG, WHITE_PREVIEW, "#0058FF", "#FFFFFF")
    make_archive()


if __name__ == "__main__":
    main()
