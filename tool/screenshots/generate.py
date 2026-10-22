#!/usr/bin/env python3
"""Capture README images and cache only the OSM tiles requested by the map."""
import os
from pathlib import Path
import shutil
import subprocess
import urllib.parse
import urllib.request

repo = Path(__file__).resolve().parents[2]
sdk_env = os.environ.get('FLUTTER_HOME')
flutter = Path(sdk_env) / 'bin/flutter' if sdk_env else Path(shutil.which('flutter') or '')
if not flutter.is_file():
    raise SystemExit('Set FLUTTER_HOME to the existing Flutter SDK, or add flutter to PATH.')
env = dict(os.environ, FLUTTER_HOME=str(flutter.resolve().parent.parent), TZ='UTC')


def capture():
    subprocess.run(
        [str(flutter), 'test', 'tool/screenshots/capture.dart', '--reporter', 'expanded'],
        cwd=repo, env=env, check=True,
    )


def fetch_tiles():
    requests = (repo / 'build/readme-tile-requests.txt').read_text().splitlines()
    for url in sorted(set(requests)):
        parsed = urllib.parse.urlparse(url)
        if parsed.scheme != 'https' or parsed.netloc != 'tile.openstreetmap.org':
            raise SystemExit(f'Unexpected tile source: {url}')
        destination = repo / 'build/readme-tiles' / parsed.path.lstrip('/')
        if destination.exists():
            continue
        request = urllib.request.Request(url, headers={
            'User-Agent': 'EndurainForkReadmeScreenshots/1.0 (https://github.com/niklasonfire/endurain-flutter)',
        })
        with urllib.request.urlopen(request, timeout=30) as response:
            data = response.read()
        if not data.startswith(b'\x89PNG\r\n\x1a\n'):
            raise SystemExit(f'Tile is not a PNG: {url}')
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)


# First discover visible tiles, then capture again with those tiles cached.
capture()
fetch_tiles()
capture()
missing = [
    url for url in (repo / 'build/readme-tile-requests.txt').read_text().splitlines()
    if not (repo / 'build/readme-tiles' / urllib.parse.urlparse(url).path.lstrip('/')).is_file()
]
if missing:
    raise SystemExit('Some map tiles are missing; rerun to cache the new viewport.')
print('Updated five README screenshots in docs/screenshots/.')
