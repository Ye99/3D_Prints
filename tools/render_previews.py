#!/usr/bin/env python3
"""Render a PNG preview for every 3D model in this repo.

Previews go to ``previews/<model path>.png`` (for example
``previews/AirHoseAdapter/AirHoseAdapter_8mm.stl.png``), so model folders stay
untouched. A manifest of file hashes (``previews/manifest.json``) means only new
or changed models are re-rendered, and previews of deleted models are removed.

Rendering is pure software (trimesh + numpy + Pillow): no GPU, display or
OpenGL is needed, so it runs the same on a laptop and in GitHub Actions.

Supported: .stl and .3mf. OpenSCAD sources (.scad) are not rendered; their
exported .stl next to them gets a preview instead.

Usage:
    python tools/render_previews.py            # render new/changed models
    python tools/render_previews.py --force    # re-render everything
    python tools/render_previews.py --check    # exit 1 if any preview is missing or stale
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import sys
from concurrent.futures import ProcessPoolExecutor
from pathlib import Path

import numpy as np
import trimesh
from PIL import Image, ImageDraw

REPO = Path(__file__).resolve().parent.parent
OUT_DIR = REPO / "previews"
MANIFEST = OUT_DIR / "manifest.json"
MODEL_EXTS = {".stl", ".3mf"}
# Folders that never hold printable models of their own (git submodules, IDE files).
SKIP_DIRS = {".git", ".github", ".idea", ".cursor", "previews", "tools",
             "BOSL", "MCAD", "OpenSCAD-common-libraries"}

SIZE = 512            # output width and height in pixels
SUPERSAMPLE = 2       # render larger, then downscale for anti-aliasing
BACKGROUND = (255, 255, 255, 255)
BASE_COLOR = np.array([70, 130, 200], dtype=float)   # steel blue
VIEW_DIR = np.array([1.0, -1.0, 0.8])                # camera sits front-right-above, Z up
LIGHT_DIR = np.array([0.4, -0.6, 1.0])


def find_models(root: Path) -> list[Path]:
    models = []
    for path in root.rglob("*"):
        rel = path.relative_to(root)
        if any(part in SKIP_DIRS for part in rel.parts[:-1]):
            continue
        if path.is_file() and path.suffix.lower() in MODEL_EXTS:
            models.append(rel)
    return sorted(models, key=lambda p: p.as_posix().lower())


def file_hash(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def load_mesh(path: Path) -> trimesh.Trimesh:
    loaded = trimesh.load(path, force="mesh")
    if not isinstance(loaded, trimesh.Trimesh) or len(loaded.faces) == 0:
        raise ValueError("no triangles found")
    # The painter's algorithm sorts whole triangles, so long thin ones can be
    # drawn in the wrong order. Splitting long edges keeps the picture clean.
    max_edge = np.linalg.norm(loaded.extents) / 60
    if loaded.edges_unique_length.max() > max_edge:
        try:
            verts, faces = trimesh.remesh.subdivide_to_size(
                loaded.vertices, loaded.faces, max_edge=max_edge, max_iter=10)
            loaded = trimesh.Trimesh(verts, faces, process=False)
        except ValueError:
            pass  # very long, thin parts: render as-is rather than not at all
    return loaded


def camera_basis() -> np.ndarray:
    """Rows are the camera's right, up and toward-viewer axes in world space."""
    forward = VIEW_DIR / np.linalg.norm(VIEW_DIR)          # points toward the viewer
    right = np.cross([0.0, 0.0, 1.0], forward)
    right /= np.linalg.norm(right)
    up = np.cross(forward, right)
    return np.stack([right, up, forward])


def render(mesh: trimesh.Trimesh) -> Image.Image:
    """Flat-shaded orthographic render using the painter's algorithm."""
    basis = camera_basis()
    verts = (mesh.vertices - mesh.bounds.mean(axis=0)) @ basis.T
    tris = verts[mesh.faces]                                   # (n, 3, 3) in camera space

    normals = np.cross(tris[:, 1] - tris[:, 0], tris[:, 2] - tris[:, 0])
    lengths = np.linalg.norm(normals, axis=1)
    keep = lengths > 0
    tris, normals = tris[keep], normals[keep] / lengths[keep, None]
    # Draw both sides so meshes with flipped normals still look solid.
    facing = np.sign(normals[:, 2])
    facing[facing == 0] = 1
    normals = normals * facing[:, None]

    light = LIGHT_DIR @ basis.T
    light /= np.linalg.norm(light)
    shade = 0.35 + 0.65 * np.clip(normals @ light, 0, 1)
    colors = np.clip(BASE_COLOR[None, :] * shade[:, None] + 25 * (1 - shade[:, None]), 0, 255)

    canvas = SIZE * SUPERSAMPLE
    margin = 0.08 * canvas
    xy = tris[:, :, :2]
    lo, hi = xy.reshape(-1, 2).min(axis=0), xy.reshape(-1, 2).max(axis=0)
    span = max(hi - lo)
    scale = (canvas - 2 * margin) / span if span > 0 else 1.0
    center = (lo + hi) / 2
    px = (xy - center) * scale
    px[:, :, 0] += canvas / 2
    px[:, :, 1] = canvas / 2 - px[:, :, 1]                     # image y grows downward

    order = np.argsort(tris[:, :, 2].mean(axis=1))             # far to near
    img = Image.new("RGBA", (canvas, canvas), BACKGROUND)
    draw = ImageDraw.Draw(img)
    for i in order:
        color = tuple(int(c) for c in colors[i])
        pts = [tuple(p) for p in px[i]]
        draw.polygon(pts, fill=color, outline=color)
    return img.resize((SIZE, SIZE), Image.LANCZOS).convert("RGB")


def preview_path(model: Path) -> Path:
    return OUT_DIR / (model.as_posix() + ".png")


def render_one(model: Path) -> str | None:
    """Render one model to its preview file. Returns an error message, or None."""
    try:
        image = render(load_mesh(REPO / model))
    except Exception as exc:  # keep going; one bad file shouldn't block the rest
        return str(exc) or type(exc).__name__
    out = preview_path(model)
    out.parent.mkdir(parents=True, exist_ok=True)
    image.save(out, optimize=True)
    return None


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--force", action="store_true", help="re-render every model")
    parser.add_argument("--check", action="store_true",
                        help="only report missing or stale previews; exit 1 if any")
    parser.add_argument("--jobs", type=int, default=0,
                        help="parallel render processes (default: one per CPU)")
    args = parser.parse_args()

    manifest: dict[str, str] = {}
    # Load the manifest even with --force so removed models are still pruned.
    if MANIFEST.exists():
        manifest = json.loads(MANIFEST.read_text())

    models = find_models(REPO)
    current = {m.as_posix() for m in models}
    todo = []
    for model in models:
        key = model.as_posix()
        digest = file_hash(REPO / model)
        if args.force or manifest.get(key) != digest or not preview_path(model).exists():
            todo.append((model, digest))
    stale = sorted(set(manifest) - current)

    if args.check:
        for model, _ in todo:
            print(f"missing or stale: {preview_path(model).relative_to(REPO)}")
        for key in stale:
            print(f"orphaned: previews/{key}.png")
        return 1 if todo or stale else 0

    failures = []
    workers = args.jobs or os.cpu_count() or 1
    with ProcessPoolExecutor(max_workers=workers) as pool:
        results = pool.map(render_one, [model for model, _ in todo])
        for n, ((model, digest), error) in enumerate(zip(todo, results), 1):
            if error:
                failures.append(f"{model}: {error}")
                print(f"[{n}/{len(todo)}] FAILED {model}: {error}", file=sys.stderr)
                continue
            manifest[model.as_posix()] = digest
            print(f"[{n}/{len(todo)}] {preview_path(model).relative_to(REPO)}", flush=True)

    for key in stale:
        orphan = OUT_DIR / (key + ".png")
        orphan.unlink(missing_ok=True)
        manifest.pop(key, None)
        print(f"removed orphaned preview for {key}")
    # Clean up folders left empty by removed previews.
    for folder in sorted((p for p in OUT_DIR.rglob("*") if p.is_dir()), reverse=True):
        if not any(folder.iterdir()):
            folder.rmdir()

    OUT_DIR.mkdir(exist_ok=True)
    MANIFEST.write_text(json.dumps(dict(sorted(manifest.items())), indent=2) + "\n")
    print(f"rendered {len(todo) - len(failures)}, failed {len(failures)}, "
          f"removed {len(stale)}, total previews {len(manifest)}")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
