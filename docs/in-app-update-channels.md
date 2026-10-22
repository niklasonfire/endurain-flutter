# Vorschlag: In-App-Updates über GitHub Releases

Stand: 22. Oktober 2026. Recherche und Umsetzungsvorschlag; App und CI wurden noch nicht geändert. Ziel ist zunächst der direkt als APK verteilte Android-Fork `niklasonfire/endurain-flutter`.

## Empfehlung und Bedienung

Unter **Einstellungen → App-Updates** gibt es:

- Installierte Version einschließlich Android-Buildnummer und Build-Kanal.
- Auswahl **Stable** oder **Nightly**, lokal gespeichert; Stable als Standard.
- **Nach Updates suchen**, mit Zeitpunkt der letzten erfolgreichen Prüfung.
- Bei einem neueren Build: Version, Datum, Änderungen, Downloadgröße und **Herunterladen**.
- Downloadfortschritt und Abbrechen; anschließend **Installieren**, das den Android-Systeminstaller öffnet.

Keine Hintergrundprüfung in der ersten Version. Der Kanalwechsel startet weder Download noch Installation. Netzwerkfehler, GitHub-Limit, fehlendes Release und „aktuell“ erhalten unterschiedliche Zustände. Ein fehlendes Release im gewählten Kanal ist insbesondere kein Grund, stillschweigend den anderen Kanal zu verwenden. Während einer laufenden oder pausierten Aktivitätsaufzeichnung ist die Installation gesperrt: Ein Paketupdate kann den App-Prozess beenden. Nach Rückkehr aus dem Installer wird die tatsächlich installierte Version neu gelesen; das Öffnen des Installers allein zählt nicht als Erfolg.

## Was Wavio bereits macht

Das gesuchte Projekt ist [Joel-Mercier/wavio](https://github.com/Joel-Mercier/wavio), ein Expo-/React-Native-Musikplayer. Recherchierter Quellstand: `afd7fba6227fec124bc9ee8cfd03c34f1dc57bab`.

Die [Update-Einstellungen](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/components/settings/sections/UpdatesSection.tsx), der [Update-Hook](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/hooks/useAppUpdate.ts) und der [Dialog](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/components/update/UpdateAvailableDialog.tsx) zeigen den passenden Ablauf: manuelle Prüfung, optionaler automatischer Check beim Start mit sechs Stunden Abstand, Änderungsnotizen, Fortschritt, Abbrechen und Installation. Automatische Prüfung wäre bei uns eine spätere Erweiterung.

Wavio verwendet im [GitHub-Client](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/services/appUpdate/github.ts) ausschließlich `/releases/latest`. Der [Versionsvergleich](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/services/appUpdate/version.ts) wertet Major/Minor/Patch aus und ignoriert Suffixe. Einen Stable-/Nightly-Umschalter liefert diese Implementierung nicht. Für aufeinanderfolgende Builds unter demselben Tag brauchen wir eine eigene Erkennung über `versionCode`.

Wavios [Downloader](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/services/appUpdate/download.ts) prüft die Dateigröße, enthält aber keine explizite kryptografische Prüfsummenprüfung. Bei uns soll SHA-256 hinzukommen. Die [Installation](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/services/appUpdate/install.ts) verwendet eine Content-URI und den Systeminstaller. Die [Distributionskonfiguration](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/config/distribution.ts) trennt GitHub- und Store-Builds.

Wavios [GitHub-Workflows](https://github.com/Joel-Mercier/wavio/tree/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/.github/workflows) enthalten Tests und Typechecks, keinen entsprechenden Zwei-Kanal-Publisher. APK-Builds sind in [Expo EAS](https://github.com/Joel-Mercier/wavio/blob/afd7fba6227fec124bc9ee8cfd03c34f1dc57bab/apps/mobile/eas.json) konfiguriert. Wir übernehmen das Bedienmuster und implementieren es passend zur bestehenden Flutter-/Android-CI.

## Upstream-Check und lokaler Stand

Geprüft: offene und geschlossene Issues, offene und relevante geschlossene PRs sowie der aktuelle Default-Branch `main` von `endurain-project/endurain-flutter`, HEAD `346e13e3102819b19daa5d08402cc1abf966b62b`. Bei der Suche nach Updater, In-App-Updates und Nightly wurde keine fertige Lösung oder passende offene PR gefunden. Der aktuelle [Android-Workflow](https://github.com/endurain-project/endurain-flutter/blob/346e13e3102819b19daa5d08402cc1abf966b62b/.github/workflows/build-android-apk.yml) baut Release-APKs, implementiert aber keinen App-Updater.

- [Issue #1: Release](https://github.com/endurain-project/endurain-flutter/issues/1) ist geschlossen/completed; betrifft APK-Verfügbarkeit, keine integrierte Update-Funktion.
- [Issue #25: Prerelease-Markierung](https://github.com/endurain-project/endurain-flutter/issues/25) ist geschlossen/completed. Obtainium hatte einen Beta-Build auf einem stabilen Server installiert. Der [Maintainer-Kommentar](https://github.com/endurain-project/endurain-flutter/issues/25#issuecomment-6314293191) schließt die Anfrage wegen des inzwischen erschienenen stabilen Servers; er belegt keine implementierte Kanaltrennung. Konsequenz: Nightly ausdrücklich als Prerelease behandeln, Stable niemals automatisch mit Beta-Builds vermischen. Ein stabiler App-Kanal allein garantiert keine Kompatibilität mit jeder Serverversion; bekannte Anforderungen gehören in die Release-Notizen.

Lokaler Ausgangsstand nach `git fetch origin`: `origin/main` bei `de91a23f254bfb14f1946d838445baa36d71711c`. Das Fork-Repository hatte zum Recherchezeitpunkt keine veröffentlichten GitHub-Releases ([Abfrage](https://api.github.com/repos/niklasonfire/endurain-flutter/releases)).

Die vorhandene [Build-CI](../.github/workflows/build-android-apk.yml) unterstützt manuelle Builds und veröffentlichte Releases, persistente Signierung und Zertifikatsprüfung. Manuelle Builds landen als Actions-Artefakt, Release-Builds als `app-release.apk` am Release. Der Release-Pfad erwartet `vX.Y.Z+BUILD` und dieselbe Version in `pubspec.yaml`; ein Tag `nightly` würde aktuell abgelehnt. Der Fork verwendet einen Self-hosted-Runner, [lokale CI](../.github/workflows/ci-self-hosted.yml) prüft Formatierung, Analyse, Coverage, native Android-Tests und einen Debug-Build. Dieser Debug-Build ist kein veröffentlichungsfähiger Update-Build.

## Kanäle und Release-Vertrag

| Kanal | GitHub-Veröffentlichung | Abfrage der App |
| --- | --- | --- |
| Stable | Unveränderliches Release mit Tag `vX.Y.Z+CODE`, `prerelease: false` | `/repos/niklasonfire/endurain-flutter/releases/latest` |
| Nightly | Rollendes Release mit Tag `nightly`, `prerelease: true`, nicht als Latest markieren | `/repos/niklasonfire/endurain-flutter/releases/tags/nightly` |

Damit gibt es zwei auswählbare Kanäle; Stable braucht keinen beweglichen Tag namens `release`. Versionierte Stable-Tags erhalten die nachvollziehbare Zuordnung von Quellstand und APK. Nightly bezeichnet jeweils den neuesten erfolgreich geprüften und veröffentlichten Build; „Nightly“ muss keinen nächtlichen Zeitplan bedeuten.

Die [GitHub-Releases-API](https://docs.github.com/en/rest/releases/releases) schließt Prereleases aus `/latest` aus. Ein Git-Tag allein reicht nicht: Beide Kanäle benötigen Release-Objekte mit Assets. Öffentliche Releases können ohne App-Token gelesen werden. Die [anonyme Grenze von 60 Anfragen pro Stunde und IP](https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api) erfordert verständliche Fehler und Retry-Verhalten; kein eingebetteter PAT und keine Backend-Zugangsdaten an GitHub.

Jedes Release erhält ein `update.json`, erzeugt aus dem tatsächlich gebauten und geprüften APK. Vorgeschlagene Felder:

```json
{
  "schemaVersion": 1,
  "channel": "nightly",
  "versionName": "0.12.0-nightly.20261022",
  "versionCode": 100042,
  "commit": "<full git sha>",
  "builtAt": "<UTC timestamp>",
  "applicationId": "com.endurain.endurain.local",
  "minSdk": 26,
  "assets": [{
    "abi": "arm64-v8a",
    "name": "endurain-local-100042-arm64-v8a.apk",
    "size": 0,
    "sha256": "<64 hexadecimal characters>"
  }]
}
```

Das Beispiel ist ein Schemaentwurf, kein fertiges Manifest. Asset-Größe, Prüfsumme, Package-ID und Version müssen aus dem APK stammen. Die App gleicht Manifest und Release-Assets ab, prüft ABI und Android-Version und verwendet nur HTTPS-Downloads aus dem festgelegten Repository. GitHub-Redirects auf seine Asset-Infrastruktur müssen unterstützt werden. Zunächst passt arm64 zum vorhandenen Release-Build; andere Architekturen bekommen einen klaren Hinweis statt eines inkompatiblen Downloads.

Beim rollenden Nightly sind mehrere Asset-Uploads nicht atomar. Deshalb eindeutige APK-Dateinamen verwenden, APK vollständig hochladen und `update.json` zuletzt ersetzen. Während des Austauschs wird ein fehlendes Manifest als vorübergehend nicht verfügbar behandelt. Vorheriges APK zunächst behalten; die App bindet einen Download an die gelesene Buildnummer und Prüfsumme. Bei zwischenzeitlich entfernten Assets einmal neu prüfen, keine Mischinstallation. Ein fehlgeschlagener Publish darf nicht „aktuell“ melden. Wer später alle Nightlies archivieren möchte, kann zusätzliche unveränderliche Nightly-Tags einführen.

## Versionierung und bestehende Installationen

[Android](https://developer.android.com/studio/publish/versioning) verwendet den ganzzahligen `versionCode` für die Reihenfolge; niedrigere Codes können eine neuere Installation regulär nicht ersetzen. Deshalb entscheidet ausschließlich `remote.versionCode > installed.buildNumber`, nicht der Tag, das Release-Datum oder der sichtbare Versionsname. Schema, Package-ID, Kanal und Plattform müssen davor validiert sein.

Empfehlung: **ein gemeinsamer Build-Workflow** vergibt Codes für Stable und Nightly. Ein möglicher Start ist `100000 + github.run_number`, sofern dieser Wert vor Einführung nachweislich über allen ausgelieferten lokalen und CI-Codes liegt. `run_number` ist nur innerhalb desselben Workflows brauchbar: kein unabhängiger Stable-Zähler, keine Rücksetzung beim Workflow-Wechsel. Wiederholungen eines Runs veröffentlichen denselben bereits erzeugten Build oder brechen ab; ein neuer Build benötigt einen neuen Run. Kanalübergreifende Serialisierung plus Prüfung gegen bereits veröffentlichte Codes verhindert, dass ein älterer Run später einen neueren Kanalstand überschreibt. Lokale künftig verteilte Builds müssen dieselbe Nummernvergabe nutzen bzw. bewusst einen gemeinsam verwalteten höheren Code reservieren. Die Obergrenze des Android-Codes ist zu prüfen.

Nightly → Stable mit kleinerem Code zeigt „Auf nächstes Stable-Update warten“. Kein automatischer Downgrade und keine Deinstallation, die lokale Daten verlieren könnte. Ein Stable-Release nach einer Nightly wird mit höherem Code aus dem gewählten stabilen Commit gebaut. Das muss nicht der neueste Nightly-Commit sein.

Die [lokale Build-Dokumentation](../BUILDING_LOCAL.md) nennt als zuletzt gelieferten Stand `0.11.1+21`; `pubspec.yaml` allein reicht wegen der bisherigen Build-Overrides nicht zur Bestandsaufnahme. Das aktuelle Gradle-Package ist `com.endurain.endurain.local`. Beide Kanäle müssen dieses Package und die bestehende Signatur behalten. Die dokumentierte Zertifikats-SHA256 ist `3341bbf406214b746b6f893d12a353652df6c9215feb6b2e58e541c2bb9dfb6e`. Ob die CI-Secrets tatsächlich dazu passen, wurde bei dieser Recherche nicht geprüft. Vor dem ersten Publish ist genau dieser Abgleich Pflicht; ein neuer CI-Schlüssel würde bestehende Installationen nicht aktualisieren ([Android-Signierung](https://developer.android.com/studio/publish/app-signing)).

## Einbau in die App

Ein eigenes Modul unter `lib/features/updates/` bündelt Release-Auflösung, Metadatenprüfung, Versionsvergleich, Download und Installation hinter einer kleinen Interface. Die Oberfläche steuert `check(channel)`, Download/Abbruch und Installation und beobachtet eindeutige Zustände. GitHub-HTTP-Zugriff und Plattforminstallation werden injiziert, damit Fehler und Kanalwechsel ohne echtes Netzwerk oder Installer prüfbar bleiben.

- Einstieg in [SettingsScreen](../lib/features/settings/screens/settings_screen.dart), eigene Update-Seite und eigener Controller nach dem vorhandenen Screen-/Controller-Muster.
- Kanal in [AppPreferencesStore](../lib/core/services/app_preferences_store.dart); Verdrahtung in [AppServices](../lib/core/services/app_services.dart). Installierten Code über den vorhandenen [PackageInfoService](../lib/core/services/platform/package_info_service.dart) lesen; derzeit zeigt Settings nur `version`.
- Bereits vorhandene Pakete `http`, `crypto`, `path_provider`, `package_info_plus` und `url_launcher` decken Netzwerk, SHA-256, Cache und Browser-Fallback ab. Kein großes Updater-Paket erforderlich; Downloads streamen, zeitlich begrenzen, abbrechen und Teil-Dateien entfernen.
- Kleiner Android-Adapter für Installer und Berechtigung. [REQUEST_INSTALL_PACKAGES und canRequestPackageInstalls](https://developer.android.com/reference/android/content/pm/PackageManager#canRequestPackageInstalls()) plus Systemseite für die Freigabe dieser App als Installationsquelle; nach Rückkehr erneut prüfen. APK über einen eng auf das Update-Verzeichnis begrenzten [FileProvider](https://developer.android.com/reference/androidx/core/content/FileProvider) mit temporärer Leseberechtigung übergeben. Das aktuelle App-Manifest enthält diese Update-Deklarationen noch nicht.

SHA-256 erkennt beschädigte oder vermischte Downloads. Es ersetzt keinen unabhängigen Vertrauensanker: Die Android-Signatur bleibt entscheidend. Vor dem Installer möglichst Package-ID, eingebetteten Code und Signierzertifikat des heruntergeladenen APK mit der installierten App vergleichen; Android prüft die eigentliche Installation ebenfalls.

Der GitHub-Updater ist eine Fork-/Distributionsfunktion. Allgemeine Update-Logik und Tests getrennt von Fork-Repository, Kanalpolitik und Package-Konfiguration halten. Für iOS wird in dieser ersten Version keine APK-Funktion angezeigt; Store-Distribution bräuchte einen eigenen Updateweg.

## Einbindung in unsere CI

1. Die bestehende Prüfstrecke bleibt Voraussetzung. Ein Nightly entsteht nach erfolgreicher vollständiger CI auf `main`, nur bei relevanten Codeänderungen; reine Dokumentationsänderungen gemäß [CI-Klassifizierung](../.github/scripts/classify_ci_changes.py) erzeugen keinen Build. Ein grüner Sammelstatus mit übersprungenen Checks genügt nicht. Kein Signieren von PR-Code. Falls `workflow_run` genutzt wird, Repository, Event, Branch, Ergebnis, wirklich gelaufene Checks und exakten `head_sha` verifizieren; diesen SHA bauen, nicht das inzwischen weitergelaufene `main`.
2. Signieren, Version vergeben und APK-Prüfung in einen gemeinsamen Workflow für beide Kanäle ziehen. Vorhandene Zertifikatsprüfung weiterverwenden; zusätzlich Package-ID, tatsächlichen `versionCode`, ABI und SHA-256 prüfen. Build- und Publish-Läufe über beide Kanäle serialisieren; veraltete Nightly-Kandidaten vor Veröffentlichung verwerfen.
3. Nightly darf automatisch aus dem geprüften Main-Commit erscheinen. Stable wird bewusst per manuellem Workflow mit Kanal, Version und geprüftem Commit gestartet. Der Workflow erstellt nach erfolgreichem Build das versionierte Release. Den bisherigen `release: published`-Buildpfad ersetzen oder eindeutig abgrenzen, damit keine Doppel-Builds entstehen. Publikation im selben Ablauf ausführen und nicht auf einen rekursiv ausgelösten Release-Workflow bauen.
4. Zuerst signierten Build samt eindeutigem APK und Manifest vorbereiten und prüfen, dann veröffentlichen. Bei Stable Release erst mit allen Assets freigeben; bei Nightly die oben beschriebene Reihenfolge einhalten. Fehlgeschlagener Build verändert keinen vorhandenen Kanalstand. Signiermaterial in temporären Dateien nach dem Lauf entfernen; Zugang zum Signieren auf vertrauenswürdige Runs begrenzen.
5. Vorhandenen Self-hosted-Runner nutzen; kein neuer Dienst und keine zusätzlichen macOS-Ressourcen für dieses Android-Feature. APK und Metadaten sind öffentliche Release-Assets, keine kurzlebigen Actions-Artefakte. Bestehende manuelle Build-Funktion kann als unveröffentlichter Prüfmodus erhalten bleiben.

Die eigentliche Änderung lässt sich in drei fokussierte Schritte aufteilen: Release-Vertrag und gemeinsamer Publisher; manuelle Update-Seite mit Download; Android-Installer mit Berechtigungsrückkehr. Die erste APK mit Updater wird einmal über den bisherigen Weg installiert. Danach funktionieren künftige Updates aus der App.

## Verifikation bei der Umsetzung

Gezielte Tests für kanalrichtige Auswahl, wechselnde Nightly-Metadaten, höhere/gleiche/niedrigere Codes, fehlende Assets, 404/403/Timeout, Prüfsummenfehler, Downloadabbruch, veraltete Check-Antwort nach Kanalwechsel und gesperrte Installation bei aktiver Aufnahme. CI-Tests für beide Triggerpfade, übersprungene Prüfungen, veraltete Runs, monotone Codes und Paket-/Zertifikatsabweichungen. Auf einem Android-Gerät: bisheriges lokales APK → Nightly → neueres Stable mit erhaltenen Einstellungen und Aufzeichnungen, verweigerte Installationsfreigabe, Rückkehr aus Systemeinstellungen und abgebrochener Installer. Zusätzlich vollständige Checks gemäß Repository-Vorgaben vor integrierter Auslieferung.
