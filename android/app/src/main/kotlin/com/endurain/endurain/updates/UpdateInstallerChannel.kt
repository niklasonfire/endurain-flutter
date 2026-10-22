package com.endurain.endurain.updates

import android.app.Activity
import android.content.ActivityNotFoundException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class UpdateInstallerChannel(private val activity: Activity) : MethodChannel.MethodCallHandler {
    private val installer = UpdateInstaller(activity)
    private val worker = Executors.newSingleThreadExecutor()
    private var channel: MethodChannel? = null

    fun register(messenger: BinaryMessenger) {
        channel = MethodChannel(messenger, "endurain/updates").also {
            it.setMethodCallHandler(this)
        }
    }

    fun unregister() {
        channel?.setMethodCallHandler(null)
        channel = null
        worker.shutdownNow()
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "installedInfo" -> result.success(installer.installedInfo())
                "canInstall" -> result.success(installer.canInstall())
                "requestInstallPermission" -> {
                    installer.requestInstallPermission()
                    result.success(null)
                }
                "install" -> {
                    val path = call.argument<String>("apkPath")
                    val code = call.argument<Number>("versionCode")?.toLong()
                    val packageName = call.argument<String>("applicationId")
                    val sha256 = call.argument<String>("sha256")
                    if (path == null || code == null || packageName == null || sha256 == null) {
                        result.error("invalid_arguments", "Update metadata is incomplete.", null)
                        return
                    }
                    worker.execute {
                        try {
                            val apk = installer.validate(path, code, packageName, sha256)
                            activity.runOnUiThread {
                                try {
                                    if (channel == null || activity.isFinishing || activity.isDestroyed) {
                                        result.error("unavailable", "The installer activity is no longer available.", null)
                                    } else {
                                        installer.launch(apk)
                                        result.success(null)
                                    }
                                } catch (error: Exception) {
                                    report(error, result)
                                }
                            }
                        } catch (error: Exception) {
                            activity.runOnUiThread { report(error, result) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            report(error, result)
        }
    }

    private fun report(error: Exception, result: MethodChannel.Result) {
        val code = when (error) {
            is UpdateInstallException -> error.code
            is ActivityNotFoundException -> "installer_unavailable"
            is SecurityException -> "permission_denied"
            else -> "platform_error"
        }
        result.error(code, error.message ?: "Android could not open the update installer.", null)
    }
}
