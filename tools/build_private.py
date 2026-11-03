"""Build a deterministic, verified PRIVATE game-layout archive. No network calls."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def safe_relative(value):
    path = PurePosixPath(value)
    if not value or path.is_absolute() or ".." in path.parts or "\\" in value or ":" in value:
        raise ValueError(f"Unsafe package path: {value!r}")
    return path


def build(root=ROOT):
    root = Path(root)
    status = json.loads((root / "release-status.json").read_text(encoding="utf-8"))
    if status.get("visibility") != "private":
        raise ValueError("This builder only supports private candidates; public publishing is not implemented.")
    version = (root / "VERSION").read_text(encoding="utf-8").strip()
    if not version or any(c not in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.-" for c in version):
        raise ValueError("Invalid version string")
    mapping = json.loads((root / "package-map.json").read_text(encoding="utf-8"))
    payload = {}
    for source, destination in mapping.items():
        source_path, destination_path = safe_relative(source), safe_relative(destination)
        resolved = (root / str(source_path)).resolve()
        if not resolved.is_relative_to(root.resolve()):
            raise ValueError("Source escapes project root")
        if str(destination_path) in payload:
            raise ValueError("Duplicate install destination")
        payload[str(destination_path)] = resolved.read_bytes()
    manifest = {
        "version": version,
        "visibility": "private",
        "release_status": status,
        "files": {name: {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}
                  for name, data in sorted(payload.items())},
    }
    payload["CapriCompanionQoL-MANIFEST.json"] = (json.dumps(manifest, indent=2) + "\n").encode()
    payload["CapriCompanionQoL-PRIVATE-README.txt"] = (
        "PRIVATE TEST CANDIDATE - DO NOT UPLOAD TO NEXUS\n\n"
        "Requires the original Capricorn mod and its frameworks.\n"
        "Contains modified upstream scripts and derived artwork. Author permission has not been granted.\n"
        "Mission safety remains unverified. Automatic Sandevistan attacks default OFF.\n"
        "Close Cyberpunk before installing. Back up matching files before extracting at the game root.\n"
        "Prefer the project's backing-up installer for personal testing.\n"
        "Restore a checkpoint from before any mission character was harmed.\n"
        "Tutorial: CapriCompanionQoL-docs/docs/PLAYER_GUIDE.md\n"
        "Settings: CapriCompanionQoL-docs/docs/SETTINGS.md\n"
        "FAQ and credits are in the same documentation folder.\n"
    ).encode()
    for name in ("CHANGELOG.md", "THIRD_PARTY_NOTICES.md", "docs/KNOWN_ISSUES.md",
                 "docs/PLAYER_GUIDE.md", "docs/SETTINGS.md", "docs/FAQ.md",
                 "docs/CREDITS.md", "docs/NEXUS_DRAFT.md"):
        payload["CapriCompanionQoL-docs/" + name] = (root / name).read_bytes()
    output = root / "dist" / "private"
    output.mkdir(parents=True, exist_ok=True)
    archive = output / f"CapriCompanionQoL-{version}.zip"
    with zipfile.ZipFile(archive, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as handle:
        for name, data in sorted(payload.items()):
            info = zipfile.ZipInfo(name, date_time=(1980, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            handle.writestr(info, data)
    with zipfile.ZipFile(archive) as handle:
        if handle.testzip() is not None or set(handle.namelist()) != set(payload):
            raise ValueError("Archive verification failed")
        for name, expected in payload.items():
            if handle.read(name) != expected:
                raise ValueError(f"Archive contents mismatch: {name}")
    checksum = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{checksum}  {archive.name}\n", encoding="utf-8")
    return archive, checksum


if __name__ == "__main__":
    argparse.ArgumentParser(description=__doc__).parse_args()
    package, checksum = build()
    print(f"Private candidate: {package}\nSHA256: {checksum}")
