#!/usr/bin/env python3
"""Export the six reviewed portrait captures as Play-compatible 9:16 PNGs."""
import argparse
import hashlib
import json
from pathlib import Path


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def export_gallery(source: Path, output: Path):
    from PIL import Image

    entries = []
    prepared = []
    for theme in ("light", "dark"):
        for screen in ("01-convert", "02-chart-btc", "03-favorites"):
            path = source / theme / f"{screen}.png"
            with Image.open(path) as image:
                image.load()
                if image.size != (1080, 2400):
                    raise ValueError(f"Expected 1080x2400 capture: {path} is {image.size}")
                original = image.convert("RGB")
                canvas = Image.new("RGB", (1350, 2400), original.getpixel((0, 0)))
                canvas.paste(original, (135, 0))
                name = f"{len(entries) + 1:02d}-{theme}-{screen[3:]}.png"
                prepared.append((canvas, name))
                entries.append({"file": name, "source": str(path.resolve()), "sourceSha256": digest(path)})
    output.mkdir(parents=True, exist_ok=True)
    for (image, name), entry in zip(prepared, entries):
        target = output / name
        image.save(target, optimize=True)
        if target.stat().st_size > 8 * 1024 * 1024:
            raise ValueError(f"Play screenshot exceeds 8 MiB: {target}")
        entry.update(sha256=digest(target), width=1350, height=2400, sizeBytes=target.stat().st_size)
    manifest = {"locale": "en-GB", "imageType": "phoneScreenshots", "images": entries}
    (output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    preview = Image.new("RGB", (1350, 1600), "#808080")
    for index, (image, _) in enumerate(prepared):
        preview.paste(image.resize((450, 800)), ((index % 3) * 450, (index // 3) * 800))
    preview.save(output / "preview.jpg")
    return manifest


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", required=True, type=Path, help="Root with light/ and dark/ captures")
    parser.add_argument("--output", required=True, type=Path, help="Output gallery directory")
    args = parser.parse_args()
    try:
        manifest = export_gallery(args.source, args.output)
    except (OSError, ValueError, ImportError) as error:
        parser.exit(1, f"Screenshot export failed: {error}\n")
    print(f"Prepared {len(manifest['images'])} screenshots and manifest in {args.output}")


if __name__ == "__main__":
    main()
