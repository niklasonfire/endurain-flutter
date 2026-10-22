package com.endurain.endurain.updates

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.PackageInfo
import android.content.pm.Signature
import android.content.pm.SigningInfo
import android.os.Build
import android.provider.Settings
import com.endurain.endurain.activity.ActiveActivitySessionData
import com.endurain.endurain.activity.ActiveActivityStore
import com.endurain.endurain.activity.ActivityRecorderService
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.Shadows.shadowOf
import org.robolectric.annotation.Config
import org.robolectric.shadow.api.Shadow
import java.io.File

/** PackageManager is the OS boundary: archive metadata/signers are supplied by its shadow. */
@RunWith(RobolectricTestRunner::class)
@Config(sdk = [35], application = Application::class)
class UpdateInstallerTest {
    private lateinit var activity: Activity
    private lateinit var installer: UpdateInstaller
    private lateinit var apk: File
    private lateinit var store: ActiveActivityStore

    @Before
    @Suppress("DEPRECATION")
    fun setUp() {
        activity = Robolectric.buildActivity(Activity::class.java).setup().get()
        installer = UpdateInstaller(activity)
        store = ActiveActivityStore.of(activity)
        store.clear()
        apk = File(activity.cacheDir, "updates/new.apk")
        apk.parentFile!!.mkdirs()
        apk.writeText("abc")
        val packages = shadowOf(activity.packageManager)
        val installed = activity.packageManager.getPackageInfo(
            PACKAGE, PackageManager.GET_PROVIDERS or PackageManager.GET_META_DATA,
        ).apply {
            versionCode = 21
            versionName = "0.12.0"
            if (Build.VERSION.SDK_INT >= 28) {
                signingInfo = packageInfo(21).signingInfo
            } else {
                @Suppress("DEPRECATION")
                signatures = packageInfo(21).signatures
            }
        }
        packages.installPackage(installed)
        packages.setPackageArchiveInfo(apk.path, packageInfo(100042))
        packages.setCanRequestPackageInstalls(true)
    }

    @After
    fun tearDown() {
        store.clear()
        apk.parentFile!!.deleteRecursively()
        activity.finish()
    }

    @Test
    fun acceptsNewerApkWithInstalledSigningIdentity() {
        assertEquals(apk.canonicalFile, validate())
        val installed = installer.installedInfo()
        assertEquals(21L, installed["versionCode"])
        assertEquals(PACKAGE, installed["applicationId"])
        assertEquals(true, installed["supported"])
    }

    @Test
    @Config(sdk = [27])
    fun validatesSignerOnAndroidBeforeSigningInfoApi() {
        assertEquals(apk.canonicalFile, validate())
    }

    @Test
    fun rejectsFilesOutsidePrivateUpdateDirectory() {
        val outside = File(activity.cacheDir, "outside.apk").apply { writeText("abc") }
        try {
            expectError("invalid_path") { installer.validate(outside.path, 100042, PACKAGE, HASH) }
            expectError("invalid_path") {
                installer.validate(File(apk.parentFile, "../outside.apk").path, 100042, PACKAGE, HASH)
            }
        } finally {
            outside.delete()
        }
    }

    @Test
    fun rejectsModifiedDownloadBeforeOpeningInstaller() {
        apk.writeText("tampered")
        expectError("integrity_error") { validate() }
        assertNull(shadowOf(activity).nextStartedActivity)
    }

    @Test
    fun rejectsArchiveForDifferentApplication() {
        val archive = packageInfo(100042).apply { packageName = "another.application" }
        shadowOf(activity.packageManager).setPackageArchiveInfo(apk.path, archive)
        expectError("package_mismatch") { validate() }
    }

    @Test
    fun rejectsManifestForDifferentApplication() {
        expectError("package_mismatch") { installer.validate(apk.path, 100042, "another.application", HASH) }
    }

    @Test
    fun rejectsVersionDifferentFromManifestAndDowngrades() {
        shadowOf(activity.packageManager).setPackageArchiveInfo(apk.path, packageInfo(100041))
        expectError("version_mismatch") { validate() }
        shadowOf(activity.packageManager).setPackageArchiveInfo(apk.path, packageInfo(21))
        expectError("version_mismatch") { installer.validate(apk.path, 21, PACKAGE, HASH) }
        shadowOf(activity.packageManager).setPackageArchiveInfo(apk.path, packageInfo(20))
        expectError("version_mismatch") { installer.validate(apk.path, 20, PACKAGE, HASH) }
    }

    @Test
    fun rejectsDifferentOrMissingSigningIdentity() {
        shadowOf(activity.packageManager).setPackageArchiveInfo(apk.path, packageInfo(100042, "040506"))
        expectError("signature_mismatch") { validate() }
        val unsigned = packageInfo(100042).apply { signingInfo = null }
        shadowOf(activity.packageManager).setPackageArchiveInfo(apk.path, unsigned)
        expectError("signature_mismatch") { validate() }
    }

    @Test
    fun deniedSourcePermissionOpensAppSpecificSettingsAndIsRechecked() {
        val packages = shadowOf(activity.packageManager)
        packages.setCanRequestPackageInstalls(false)
        assertFalse(installer.canInstall())
        installer.requestInstallPermission()
        val settings = shadowOf(activity).nextStartedActivity
        assertEquals(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, settings.action)
        assertEquals("package:$PACKAGE", settings.data.toString())
        expectError("permission_denied") { installer.launch(validate()) }
        packages.setCanRequestPackageInstalls(true)
        assertTrue(installer.canInstall())
    }

    @Test
    fun launchesOnlyReadGrantedContentUriInSystemInstaller() {
        installer.launch(validate())
        val intent = shadowOf(activity).nextStartedActivity
        assertEquals(Intent.ACTION_VIEW, intent.action)
        assertEquals("application/vnd.android.package-archive", intent.type)
        assertEquals("content", intent.data!!.scheme)
        assertEquals("$PACKAGE.updates", intent.data!!.authority)
        assertEquals(Intent.FLAG_GRANT_READ_URI_PERMISSION, intent.flags)
    }

    @Test
    fun recordingStartedDuringVerificationBlocksInstaller() {
        val validated = validate()
        for (status in listOf("recording", "paused", "stopping")) {
            store.saveSession(ActiveActivitySessionData(
                localSessionId = "recording", activityType = "ride", status = status,
                startedAt = "2026-10-22T10:00:00.000Z",
            ))
            expectError("recording_active") { installer.launch(validated) }
        }
        assertNull(shadowOf(activity).nextStartedActivity)
    }

    @Test
    fun completedSessionMustBeDurablyFinalizedBeforeInstallation() {
        store.saveSession(ActiveActivitySessionData(
            localSessionId = "finalizing", activityType = "ride", status = "completed",
            startedAt = "2026-10-22T10:00:00.000Z",
            endedAt = "2026-10-22T11:00:00.000Z",
        ))
        expectError("recording_active") { installer.launch(validate()) }
        // The recorder's discard/acknowledge call clears this durable store after GPX save.
        store.clear()
        installer.launch(validate())
        assertEquals(Intent.ACTION_VIEW, shadowOf(activity).nextStartedActivity.action)
    }

    @Test
    fun liveRecorderServiceBlocksInstallerEvenWithoutSession() {
        val controller = Robolectric.buildService(ActivityRecorderService::class.java).create()
        try {
            expectError("recording_active") { installer.launch(validate()) }
        } finally {
            controller.destroy()
        }
    }

    private fun validate() = installer.validate(apk.path, 100042, PACKAGE, HASH)

    @Suppress("DEPRECATION")
    private fun packageInfo(code: Int, signer: String = "010203") = PackageInfo().apply {
        packageName = PACKAGE
        versionName = "0.12.0"
        versionCode = code
        if (Build.VERSION.SDK_INT >= 28) {
            signingInfo = Shadow.newInstanceOf(SigningInfo::class.java).also {
                shadowOf(it).setSignatures(arrayOf(Signature(signer)))
            }
        } else {
            signatures = arrayOf(Signature(signer))
        }
    }

    private fun expectError(code: String, action: () -> Unit) {
        try {
            action()
            fail("Expected $code")
        } catch (error: UpdateInstallException) {
            assertEquals(code, error.code)
        }
    }

    private companion object {
        const val PACKAGE = "com.endurain.endurain.local"
        // Published SHA-256 test vector for the bytes 'abc'.
        const val HASH = "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad"
    }
}
