# Screenshot track sources

Checked 2026-10-22 against the dataset publisher and the downloaded archive.

## Selected source

The README screenshots use three recorded, anonymised GPS trajectories from **Geoprivacy Open Data 2023/11**, published by the Finnish Geospatial Research Institute, Department of Geoinformatics and Cartography, National Land Survey of Finland. Volunteers donated activity recordings and separately opted into publication of privacy-protected tracks. The dataset describes its `running_` prefix as an automatic classification based on average speed, which can be wrong: these are running-classified recordings, not independently verified races or a single athlete’s training diary. [Dataset and provenance](https://doi.org/10.23729/a86e508a-8798-4720-9b06-0b9db8fc6b8e), [publisher metadata API](https://etsin.fairdata.fi/api/dataset/e79bdb17-ab1a-4a66-b195-cdd117e62934).

The dataset declares **CC BY 4.0**, and its linked terms additionally prohibit reidentification, attribute linkage to natural persons, and uses that harm contributors. This screenshot use displays anonymous activity data without attempting identification. Preserve the source’s additional privacy restrictions when reusing these fixtures. [Dataset terms](https://geoprivacy.fi/open-data-terms-of-use/), [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

The source privacy process truncates sensitive locations and changes timestamps. It preserves the month and weekday, generalises start time to a six-hour period, and translates subsequent timestamps relative to the modified start. Relative point intervals therefore survive; displayed calendar dates are anonymised dates. Separate files must not be interpreted as belonging to one person or an actual shared training week. [Privacy mechanisms](https://geoprivacy.fi/privacy-mechanisms/), [platform terms, anonymisation definition](https://geoprivacy.fi/tos/).

## Local fixtures

Files are byte-identical archive members; only local filenames changed. They contain WGS84 latitude/longitude and UTC timestamps. No elevation, heart rate, cadence, power, calories, or athlete identity is supplied, so the screenshot generator must not invent those measurements. Distances, duration and pace are calculated from the retained coordinates and time intervals.

| Local file | Original archive member | Stored UTC start | Points | Approx. distance | Recorded duration |
| --- | --- | --- | ---: | ---: | ---: |
| `tool/screenshots/fixtures/Running_01.gpx` | `running_add2b9a.gpx` | 2023-06-01 09:00:00.790 | 620 | 7.471 km | 32:16.005 |
| `tool/screenshots/fixtures/Running_02.gpx` | `running_4b8ade3.gpx` | 2023-06-02 09:00:00.766 | 354 | 4.198 km | 18:34.022 |
| `tool/screenshots/fixtures/Running_03.gpx` | `running_16ca808.gpx` | 2023-06-03 09:00:00.112 | 490 | 5.896 km | 28:01.004 |

SHA-256:

```text
916c79d18637dcb068562d25018a1e53f00d7cbcd85b2e255daeb717447f8412  Running_01.gpx
79587e764c765f7516690b40ac8583b649fec0b6455afc972a9da70d21823cba  Running_02.gpx
0ef4978e7f8f289fc80520f8b2747df82d083091fb49af3f816c4f7f70cfa55d  Running_03.gpx
```

## Download and verification

The publisher’s [file metadata API](https://metax-legacy.fairdata.fi/rest/v2/datasets/e79bdb17-ab1a-4a66-b195-cdd117e62934/files) identifies `Geoprivacy_open_data_202311.zip`, 128,586,041 bytes, SHA-256 `249fe9b21e7cfc9f43edf394f55337f4d5a893f94c6d6d83508cd76373e13498`. The downloaded archive matched that checksum. It contains 64 `running_` GPX files.

Download from the dataset’s Files tab, or request its temporary public file URL with:

```http
POST https://etsin.fairdata.fi/api/download/authorize
Content-Type: application/json

{"cr_id":"e79bdb17-ab1a-4a66-b195-cdd117e62934","file":"/Geoprivacy_open_data_202311.zip"}
```

Download the JSON response’s `url`; it expires and should not be committed. This is the same public download flow used by the [publisher’s frontend](https://github.com/CSCfi/fairdata-etsin-qvain/blob/master/etsin_finder/frontend/js/components/etsin/Dataset/data/idaResources/download.js).

## Attribution

Mäkinen, V., Brauer, A. and Oksanen, J. (2023). *GeoPrivacy platform*, https://geoprivacy.fi. Dataset: *Geoprivacy Open Data 2023/11*, https://doi.org/10.23729/a86e508a-8798-4720-9b06-0b9db8fc6b8e. CC BY 4.0, with the source’s additional privacy restrictions. Original GPX data unchanged; filenames renamed and activity metrics derived for screenshots.

The publisher asks users to acknowledge: “We made use of geospatial data provided by the Open Geospatial Information Infrastructure for Research (Geoportti, urn:nbn:fi:research-infras-2016072513) funded by the Academy of Finland, CSC – IT Center for Science, and other Geoportti consortium members.” [Requested citation and acknowledgement](https://etsin.fairdata.fi/api/dataset/e79bdb17-ab1a-4a66-b195-cdd117e62934).

## Alternatives investigated

- [CC-GPX](https://github.com/ilyankou/cc-gpx) collects GPX and descriptions from Common Crawl. Its code license does not establish permission from each original track owner; it was not selected.
- [HikeAlong open data](https://hikealongtours.com/data/) explicitly licenses watch-recorded GPX under CC BY 4.0, with coordinates, elevation and UTC times. These are hikes rather than runs, so they were not selected.
- [Entalpi Kona 2022](https://github.com/entalpi-no/kona-2022) contains professional runners’ recorded race data but uses CC BY-NC 4.0; it was not selected for the requested freely reusable fixture.
