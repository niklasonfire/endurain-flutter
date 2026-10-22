package com.endurain.endurain.activity

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.location.Location
import android.os.Handler
import android.os.Looper

/** Optional pressure capture, sharing the location recorder's main-thread lifecycle. */
internal class RecordingBarometer(private val manager: SensorManager?) : SensorEventListener {
    private var estimator = RecordingElevationEstimator()
    private var registered = false

    fun start(previous: RecordedActivityPointData?) {
        stop()
        estimator = RecordingElevationEstimator(previous)
        try {
            val sensor = manager?.getDefaultSensor(Sensor.TYPE_PRESSURE) ?: return
            registered = manager.registerListener(
                this,
                sensor,
                SensorManager.SENSOR_DELAY_NORMAL,
                Handler(Looper.getMainLooper()),
            )
        } catch (_: RuntimeException) {
            // Missing/broken pressure hardware must never prevent GPS recording.
            stop()
        }
    }

    fun stop() {
        try {
            manager?.unregisterListener(this)
        } catch (_: RuntimeException) {
            // Sensor teardown must not interfere with recording teardown.
        }
        registered = false
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (registered && event.sensor.type == Sensor.TYPE_PRESSURE && event.values.isNotEmpty()) {
            if (event.accuracy == SensorManager.SENSOR_STATUS_UNRELIABLE) {
                estimator.pressureUnavailable()
                return
            }
            estimator.onPressure(event.values[0].toDouble(), event.timestamp)
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
        if (registered && sensor?.type == Sensor.TYPE_PRESSURE &&
            accuracy == SensorManager.SENSOR_STATUS_UNRELIABLE
        ) {
            estimator.pressureUnavailable()
        }
    }

    fun elevation(location: Location): RecordingElevationEstimator.Reading = estimator.elevation(
        location.altitude.takeIf { location.hasAltitude() },
        location.elapsedRealtimeNanos,
    )
}
