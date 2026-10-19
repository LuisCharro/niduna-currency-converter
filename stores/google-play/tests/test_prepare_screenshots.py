"""Offline checks for the Play gallery export; no browser or credentials."""
import hashlib
import importlib.util
import json
from pathlib import Path
import tempfile
import unittest

try:
    from PIL import Image
except ImportError:
    Image = None

SPEC = importlib.util.spec_from_file_location(
    "prepare_screenshots", Path(__file__).resolve().parents[1] / "scripts/prepare_screenshots.py"
)
exporter = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(exporter)


@unittest.skipIf(Image is None, "Install stores/google-play/requirements.txt for image checks")
class GalleryTests(unittest.TestCase):
    def test_preserves_app_pixels_and_hashes_in_order(self):
        with tempfile.TemporaryDirectory() as temporary:
            source, output = Path(temporary) / "source", Path(temporary) / "output"
            originals = []
            for theme in ("light", "dark"):
                (source / theme).mkdir(parents=True)
                for screen in ("01-convert", "02-chart-btc", "03-favorites"):
                    image = Image.new("RGB", (1080, 2400), (21, 45, len(originals)))
                    image.putpixel((100, 200), (255, 0, 0))
                    image.save(source / theme / f"{screen}.png")
                    originals.append(image)
            manifest = exporter.export_gallery(source, output)
            self.assertEqual(len(manifest["images"]), 6)
            self.assertEqual(manifest["images"][1]["file"], "02-light-chart-btc.png")
            for entry, original in zip(manifest["images"], originals):
                path = output / entry["file"]
                with Image.open(path) as exported:
                    self.assertEqual(exported.size, (1350, 2400))
                    self.assertEqual(exported.crop((135, 0, 1215, 2400)).tobytes(), original.tobytes())
                self.assertEqual(entry["sha256"], hashlib.sha256(path.read_bytes()).hexdigest())
            self.assertEqual(json.loads((output / "manifest.json").read_text()), manifest)
            self.assertTrue((output / "preview.jpg").exists())

    def test_wrong_dimensions_fail_before_writing_gallery(self):
        with tempfile.TemporaryDirectory() as temporary:
            source, output = Path(temporary) / "source", Path(temporary) / "output"
            (source / "light").mkdir(parents=True)
            Image.new("RGB", (100, 100)).save(source / "light/01-convert.png")
            with self.assertRaisesRegex(ValueError, "Expected 1080x2400"):
                exporter.export_gallery(source, output)
            self.assertFalse(output.exists())

    def test_missing_capture_fails_before_writing_gallery(self):
        with tempfile.TemporaryDirectory() as temporary:
            output = Path(temporary) / "output"
            with self.assertRaises(FileNotFoundError):
                exporter.export_gallery(Path(temporary) / "absent", output)
            self.assertFalse(output.exists())
