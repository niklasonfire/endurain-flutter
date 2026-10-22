package com.endurain.endurain.updates

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import androidx.core.content.FileProvider
import com.endurain.endurain.activity.ActiveActivityStore
import com.endurain.endurain.activity.ActiveActivitySessionData
import com.endurain.endurain.activity.ActivityRecorderService
import java.io.File
import java.security.MessageDigest

class UpdateInstallException(val code: String, message: String) : RuntimeException(message)

/** The native trust boundary for downloaded APKs and the Android installer. */
class UpdateInstaller(private val activity: Activity) {
    private val packages get() = activity.packageManager

    fun installedInfo(): Map<String, Any> {
        val installed = installedPackage()
        return mapOf(
            "applicationId" to activity.packageName,
            "versionName" to (installed.versionName ?: ""),
            "versionCode" to versionCode(installed),
            "supportedAbis" to Build.SUPPORTED_ABIS.toList(),
            "sdkInt" to Build.VERSION.SDK_INT,
            "supported" to (activity.packageName == APPLICATION_ID),
        )
    }

    fun canInstall(): Boolean =
        Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packages.canRequestPackageInstalls()

    fun requestInstallPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && !canInstall()) {
            activity.startActivity(
                Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, Uri.parse("package:${activity.packageName}")),
            )
        }
    }

    /** Does file I/O; callers run validation off the UI thread. */
    fun validate(apkPath: String, expectedCode: Long, expectedPackage: String, expectedSha256: String): File {
        val directory = File(activity.cacheDir, "updates").canonicalFile
        val apk = File(apkPath).canonicalFile
        if (apk.parentFile != directory || !apk.isFile || apk.extension != "apk") {
            fail("invalid_path", "The APK must be a file in the private update cache.")
        }
        if (expectedPackage != APPLICATION_ID || expectedPackage != activity.packageName) {
            fail("package_mismatch", "The update targets a different application.")
        }
        if (!expectedSha256.matches(Regex("[a-fA-F0-9]{64}"))) {
            fail("integrity_error", "The update checksum is invalid.")
        }
        val digest = MessageDigest.getInstance("SHA-256")
        apk.inputStream().use { input ->
            val buffer = ByteArray(64 * 1024)
            while (true) {
                val count = input.read(buffer)
                if (count < 0) break
                digest.update(buffer, 0, count)
            }
        }
        val expectedDigest = expectedSha256.chunked(2).map { it.toInt(16).toByte() }.toByteArray()
        if (!MessageDigest.isEqual(digest.digest(), expectedDigest)) {
            fail("integrity_error", "The downloaded APK checksum does not match.")
        }
        val archive = packages.getPackageArchiveInfo(apk.path, signatureFlags())
            ?: fail("invalid_apk", "Android could not read the downloaded APK.")
        if (archive.packageName != expectedPackage) {
            fail("package_mismatch", "The APK package differs from the update metadata.")
        }
        val installed = installedPackage()
        if (versionCode(archive) != expectedCode || expectedCode <= versionCode(installed)) {
            fail("version_mismatch", "The APK version is different or is not newer than the installed app.")
        }
        val archiveSigners = signers(archive)
        val installedSigners = signers(installed)
        if (archiveSigners.isEmpty() || installedSigners.isEmpty() || archiveSigners != installedSigners) {
            fail("signature_mismatch", "The APK was not signed by the installed app's signing identity.")
        }
        return apk
    }

    /** A successful launch does not mean that the user installed the update. */
    fun launch(apk: File) {
        val status = ActiveActivityStore.of(activity).loadSession()?.status
        if (ActivityRecorderService.hasActiveService() || status in setOf(
                ActiveActivitySessionData.STATUS_RECORDING,
                ActiveActivitySessionData.STATUS_PAUSED,
                ActiveActivitySessionData.STATUS_STOPPING,
                // Cleared by acknowledgeFinalized only after GPX and local metadata are saved.
                ActiveActivitySessionData.STATUS_COMPLETED,
            )
        ) {
            fail("recording_active", "Finish the activity recording before installing an update.")
        }
        if (!canInstall()) fail("permission_denied", "Allow this app to install updates in Android settings.")
        val uri = FileProvider.getUriForFile(activity, "${activity.packageName}.updates", apk)
        activity.startActivity(
            Intent(Intent.ACTION_VIEW)
                .setDataAndType(uri, "application/vnd.android.package-archive")
                .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION),
        )
    }

    @Suppress("DEPRECATION")
    private fun installedPackage(): PackageInfo = packages.getPackageInfo(activity.packageName, signatureFlags())

    @Suppress("DEPRECATION")
    private fun signatureFlags(): Int = if (Build.VERSION.SDK_INT >= 28) {
        PackageManager.GET_SIGNING_CERTIFICATES
    } else {
        PackageManager.GET_SIGNATURES
    }

    @Suppress("DEPRECATION")
    private fun signers(info: PackageInfo): Set<String> {
        val signatures = if (Build.VERSION.SDK_INT >= 28) {
            info.signingInfo?.apkContentsSigners
        } else {
            info.signatures
        }
        return signatures?.map { it.toCharsString() }?.toSet().orEmpty()
    }

    @Suppress("DEPRECATION")
    private fun versionCode(info: PackageInfo): Long = if (Build.VERSION.SDK_INT >= 28) {
        info.longVersionCode
    } else {
        info.versionCode.toLong()
    }

    private fun fail(code: String, message: String): Nothing = throw UpdateInstallException(code, message)

    private companion object {
        const val APPLICATION_ID = "com.endurain.endurain.local"
    }
}
