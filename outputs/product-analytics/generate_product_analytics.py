from __future__ import annotations

import html
import math
import subprocess
from pathlib import Path


OUT_DIR = Path(__file__).resolve().parent

BLUE = "#0058FF"
RED = "#FF5101"
WHITE = "#FFFFFF"
BLACK = "#222222"
GRAY = "#6B6B6B"
LIGHT = "#F1F1F1"
FONT = "'Vela Sans GX', 'Inter', 'Arial', sans-serif"

DATA = {
    "period": "15.02.2026-14.05.2026",
    "users": 57,
    "installs": 56,
    "telegram_organic_share": 98,
    "telegram_subscribers": 105,
    "telegram_week_growth": 15,
    "telegram_post_views": 161,
    "onboarding_rate": 68,
    "auth_rate": 49,
    "retention": {"Day 1": 20.8, "Day 7": 2.4, "Day 14": 5.4},
    "wishlist_adds": 21,
    "wishlist_per_user": 0.7,
    "calendar_events": 48,
    "calendar_per_user": 1.6,
    "notifications_users": 6,
    "notifications_share": 10.5,
    "survey_respondents": 17,
    "nps": 65,
    "app_store_rating": 5.0,
}


def esc(value: object) -> str:
    return html.escape(str(value), quote=True)


def svg_root(width: int, height: int, body: str, bg: str = BLACK) -> str:
    bg_rect = "" if bg == "transparent" else f'<rect width="{width}" height="{height}" fill="{bg}"/>'
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 0 {width} {height}">
{bg_rect}
<style>
  text {{
    font-family: {FONT};
    font-weight: 700;
    font-size: 21px;
  }}
  .small {{ font-size: 18px; }}
  .tiny {{ font-size: 14px; }}
  .title {{ font-size: 46px; }}
  .subtitle {{ font-size: 28px; }}
  .metric {{ font-size: 44px; }}
  .label {{ font-size: 16px; }}
</style>
{body}
</svg>
"""


def text(x: float, y: float, value: object, size: int = 21, fill: str = WHITE, anchor: str = "start", cls: str = "") -> str:
    class_attr = f' class="{cls}"' if cls else ""
    return f'<text x="{x}" y="{y}" fill="{fill}" font-size="{size}px" text-anchor="{anchor}"{class_attr}>{esc(value)}</text>'


def multiline(x: float, y: float, lines: list[str], size: int = 21, fill: str = WHITE, gap: int | None = None, anchor: str = "start") -> str:
    gap = gap or int(size * 1.18)
    return "\n".join(text(x, y + i * gap, line, size, fill, anchor) for i, line in enumerate(lines))


def rect(x: float, y: float, w: float, h: float, fill: str, radius: int = 12) -> str:
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{radius}" fill="{fill}"/>'


def line(x1: float, y1: float, x2: float, y2: float, stroke: str = WHITE, width: int = 3, dash: str = "") -> str:
    dash_attr = f' stroke-dasharray="{dash}"' if dash else ""
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{stroke}" stroke-width="{width}"{dash_attr}/>'


def card(x: float, y: float, w: float, h: float, value: str, label: str, color: str = BLUE, note: str = "") -> str:
    return "\n".join(
        [
            rect(x, y, w, h, color, 18),
            text(x + 22, y + 48, value, 42, WHITE),
            text(x + 22, y + 78, label, 16, WHITE),
            text(x + 22, y + 104, note, 13, WHITE) if note else "",
        ]
    )


def write_svg(name: str, width: int, height: int, body: str) -> Path:
    path = OUT_DIR / f"{name}.svg"
    path.write_text(svg_root(width, height, body), encoding="utf-8")
    return path


def write_clean_svg(name: str, width: int, height: int, body: str) -> Path:
    path = OUT_DIR / f"{name}.svg"
    path.write_text(svg_root(width, height, body, bg="transparent"), encoding="utf-8")
    return path


def convert_to_png(svg_path: Path) -> None:
    png_path = svg_path.with_suffix(".png")
    subprocess.run(["rsvg-convert", "-w", "2400", "-o", str(png_path), str(svg_path)], check=True)


def save(name: str, width: int, height: int, body: str) -> None:
    svg_path = write_svg(name, width, height, body)
    convert_to_png(svg_path)


def save_clean(name: str, width: int, height: int, body: str) -> None:
    write_clean_svg(name, width, height, body)


def donut(cx: int, cy: int, r: int, percent: float, title: str, subtitle: str) -> str:
    circumference = 2 * math.pi * r
    dash = circumference * percent / 100
    rest = circumference - dash
    return "\n".join(
        [
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{RED}" stroke-width="42"/>',
            f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="none" stroke="{BLUE}" stroke-width="42" stroke-dasharray="{dash} {rest}" transform="rotate(-90 {cx} {cy})"/>',
            text(cx, cy - 8, f"{percent:g}%", 46, WHITE, "middle"),
            text(cx, cy + 30, title, 20, WHITE, "middle"),
            text(cx, cy + 58, subtitle, 15, WHITE, "middle"),
        ]
    )


def acquisition_sources() -> None:
    body = "\n".join(
        [
            text(60, 78, "Источники установок", 36),
            donut(390, 285, 120, DATA["telegram_organic_share"], "Telegram / органика", "основной канал привлечения"),
            card(700, 166, 230, 128, "105", "подписчиков", BLUE, "+15 за неделю"),
            card(700, 326, 230, 128, "161", "просмотр постов", RED),
            text(60, 548, "Вывод: почти все установки пришли из Telegram / органики.", 21),
        ]
    )
    save("01_acquisition_sources", 1000, 620, body)


def activation_funnel() -> None:
    users = DATA["users"]
    onboarding = round(users * DATA["onboarding_rate"] / 100)
    auth = round(users * DATA["auth_rate"] / 100)
    stages = [
        ("Пользователи", users, "100%", BLUE),
        ("Завершили onboarding", onboarding, f"{DATA['onboarding_rate']}%", RED),
        ("Прошли авторизацию", auth, f"{DATA['auth_rate']}%", BLUE),
    ]
    max_value = users
    rows = [text(60, 78, "Воронка активации", 36)]
    for i, (label, value, pct, color) in enumerate(stages):
        y = 158 + i * 138
        width = 760 * value / max_value
        x = 500 - width / 2
        points = f"{x},{y} {x + width},{y} {x + width - 32},{y + 82} {x + 32},{y + 82}"
        rows.append(f'<polygon points="{points}" fill="{color}"/>')
        rows.append(text(500, y + 36, f"{label}: {value}", 25, WHITE, "middle"))
        rows.append(text(500, y + 66, pct, 18, WHITE, "middle"))
    rows.append(text(60, 570, "Точка роста: авторизация отсекает часть пользователей после onboarding.", 21))
    save("02_activation_funnel", 1000, 640, "\n".join(rows))


def retention_chart() -> None:
    labels = list(DATA["retention"].keys())
    values = list(DATA["retention"].values())
    max_val = 25
    chart_x, chart_y, chart_w, chart_h = 120, 135, 760, 360
    rows = [text(60, 78, "Удержание пользователей", 36)]
    for tick in range(0, 26, 5):
        y = chart_y + chart_h - chart_h * tick / max_val
        rows.append(line(chart_x, y, chart_x + chart_w, y, GRAY, 1))
        rows.append(text(78, y + 6, f"{tick}%", 15, WHITE, "end"))
    bar_w = 120
    for i, (label, value) in enumerate(zip(labels, values)):
        h = chart_h * value / max_val
        x = chart_x + 95 + i * 220
        y = chart_y + chart_h - h
        rows.append(rect(x, y, bar_w, h, BLUE if i != 1 else RED, 8))
        rows.append(text(x + bar_w / 2, y - 16, f"{value:g}%", 22, WHITE, "middle"))
        rows.append(text(x + bar_w / 2, chart_y + chart_h + 38, label, 20, WHITE, "middle"))
    rows.append(text(60, 560, "Примечание: на малой выборке exact-day retention может быть нестабильным.", 19))
    save("03_retention", 1000, 640, "\n".join(rows))


def feature_usage() -> None:
    items = [
        ("Календарь", DATA["calendar_events"], f"{DATA['calendar_per_user']} на пользователя", BLUE),
        ("Вишлист", DATA["wishlist_adds"], f"{DATA['wishlist_per_user']} на пользователя", RED),
        ("Уведомления", DATA["notifications_users"], f"{DATA['notifications_share']}% пользователей", BLUE),
    ]
    rows = [text(60, 78, "Использование функций", 36)]
    max_val = 55
    for i, (label, value, note, color) in enumerate(items):
        y = 170 + i * 128
        w = 720 * value / max_val
        rows.append(text(60, y + 38, label, 24))
        rows.append(rect(300, y, w, 62, color, 10))
        rows.append(text(320 + w, y + 40, f"{value} · {note}", 21))
    save("04_feature_usage", 1000, 600, "\n".join(rows))


def feedback() -> None:
    body = "\n".join(
        [
            text(60, 78, "Обратная связь", 36),
            card(80, 160, 260, 150, "17", "респондентов", BLUE, "опрос пользователей"),
            card(380, 160, 260, 150, "≈65", "NPS", RED, "первичная оценка"),
            card(680, 160, 260, 150, "5.0", "App Store", BLUE, "оценка приложения"),
            text(80, 405, "Вывод: первые отзывы подтверждают интерес к MVP, но выборка пока небольшая.", 21),
        ]
    )
    save("05_feedback", 1000, 520, body)


def clean_acquisition_sources() -> None:
    body = "\n".join(
        [
            donut(240, 230, 130, DATA["telegram_organic_share"], "Telegram", ""),
            text(240, 410, "98% установок", 24, WHITE, "middle"),
            card(470, 110, 250, 130, "105", "подписчиков", BLUE, "+15 за неделю"),
            card(470, 280, 250, 130, "161", "просмотр постов", RED),
        ]
    )
    save_clean("clean_01_acquisition_sources", 760, 470, body)


def clean_activation_funnel() -> None:
    users = DATA["users"]
    onboarding = round(users * DATA["onboarding_rate"] / 100)
    auth = round(users * DATA["auth_rate"] / 100)
    stages = [
        ("Пользователи", users, "100%", BLUE),
        ("Onboarding", onboarding, f"{DATA['onboarding_rate']}%", RED),
        ("Авторизация", auth, f"{DATA['auth_rate']}%", BLUE),
    ]
    rows = []
    max_value = users
    for i, (label, value, pct, color) in enumerate(stages):
        y = 30 + i * 112
        width = 620 * value / max_value
        x = 330 - width / 2
        points = f"{x},{y} {x + width},{y} {x + width - 34},{y + 72} {x + 34},{y + 72}"
        rows.append(f'<polygon points="{points}" fill="{color}"/>')
        rows.append(text(330, y + 32, f"{label}: {value}", 25, WHITE, "middle"))
        rows.append(text(330, y + 59, pct, 18, WHITE, "middle"))
    save_clean("clean_02_activation_funnel", 660, 350, "\n".join(rows))


def clean_retention_chart() -> None:
    labels = list(DATA["retention"].keys())
    values = list(DATA["retention"].values())
    max_val = 25
    chart_x, chart_y, chart_w, chart_h = 50, 30, 650, 300
    rows = []
    for tick in range(0, 26, 5):
        y = chart_y + chart_h - chart_h * tick / max_val
        rows.append(line(chart_x, y, chart_x + chart_w, y, "#FFFFFF55", 1))
    bar_w = 94
    for i, (label, value) in enumerate(zip(labels, values)):
        h = chart_h * value / max_val
        x = chart_x + 90 + i * 190
        y = chart_y + chart_h - h
        rows.append(rect(x, y, bar_w, h, BLUE if i != 1 else RED, 10))
        rows.append(text(x + bar_w / 2, y - 18, f"{value:g}%", 24, WHITE, "middle"))
        rows.append(text(x + bar_w / 2, chart_y + chart_h + 42, label, 23, WHITE, "middle"))
    save_clean("clean_03_retention", 760, 410, "\n".join(rows))


def clean_feature_usage() -> None:
    items = [
        ("Календарь", DATA["calendar_events"], f"{DATA['calendar_per_user']} на пользователя", BLUE),
        ("Вишлист", DATA["wishlist_adds"], f"{DATA['wishlist_per_user']} на пользователя", RED),
        ("Уведомления", DATA["notifications_users"], f"{DATA['notifications_share']}% пользователей", BLUE),
    ]
    rows = []
    max_val = 55
    for i, (label, value, note, color) in enumerate(items):
        y = 35 + i * 92
        w = 520 * value / max_val
        rows.append(text(24, y + 42, label, 26))
        rows.append(rect(280, y, w, 50, color, 10))
        rows.append(text(280 + w + 24, y + 34, f"{value} · {note}", 23))
    save_clean("clean_04_feature_usage", 1220, 310, "\n".join(rows))


def clean_feedback() -> None:
    body = "\n".join(
        [
            card(0, 0, 245, 128, "17", "респондентов", BLUE, "опрос пользователей"),
            card(285, 0, 245, 128, "≈65", "NPS", RED, "первичная оценка"),
            card(570, 0, 245, 128, "5.0", "App Store", BLUE, "оценка приложения"),
        ]
    )
    save_clean("clean_05_feedback", 815, 128, body)


def dashboard() -> None:
    rows = [
        text(60, 74, "Сводка продуктовой аналитики", 46),
        text(60, 116, f"Период: {DATA['period']}", 25),
        card(60, 154, 280, 108, "57", "пользователей", BLUE),
        card(370, 154, 280, 108, "56", "установок", RED),
        card(680, 154, 280, 108, "98%", "из Telegram", BLUE),
        card(990, 154, 280, 108, "≈65", "NPS", RED),
        card(1300, 154, 240, 108, "5.0", "App Store", BLUE),
        text(72, 326, "Привлечение", 25),
        donut(245, 470, 82, 98, "Telegram", ""),
        text(245, 628, "98% установок", 20, WHITE, "middle"),
    ]

    # Activation funnel
    rows.append(text(470, 326, "Активация", 25))
    funnel = [("Пользователи", 57, BLUE), ("Onboarding", 39, RED), ("Авторизация", 28, BLUE)]
    for i, (label, value, color) in enumerate(funnel):
        y = 374 + i * 70
        w = 430 * value / 57
        rows.append(rect(470, y, w, 46, color, 8))
        rows.append(text(490, y + 31, f"{label}: {value}", 18))

    # Retention
    rows.append(text(1055, 326, "Retention", 25))
    ret = list(DATA["retention"].items())
    for i, (label, value) in enumerate(ret):
        x = 1055 + i * 150
        h = 170 * value / 25
        rows.append(rect(x, 560 - h, 84, h, BLUE if i != 1 else RED, 8))
        rows.append(text(x + 42, 598, label, 16, WHITE, "middle"))
        rows.append(text(x + 42, 548 - h, f"{value:g}%", 18, WHITE, "middle"))

    # Feature usage
    rows.append(text(72, 658, "Использование функций", 25))
    features = [("Календарь", 48, BLUE), ("Вишлист", 21, RED), ("Уведомления", 6, BLUE)]
    for i, (label, value, color) in enumerate(features):
        y = 700 + i * 52
        rows.append(text(72, y + 28, label, 19))
        rows.append(rect(255, y, 400 * value / 55, 36, color, 7))
        rows.append(text(680, y + 27, str(value), 20))

    # Telegram and feedback
    rows.append(text(860, 658, "Канал и обратная связь", 25))
    rows.append(card(860, 700, 220, 122, "105", "подписчиков", BLUE, "+15 за неделю"))
    rows.append(card(1110, 700, 220, 122, "161", "просмотр постов", RED))
    rows.append(card(860, 850, 220, 122, "17", "опрос", BLUE, "респондентов"))
    rows.append(card(1110, 850, 220, 122, "10,5%", "уведомления", RED, "включили"))
    rows.append(text(60, 1032, "Вывод: есть органический интерес; точки роста - авторизация, удержание и включение уведомлений.", 22))
    save("00_dashboard_product_analytics", 1600, 1080, "\n".join(rows))


def main() -> None:
    dashboard()
    acquisition_sources()
    activation_funnel()
    retention_chart()
    feature_usage()
    feedback()
    clean_acquisition_sources()
    clean_activation_funnel()
    clean_retention_chart()
    clean_feature_usage()
    clean_feedback()
    print(f"Готово. SVG и PNG сохранены в {OUT_DIR}")


if __name__ == "__main__":
    main()
