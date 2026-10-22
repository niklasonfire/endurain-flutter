# README screenshots

The images in `docs/screenshots/` render the production Home, server activities,
activity details, and statistics screens using the app's Android light theme.
The charts image is a second, scrolled view of activity details. Recorded tracks
come from the CC BY 4.0 GeoPrivacy Open Data dataset; see
[the source and processing notes](../../docs/screenshot-track-sources.md) and
[the fixture credits](fixtures/README.md). No account, backend, device, or Android
emulator is used.

`sample_activity.dart` reads the GPX fixtures directly. Distance is the sum of
unrounded Vincenty distances between consecutive positions within each segment;
duration is the difference between the first and last recorded timestamps.
Pace curves use GPS speed averaged over a trailing 20-second window. The source
files contain no pause state, so the displayed duration includes any stops.
No heart rate, elevation, calories, or place names are invented when absent.
Weekly totals aggregate only files in the displayed UTC week, and every activity
card uses its own route. The weekly distance goal is a demonstration setting.
The statistics model requires a numeric elevation total, so the screenshot shows
zero as the sum of supplied elevation gains, rather than a measured zero climb.
The tracks are anonymous independent records, rather than one runner's diary;
the original dataset has already generalized their dates and trimmed endpoints.

From the repository root, use the existing Flutter SDK described in
[BUILDING_LOCAL.md](../../BUILDING_LOCAL.md):

```bash
export FLUTTER_HOME=/path/to/existing/flutter
python3 tool/screenshots/generate.py
```

The SDK must include its Roboto fonts under
`engine/src/flutter/txt/third_party/fonts/` and its cached Material Icons font.
For the elevation arrow, the renderer also loads Noto Sans Symbols from
`/usr/share/fonts/truetype/noto/NotoSansSymbols-Regular.ttf`; set
`ENDURAIN_SCREENSHOT_SYMBOL_FONT` to that font's location on another machine.
The generator renders at 412 × 915 logical pixels and saves 824 × 1830 PNGs.
It loads the real fonts to avoid Flutter's widget-test placeholder typeface.
The normal test suite does not run this documentation generator.

The first pass discovers the visible OpenStreetMap tiles. Python downloads only
those tiles, keeping them in the ignored `build/readme-tiles/` directory. A second
pass captures the screens with those cached tiles. Internet access is required
only for missing tiles and Flutter dependencies; app data never comes from the
network. Keep the OpenStreetMap attribution next to the images in the README.

This is a Flutter rendering preview, not a screenshot from an Android device.
It does not show Android system bars or verify native platform integrations.
