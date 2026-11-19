"""Packs the game: a .love file and, if you give it the LÖVE folder, a Windows folder with an .exe.

    python tools/build.py                          # build/DiplomacyIsInSpace.love
    python tools/build.py --love C:/path/to/love-11.5-win64   # also build/DiplomacyIsInSpace-windows/

The .love holds main.lua, conf.lua, src/ and the exported sprites (assets/sprites/*.png). Tests, the
Libresprite sources (assets/src) and docs stay out.
"""
import argparse
import os
import shutil
import zipfile

HERE = os.path.dirname(os.path.abspath(__file__))
GAME = os.path.normpath(os.path.join(HERE, ".."))


def collect():
    files = ["main.lua", "conf.lua"]
    for folder, _, names in os.walk(os.path.join(GAME, "src")):
        for name in names:
            if name.endswith(".lua"):
                files.append(os.path.relpath(os.path.join(folder, name), GAME).replace("\\", "/"))
    sprites = os.path.join(GAME, "assets", "sprites")
    for name in sorted(os.listdir(sprites)):
        if name.endswith(".png"):
            files.append("assets/sprites/" + name)
    return sorted(files)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--love", help="folder of a LÖVE 11.5 win64 download (love.exe and its DLLs)")
    parser.add_argument("--out", default=os.path.join(GAME, "build"), help="output folder (default: build/)")
    args = parser.parse_args()

    os.makedirs(args.out, exist_ok=True)
    love_file = os.path.join(args.out, "DiplomacyIsInSpace.love")
    files = collect()
    with zipfile.ZipFile(love_file, "w", zipfile.ZIP_DEFLATED) as archive:
        for name in files:
            archive.write(os.path.join(GAME, name), name)
    print(f"{len(files)} files -> {love_file} ({os.path.getsize(love_file) // 1024} KB)")

    if args.love:
        folder = os.path.join(args.out, "DiplomacyIsInSpace-windows")
        shutil.rmtree(folder, ignore_errors=True)
        os.makedirs(folder)
        with open(os.path.join(folder, "DiplomacyIsInSpace.exe"), "wb") as exe:
            exe.write(open(os.path.join(args.love, "love.exe"), "rb").read())  # love.exe + the game glued on
            exe.write(open(love_file, "rb").read())
        for name in os.listdir(args.love):
            if name.lower().endswith(".dll"):
                shutil.copy(os.path.join(args.love, name), folder)
        print("Windows folder ->", folder)


if __name__ == "__main__":
    main()
