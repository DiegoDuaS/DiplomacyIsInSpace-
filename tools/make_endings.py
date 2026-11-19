"""Builds bg_endings.png and ui_stamps.png by composing the game's own sprites in code.

    python tools/make_endings.py

Nothing here is a new drawing: the three endings reuse the delegates, ship, station and planets
drawn in Libresprite (assets/sprites), tinted and arranged; the stamps are lettered with the game's own bitmap font (src/data/font_main.lua).
Replace either PNG with a hand-drawn one at any time: the game only reads the PNG.
"""
import os
import random
from PIL import Image, ImageDraw, ImageEnhance

HERE = os.path.dirname(os.path.abspath(__file__))
SPRITES = os.path.join(HERE, "..", "assets", "sprites")
W, H = 640, 400


def load(name):
    return Image.open(os.path.join(SPRITES, name + ".png")).convert("RGBA")


def frame(name, index, size):
    sheet = load(name)
    count = sheet.width // size[0]
    i = index % count
    return sheet.crop((i * size[0], 0, (i + 1) * size[0], size[1]))


def alien(name, index=0):
    return frame(name, index, (128, 128))


def tint(image, color, strength=0.5):
    """Mixes the opaque pixels toward `color`."""
    r, g, b, a = image.split()
    flat = Image.new("RGBA", image.size, color + (255,))
    mixed = Image.blend(image, flat, strength)
    mixed.putalpha(a)
    return mixed


def desaturate(image, amount):
    r, g, b, a = image.split()
    out = ImageEnhance.Color(Image.merge("RGB", (r, g, b))).enhance(amount)
    out = ImageEnhance.Brightness(out).enhance(0.85)
    out = out.convert("RGBA")
    out.putalpha(a)
    return out


def silhouette(image, color, alpha):
    out = Image.new("RGBA", image.size, color + (255,))
    mask = image.split()[3].point(lambda v: alpha if v else 0)
    out.putalpha(mask)
    return out


def paste(canvas, sprite, x, y, flip=False):
    if flip:
        sprite = sprite.transpose(Image.FLIP_LEFT_RIGHT)
    canvas.alpha_composite(sprite, (int(x), int(y)))


def bands(colors, slope=0.18, thickness=64):
    """Diagonal bands of colour with a dithered edge, like bg_menu."""
    image = Image.new("RGBA", (W, H))
    px = image.load()
    n = len(colors)
    for y in range(H):
        for x in range(W):
            t = (y + x * slope) / thickness
            index = int(t)
            fraction = t - index
            if fraction > 0.82 and (x + y) % 2 == 0:  # dither toward the next band
                index += 1
            px[x, y] = colors[max(0, min(n - 1, index))] + (255,)
    return image


def stars(canvas, seed, count, tintcolor=(255, 255, 255)):
    rng = random.Random(seed)
    px = canvas.load()
    for _ in range(count):
        x, y = rng.randrange(W), rng.randrange(H)
        shade = rng.choice((0.4, 0.6, 0.9))
        px[x, y] = tuple(int(c * shade) for c in tintcolor) + (255,)
        if rng.random() < 0.12 and x + 1 < W and y + 1 < H:  # a few bigger ones
            px[x + 1, y] = px[x, y]
            px[x, y + 1] = px[x, y]


def dither_disc(canvas, cx, cy, radius, color, seed=0, density=0.5):
    """A soft glow: a disc whose edge fades out with scattered pixels."""
    rng = random.Random(seed)
    px = canvas.load()
    for y in range(int(cy - radius), int(cy + radius) + 1):
        for x in range(int(cx - radius), int(cx + radius) + 1):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
            if d <= radius and 0 <= x < W and 0 <= y < H:
                chance = (1 - d / radius) ** 0.6 * density * 2
                if rng.random() < chance:
                    px[x, y] = color + (255,)


def treaty(canvas, x, y):
    """A tiny sheet of paper."""
    d = ImageDraw.Draw(canvas)
    d.rectangle([x, y, x + 6, y + 8], fill=(236, 233, 224, 255))
    d.rectangle([x + 1, y + 2, x + 5, y + 2], fill=(120, 120, 130, 255))
    d.rectangle([x + 1, y + 4, x + 5, y + 4], fill=(120, 120, 130, 255))
    d.rectangle([x + 1, y + 6, x + 3, y + 6], fill=(214, 70, 60, 255))


def flame(canvas, x, base, height, seed):
    rng = random.Random(seed)
    d = ImageDraw.Draw(canvas)
    for layer, color in enumerate(((214, 70, 60, 255), (236, 140, 40, 255), (250, 220, 90, 255))):
        h = int(height * (1 - layer * 0.28))
        w = max(2, int((height * 0.28) * (1 - layer * 0.3)))
        for row in range(h):
            half = max(0, int(w * (1 - row / h) ** 0.7))
            jitter = rng.choice((-1, 0, 0, 1)) if row > 3 else 0
            d.rectangle([x - half + jitter, base - row, x + half + jitter, base - row], fill=color)


def explosion(canvas, cx, cy, r, seed):
    dither_disc(canvas, cx, cy, r, (214, 70, 60), seed, 0.55)
    dither_disc(canvas, cx, cy, r * 0.7, (236, 140, 40), seed + 1, 0.6)
    dither_disc(canvas, cx, cy, r * 0.4, (250, 225, 110), seed + 2, 0.7)


# the three delegates stand where the picture's free band is (y 118-256 in the game)
SLOTS = [64, 256, 448]
TOP = 122


def ending_win():
    canvas = bands([(10, 14, 44), (18, 30, 84), (36, 64, 124), (70, 100, 150), (120, 130, 160), (190, 150, 130), (226, 176, 124)],
                   slope=0.1, thickness=60)
    stars(canvas, 1, 140)
    homes = ["map_thalassa", "map_krag", "map_hexa"]
    for slot, home in zip(SLOTS, homes):  # each delegate in front of its world
        planet = load(home)
        paste(canvas, planet, slot + 16, 96)
    people = [alien("alien_kelari_peace", -1), alien("alien_vorn_peace", -1), alien("alien_ixili_calm", 0)]
    for slot, sprite in zip(SLOTS, people):
        paste(canvas, sprite, slot, TOP)
    for x, y in ((196, 150), (214, 176), (388, 142), (408, 172), (322, 190)):
        treaty(canvas, x, y)  # the signed treaties
    ship = frame("ship", 0, (16, 16)).resize((32, 32), Image.NEAREST)
    for x, y in ((300, 296), (330, 288), (270, 306), (360, 306)):  # a fleet at rest, nose up
        paste(canvas, ship, x, y)
    return canvas


def ending_bad():
    canvas = bands([(14, 4, 8), (34, 6, 10), (62, 10, 12), (96, 18, 14), (140, 36, 16)], slope=0.2, thickness=62)
    stars(canvas, 2, 90, (255, 190, 160))
    homes = ["map_thalassa", "map_krag", "map_hexa"]
    for slot, home in zip(SLOTS, homes):
        paste(canvas, tint(load(home), (90, 10, 10), 0.6), slot + 16, 96)
    # the station, broken in two and drifting apart
    station = load("map_station")
    top = station.crop((0, 0, 64, 30)).rotate(14, resample=Image.NEAREST, expand=True)
    bottom = station.crop((0, 30, 64, 64)).rotate(-18, resample=Image.NEAREST, expand=True)
    paste(canvas, tint(top, (60, 20, 20), 0.5), 290, 70)
    paste(canvas, tint(bottom, (60, 20, 20), 0.5), 320, 330)
    rocks = load("map_asteroids")
    rng = random.Random(4)
    for i in range(16):  # debris
        rock = rocks.crop(((i % 4) * 16, 0, (i % 4) * 16 + 16, 16)).rotate(rng.choice((0, 90, 180, 270)))
        paste(canvas, tint(rock, (120, 30, 20), 0.35), rng.randrange(10, 610), rng.choice((100, 258, 280, 300, 350)) + rng.randrange(-14, 14))
    people = [alien("alien_kelari_war", -1), alien("alien_vorn_war", -1), alien("alien_ixili_furious", 0)]
    for slot, sprite in zip(SLOTS, people):
        paste(canvas, tint(sprite, (255, 70, 40), 0.18), slot, TOP)
    for i, x in enumerate(range(20, 640, 46)):  # a line of fire along the bottom of the free band
        flame(canvas, x + (i % 3) * 5, 262, 26 + (i * 7) % 22, 10 + i)
    for cx, cy, r in ((150, 210, 40), (500, 200, 46), (320, 130, 30), (40, 150, 26), (610, 240, 30)):
        explosion(canvas, cx, cy, r, int(cx + cy))
    return canvas


def ending_meh():
    canvas = bands([(14, 14, 22), (24, 24, 36), (38, 38, 54), (56, 56, 74), (76, 76, 96)], slope=0.1, thickness=70)
    stars(canvas, 3, 110, (200, 205, 230))
    homes = ["map_thalassa", "map_krag", "map_hexa"]
    for slot, home in zip(SLOTS, homes):
        paste(canvas, desaturate(load(home), 0.35), slot + 16, 96)
    kelari = desaturate(alien("alien_kelari_peace", -1), 0.55)
    ixili = desaturate(alien("alien_ixili_calm", 0), 0.55)
    empty_seat = silhouette(alien("alien_vorn_peace", -1), (6, 6, 12), 150)  # Vorn's place, left empty
    paste(canvas, kelari, SLOTS[0], TOP)
    paste(canvas, empty_seat, SLOTS[1], TOP)
    paste(canvas, ixili, SLOTS[2], TOP)
    treaty(canvas, 206, 176)  # one treaty signed...
    d = ImageDraw.Draw(canvas)
    d.rectangle([396, 176, 402, 184], outline=(120, 120, 130, 255))  # ...one still blank
    ship = frame("ship", 1, (16, 16)).rotate(-90, resample=Image.NEAREST)  # Vorn's shuttle, leaving
    ship = desaturate(ship.resize((32, 32), Image.NEAREST), 0.6)
    for i in range(7):  # its trail
        d.rectangle([470 + i * 8, 311 + (i % 2) * 2, 473 + i * 8, 313 + (i % 2) * 2], fill=(120 - i * 12, 120 - i * 12, 140 - i * 12, 255))
    paste(canvas, ship, 440, 298)
    return canvas


# ---------------------------------------------------------------------------------- stamps
INK = {"peace": (218, 218, 214), "war": (214, 70, 60), "walkout": (236, 182, 64)}
TEXT = {"peace": "PEACE HOLDS", "war": "WAR", "walkout": "WALKED OUT"}
SCALE = {"peace": 2, "war": 4, "walkout": 2}


def load_glyphs():
    """The capitals of the game's own font (src/data/font_main.lua), as rows of '#' and '.'."""
    import re
    source = open(os.path.join(HERE, "..", "src", "data", "font_main.lua"), encoding="utf8").read()
    glyphs = {" ": ["..."] * 7}
    for char, body in re.findall(r'define\("([A-Z])", \[\[\n(.*?)\]\]\)', source, re.S):
        glyphs[char] = body.split("\n")[:7]
    return glyphs


def lettering(text, scale):
    """The text as an RGBA mask drawn with the game's own glyphs (no system font involved)."""
    glyphs = load_glyphs()
    width = sum(len(glyphs[c][0]) + 1 for c in text) - 1
    mask = Image.new("L", (width * scale, 7 * scale), 0)
    px = mask.load()
    x = 0
    for c in text:
        rows = glyphs[c]
        for r, row in enumerate(rows):
            for col, ch in enumerate(row):
                if ch == "#":
                    for dy in range(scale):
                        for dx in range(scale):
                            px[(x + col) * scale + dx, r * scale + dy] = 255
        x += len(rows[0]) + 1
    return mask


def stamp(kind):
    image = Image.new("RGBA", (160, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(image)
    ink = INK[kind] + (255,)
    # a plaque with cut corners: dark inside, two rules around it
    for inset in (0, 3):
        d.rectangle([inset + 2, inset, 159 - inset - 2, 47 - inset], outline=ink)
        d.rectangle([inset, inset + 2, 159 - inset, 47 - inset - 2], outline=ink)
    d.rectangle([5, 5, 154, 42], fill=(16, 16, 20, 255))
    d.rectangle([4, 4, 155, 43], outline=ink)

    mask = lettering(TEXT[kind], SCALE[kind])
    x, y = (160 - mask.width) // 2, (48 - mask.height) // 2
    shadow = Image.new("RGBA", mask.size, (0, 0, 0, 255))
    image.paste(shadow, (x + 1, y + 1), mask)  # a hard shadow
    image.paste(Image.new("RGBA", mask.size, ink), (x, y), mask)

    rng = random.Random(sum(map(ord, kind)))
    px = image.load()
    for _ in range(70):  # worn ink: a few pixels missing
        wx, wy = rng.randrange(160), rng.randrange(48)
        if px[wx, wy][3] and rng.random() < 0.6:
            px[wx, wy] = (16, 16, 20, 255)
    return image


def main():
    endings = Image.new("RGBA", (W * 3, H))
    for i, build in enumerate((ending_win, ending_bad, ending_meh)):  # frames: 1 win, 2 bad, 3 meh
        endings.alpha_composite(build(), (i * W, 0))
    endings.save(os.path.join(SPRITES, "bg_endings.png"))

    stamps = Image.new("RGBA", (160 * 3, 48))
    for i, kind in enumerate(("peace", "war", "walkout")):  # frames: 1 peace, 2 war, 3 walkout
        stamps.alpha_composite(stamp(kind), (i * 160, 0))
    stamps.save(os.path.join(SPRITES, "ui_stamps.png"))
    print("bg_endings.png 1920x400, ui_stamps.png 480x48")


if __name__ == "__main__":
    main()
