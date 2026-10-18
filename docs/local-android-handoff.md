# Endurain Local für Android

Die signierte Release-APK liegt nach dem Build im Workspace unter `artifacts/`. Sie benötigt Android 8.0 oder neuer. Paketkennung `com.endurain.endurain.local`, Appname **Endurain Local**: Installation parallel zur ursprünglichen Endurain-App, mit eigenem lokalen Speicher und eigener Anmeldung.

## Installation und Anmeldung

1. APK auf das Android-Gerät kopieren und öffnen; bei Bedarf die Installation aus dieser Quelle erlauben. Die ursprüngliche App muss nicht deinstalliert werden.
2. **Endurain Local** starten, die eigene Endurain-Serveradresse eingeben und einmal anmelden. Bestehende Zugangsdaten verwenden; Appdaten und Sitzung werden nicht aus der ursprünglichen App übernommen.
3. Im neuen Tab **Aktivitäten** die Liste laden, filtern und eine Aktivität öffnen. Die Detailansicht zeigt Kennzahlen und bei vorhandenen GPS-Daten die Streckenkarte. Fehlende Routen und Netzwerkfehler werden angezeigt. Für Kartenkacheln ist eine Netzverbindung erforderlich.

Der neue Tab liest Serveraktivitäten und bearbeitet oder löscht sie nicht. Die vorhandenen Aufnahme-, Upload- und Health-Funktionen der Basis-App sind weiterhin vorhanden und haben ihre bisherigen Berechtigungsdialoge; für die reine Serverliste ist keine Standortfreigabe nötig. API-Zugriff und Darstellung sind über ein austauschbares Repository getrennt.

## Lokal erneut bauen und aktualisieren

Aus dem Quellcodeverzeichnis:

```bash
cd endurain-flutter
./tool/build-local-android.sh
```

Die hier vorbereitete Flutter-/Android-Toolchain wird automatisch verwendet. Ausgabe: `endurain-flutter/build/app/outputs/flutter-apk/app-release.apk`. Ein Update derselben Paketkennung erfordert denselben Signaturschlüssel. `android/.local-signing/local.jks` und `android/key.properties` liegen nur lokal und sind ignoriert; beide sicher separat aufbewahren. Sie gehören weder in ein Quellcodearchiv noch in eine Veröffentlichung. Die APK enthält nur die öffentliche Signatur, keinen privaten Schlüssel. Die lokale Buildanleitung und Toolchainpfade stehen zusätzlich in `LOCAL_BUILD_STATUS.md` im Workspace.

SSO verwendet den separaten Callback `endurain://local-auth/sso/callback`. Der geprüfte lokale Backend-Quellstand erlaubt das Schema `endurain`; für diesen Stand ist keine Serveranpassung nötig. Die Anmeldung am privaten Server und die tatsächliche Weiterleitung zwischen zwei installierten Apps wurden hier nicht auf einem Gerät erprobt.

## Prüfung und Grenzen

Die exakten Quellcommits, SHA256, APK-Version, Signatur und ausgeführten Prüfungen werden in `artifacts/BUILD-NACHWEIS.md` im Workspace festgehalten. Es ist kein Android-Gerät angeschlossen. Installation, Darstellung auf echter Hardware, Anmeldung am privaten Server, GPS/Health Connect und SSO mit beiden Apps bleiben daher manuelle Prüfungen. Automatisierte Tests verwenden lokale Testdaten. Es wurden keine privaten Serverdaten benötigt und keine Artefakte hochgeladen.

## Verifizierter lokaler Build vom 18. Oktober 2026

Produktiver Quellstand `51013ef16285ae4f469f5bda9e191a35847d76c1`, anschließend Prüfcommit `6bebb1d` ohne Appcodeänderung. Release **0.9.2+16** erfolgreich; SHA256 `54e42bfe97689e8201c9a104d87ded7038f2b43f7ced644989ac2e86ad310b5e`. Paketname, Launcher, Health-Komponenten, separate SSO-/Provider-Ziele und Release-Signatur wurden aus der fertigen APK geprüft.

Flutter: **1495 bestanden, 1 bestehender Apple-only-Skip**, Analyzer ohne Issues, Format443/0, Coverage90,52% mit bestandenem CI-Gate. Native Android-Suite: **107 bestanden**, keine Fehler/Skips. APK und Prüfnachweise stehen im Workspace unter `artifacts/`. Gerätetest und Anmeldung am privaten Server wurden nicht durchgeführt.
