# Endurain Local für Android

Die signierte Release-APK liegt nach dem Build im Workspace unter `artifacts/`. Sie benötigt Android 8.0 oder neuer. Paketkennung `com.endurain.endurain.local`, Appname **Endurain Local**: Installation parallel zur ursprünglichen Endurain-App, mit eigenem lokalen Speicher und eigener Anmeldung.

## Update von 0.9.2+16 auf 0.10.0+17

1. Die neue `endurain-local-0.10.0+17-release.apk` auf das Gerät kopieren und öffnen; bei Bedarf die Installation aus dieser Quelle erlauben.
2. Androids **Aktualisieren** bestätigen. **Endurain Local nicht deinstallieren und keine Appdaten löschen**: Die vorhandene Anmeldung und lokale Daten sollen beim Update erhalten bleiben. Die ursprüngliche Endurain-App bleibt parallel installiert.
3. In **Aktivitäten** eine Aktivität öffnen: Graphen nutzen vorhandene Servermessdaten, Runden die gelieferten Rundendaten. Fehlende Daten werden als solche angezeigt. Unter **Statistik** Woche, Monat oder Jahr und optional eine Sportart wählen; sichtbar sind Strecke, Zeit, Anzahl und Höhenmeter.

Die neue APK muss dieselbe Paketkennung und denselben Signaturschlüssel wie die bereits installierte lokale App tragen; der Buildnachweis dokumentiert diesen Vergleich. Lehnt Android das Update ab, die bestehende App nicht vorsorglich entfernen.

Für eine Erstinstallation **Endurain Local** starten, die eigene Serveradresse eingeben und anmelden. Appdaten und Sitzung werden nicht aus der ursprünglichen Endurain-App übernommen. Für Kartenkacheln ist eine Netzverbindung erforderlich.

Die Serveransichten lesen Aktivitäten und bearbeiten oder löschen sie nicht. Die vorhandenen Aufnahme-, Upload- und Health-Funktionen haben ihre bisherigen Berechtigungsdialoge; für die reine Serverliste ist keine Standortfreigabe nötig.

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

## Verifizierter Updatebuild vom 18. Oktober 2026

Release **0.10.0+17** erfolgreich aus Produktivstand `1649714` gebaut; SHA256 `cf93291777bfd2f505b9d85b6323e0e06c92c716473ced8c9db61e670e077bdf`. Paketkennung und Signatur stimmen mit 0.9.2+16 überein; Versioncode 17 ist höher als 16. Release-/SSO-/Provider-Metadaten und unveränderte Berechtigungen wurden aus der fertigen APK geprüft. Der Nachtrag `961f584` vervollständigt Lokalisierungskataloge mit nachgewiesen identischen Runtime-Texten.

Die vorherige APK bleibt erhalten. Im Artefaktordner prüft `sha256sum -c SHA256SUMS` beide Dateien erfolgreich. Analyzer 0, Format 458/0 und Coverage 90,74% mit bestandenem CI-Gate; finale vollständige Flutter-Suite nach dem Lokalisierungsfix **1518 bestanden,1 bestehender Apple-only-Skip,0 Fehler**. Native Quellen sind unverändert; die frühere 107er Nativeprüfung wurde nicht wiederholt. Gerätetest und privater Serverzugriff wurden nicht durchgeführt.
