"""Regenerates the Android launcher icon PNGs from icon_master_1024.png.

Usage (from pushups_tracker/):  python tool/generate_launcher_icons.py

Requires Pillow. Writes, per density, into android/app/src/main/res/mipmap-*:
  ic_launcher.png             legacy square icon (the master, downscaled)
  ic_launcher_foreground.png  adaptive-icon foreground: the figure on transparent

The adaptive background is the gradient in drawable/ic_launcher_background.xml;
its colours and direction mirror BG_ORIGIN / BG_DX / BG_DY below, so keep the
two in sync if the master's gradient changes.
"""
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MASTER = ROOT.parent / "icon_master_1024.png"
RES = ROOT / "android" / "app" / "src" / "main" / "res"

# The master's background is a linear gradient: colour at (0, 0), plus the
# per-channel change across the full width (DX) and full height (DY).
BG_ORIGIN = (255, 95, 46)
BG_DX = (0, 29, 5)
BG_DY = (0, 51, 8)
FIGURE = (255, 250, 240)

# Fraction of the 108dp adaptive canvas the master maps onto. 72/108 would
# reproduce the master exactly inside the visible viewport; slightly less keeps
# the ground line inside the 66dp safe circle for round masks.
FOREGROUND_SCALE = 0.66

DENSITIES = {"mdpi": 1, "hdpi": 1.5, "xhdpi": 2, "xxhdpi": 3, "xxxhdpi": 4}


def extract_figure(master: Image.Image) -> Image.Image:
    """Returns the figure as FIGURE-coloured pixels with recovered alpha."""
    w, h = master.size
    src = master.convert("RGB").load()
    alpha = Image.new("L", (w, h))
    out = alpha.load()
    for y in range(h):
        for x in range(w):
            # Green has the widest gap between background and figure.
            bg = BG_ORIGIN[1] + BG_DX[1] * x / (w - 1) + BG_DY[1] * y / (h - 1)
            a = (src[x, y][1] - bg) / (FIGURE[1] - bg)
            out[x, y] = 0 if a < 0.03 else min(255, round(a * 255))
    figure = Image.new("RGBA", (w, h), FIGURE + (0,))
    figure.putalpha(alpha)
    return figure


def main() -> None:
    master = Image.open(MASTER)
    figure = extract_figure(master)
    bbox = figure.getbbox()
    figure = figure.crop(bbox)

    for name, factor in DENSITIES.items():
        out_dir = RES / f"mipmap-{name}"
        out_dir.mkdir(parents=True, exist_ok=True)

        legacy = round(48 * factor)
        master.convert("RGB").resize((legacy, legacy), Image.LANCZOS).save(
            out_dir / "ic_launcher.png"
        )

        canvas = round(108 * factor)
        scale = canvas * FOREGROUND_SCALE / master.width
        size = (round(figure.width * scale), round(figure.height * scale))
        foreground = Image.new("RGBA", (canvas, canvas), (0, 0, 0, 0))
        # Centre the figure's bounding box so it sits evenly in round masks.
        foreground.alpha_composite(
            figure.resize(size, Image.LANCZOS),
            ((canvas - size[0]) // 2, (canvas - size[1]) // 2),
        )
        foreground.save(out_dir / "ic_launcher_foreground.png")


if __name__ == "__main__":
    main()
