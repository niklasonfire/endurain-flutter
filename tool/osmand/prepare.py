#!/usr/bin/env python3
"""Fetch pinned OsmAnd sources and apply the tracked PoC overlay, idempotently."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import urllib.request
import zipfile

ROOT = Path(__file__).resolve().parents[2]
POC = ROOT / 'poc/osmand'
MANIFEST = json.loads((POC / 'sources.json').read_text())


def run(*args, cwd=None):
    subprocess.run(args, cwd=cwd, check=True)


def checkout(name, path):
    spec = MANIFEST[name]
    if not path.exists():
        run('git', 'clone', '--depth', '1', '--branch', spec['ref'], spec['url'], str(path))
    actual = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=path, text=True).strip()
    if actual != spec['revision']:
        run('git', 'fetch', '--depth', '1', 'origin', spec['revision'], cwd=path)
        run('git', 'checkout', '--detach', spec['revision'], cwd=path)


checkout('osmand', POC / 'upstream')
checkout('resources', POC / 'resources')
upstream = POC / 'upstream'
# Only restore tracked upstream files changed by this script; no wholesale clean.
patched = ['settings.gradle', 'build.gradle', 'gradle/wrapper/gradle-wrapper.properties', 'versions.gradle', 'OsmAnd-shared/build.gradle.kts',
           'OsmAnd/AndroidManifest.xml', 'OsmAnd/build.gradle', 'OsmAnd/src/net/osmand/plus/Version.java', 'OsmAnd/res/values/strings.xml']
run('git', 'restore', '--source=HEAD', '--', *patched, cwd=upstream)
(upstream / 'settings.gradle').write_text("include ':OsmAnd', ':OsmAnd-java', ':OsmAnd-api', ':OsmAnd-shared'\ngradle.ext.java_shared_conf = ''\n")
build = upstream / 'build.gradle'
build.write_text(build.read_text().replace("'2.1.10'", "'2.4.0'").replace('com.android.tools.build:gradle:8.7.3', 'com.android.tools.build:gradle:8.13.2').replace("classpath 'com.android.tools.build:gradle:8.13.2'", "classpath 'com.android.tools.build:gradle:8.13.2'\n        classpath 'com.android.tools:r8:9.1.31'"))
wrapper = upstream / 'gradle/wrapper/gradle-wrapper.properties'
wrapper.write_text(wrapper.read_text().replace('gradle-8.9-bin.zip', 'gradle-8.13-bin.zip'))
versions = upstream / 'versions.gradle'
versions.write_text(versions.read_text().replace('osmand_compileSdk = 35', 'osmand_compileSdk = 36').replace('"35.0.0"', '"36.0.0"'))
shared = upstream / 'OsmAnd-shared/build.gradle.kts'
shared.write_text(shared.read_text().replace('kotlin {', 'kotlin {\n\tcompilerOptions {\n\t\tlanguageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_1)\n\t\tapiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_1)\n\t}').replace('compileSdk = 35', 'compileSdk = 36\n\tbuildToolsVersion = "36.0.0"').replace('jvmTarget.set(JvmTarget.JVM_17)', 'jvmTarget.set(JvmTarget.JVM_17)\n\t\t\tlanguageVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_1)\n\t\t\tapiVersion.set(org.jetbrains.kotlin.gradle.dsl.KotlinVersion.KOTLIN_2_1)'))
strings = upstream / 'OsmAnd/res/values/strings.xml'
strings.write_text(strings.read_text().replace('<resources>', '<resources>\n    <string name="endurain_return_to_frontend">Endurain</string>', 1))
manifest = upstream / 'OsmAnd/AndroidManifest.xml'
xml = manifest.read_text().replace('android:authorities="net.osmand.plus.fileprovider"', 'android:authorities="${applicationId}.fileprovider"')
start = xml.index('\n\t\t\t<intent-filter>\n\t\t\t\t<action android:name="android.intent.action.MAIN"')
end = xml.index('</intent-filter>', start) + len('</intent-filter>')
xml = xml[:start] + xml[end:]
health_permissions = ['READ_EXERCISE', 'READ_DISTANCE', 'READ_TOTAL_CALORIES_BURNED', 'READ_STEPS', 'READ_HEART_RATE', 'READ_EXERCISE_ROUTES', 'READ_HEALTH_DATA_HISTORY']
xml = xml.replace('<application android:allowBackup="true"', '<application android:allowBackup="false"')
xml = xml.replace('<supports-screens', '\n'.join(f'<uses-permission android:name="android.permission.health.{permission}" />' for permission in health_permissions) + '\n<supports-screens')
xml = xml.replace('<queries>', '<queries><package android:name="com.google.android.apps.healthdata" /><intent><action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" /></intent>')
xml = xml.replace('</application>', '''
        <activity android:name="net.osmand.plus.endurain.HealthPermissionsRationaleActivity" android:exported="true">
            <intent-filter><action android:name="androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" /></intent-filter>
        </activity>
        <activity-alias android:name="com.endurain.osmand.poc.ViewPermissionUsageActivity"
            android:exported="true" android:targetActivity="net.osmand.plus.endurain.HealthPermissionsRationaleActivity"
            android:permission="android.permission.START_VIEW_PERMISSION_USAGE">
            <intent-filter><action android:name="android.intent.action.VIEW_PERMISSION_USAGE" /><category android:name="android.intent.category.HEALTH_PERMISSIONS" /></intent-filter>
        </activity-alias>
        <meta-data android:name="flutterEmbedding" android:value="2" />
        <activity android:name="net.osmand.plus.endurain.EndurainFlutterActivity"
            android:exported="true" android:launchMode="singleTop"
            android:theme="@style/Theme.AppCompat.DayNight.NoActionBar"
            android:hardwareAccelerated="true" android:windowSoftInputMode="adjustResize"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.VIEW" />
                <category android:name="android.intent.category.DEFAULT" />
                <category android:name="android.intent.category.BROWSABLE" />
                <data android:scheme="endurain" android:host="osmand-auth" android:pathPrefix="/sso/callback" />
            </intent-filter>
        </activity>
    </application>''')
manifest.write_text(xml)
version = upstream / 'OsmAnd/src/net/osmand/plus/Version.java'
version.write_text(version.read_text().replace('app.getPackageName().equals(FULL_VERSION_NAME)', '(app.getPackageName().equals(FULL_VERSION_NAME) || app.getPackageName().equals("com.endurain.osmand.poc"))').replace('getAppName(app).contains("~")', '(getAppName(app).contains("~") || app.getPackageName().equals("com.endurain.osmand.poc"))'))
config = upstream / 'OsmAnd/build.gradle'
config.write_text(config.read_text() + '\napply from: rootProject.file("../host.gradle")\n')
for patch in sorted(POC.glob('bridge-*.patch')):
    run('git', 'apply', str(patch), cwd=upstream)
overlay = POC / 'overlay'
if overlay.exists():
    shutil.copytree(overlay, upstream, dirs_exist_ok=True)

native = MANIFEST['native']
archive = POC / 'downloads' / native['file']
archive.parent.mkdir(exist_ok=True)
if not archive.exists():
    temporary = archive.with_suffix('.download')
    urllib.request.urlretrieve(native['url'], temporary)
    temporary.rename(archive)
digest = hashlib.file_digest(archive.open('rb'), 'sha256').hexdigest()
if digest != native['sha256']:
    raise SystemExit(f'Native APK checksum mismatch: {digest}')
# Legacy JNI is retained verbatim from the official same-version APK. OpenGL
# dependencies remain the upstream declared OsmAnd 5.3 Ivy AAR artifacts.
with zipfile.ZipFile(archive) as apk:
    for lib in ('libosmand.so', 'libc++_shared.so'):
        entry = f"lib/{native['abi']}/{lib}"
        target = upstream / 'OsmAnd/libs' / native['abi'] / lib
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(apk.read(entry))
sdk = os.environ.get('ANDROID_SDK_ROOT') or os.environ.get('ANDROID_HOME')
if sdk:
    (upstream / 'local.properties').write_text(f'sdk.dir={sdk}\n')
print(f'Prepared OsmAnd {MANIFEST["osmand"]["revision"]}; native {digest}')
