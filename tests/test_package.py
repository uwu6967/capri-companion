"""Package integrity, reproducibility and path-validation checks."""
import importlib.util
import json
from pathlib import Path
from tempfile import TemporaryDirectory
import unittest
import zipfile

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("private_builder", ROOT / "tools" / "build_private.py")
BUILDER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(BUILDER)


class PackageTests(unittest.TestCase):
    def test_unsafe_paths(self):
        for name in ("../outside", "/absolute", "C:/absolute", "src\\file", ""):
            with self.subTest(name=name), self.assertRaises(ValueError):
                BUILDER.safe_relative(name)

    def test_real_payload_roundtrip_and_determinism(self):
        first, checksum = BUILDER.build(ROOT)
        first_bytes = first.read_bytes()
        second, second_checksum = BUILDER.build(ROOT)
        self.assertEqual(first_bytes, second.read_bytes())
        self.assertEqual(checksum, second_checksum)
        with zipfile.ZipFile(first) as archive:
            manifest = json.loads(archive.read("CapriCompanionQoL-MANIFEST.json"))
            self.assertEqual(manifest["visibility"], "private")
            self.assertEqual(len(manifest["files"]), 10)
            self.assertFalse(any(name.endswith("settings.json") for name in archive.namelist()))
            self.assertTrue(all(not Path(name).is_absolute() for name in archive.namelist()))

    def test_public_flag_rejected(self):
        with TemporaryDirectory() as temp:
            root = Path(temp)
            (root / "release-status.json").write_text('{"visibility":"public"}')
            with self.assertRaises(ValueError):
                BUILDER.build(root)


if __name__ == "__main__":
    unittest.main()
