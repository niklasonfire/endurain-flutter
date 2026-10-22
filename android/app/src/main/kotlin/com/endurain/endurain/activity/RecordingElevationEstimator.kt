package com.endurain.endurain.activity

import kotlin.math.abs
import kotlin.math.exp
import kotlin.math.pow

/**
 * Uses pressure for relative height and GPS for the initial absolute reference.
 * Without fresh pressure, GPS continues on the same height reference. Keeping
 * the inputs with each durable point lets a restarted recorder restore it.
 * All timestamps use Android's elapsed-realtime clock, not wall time.
 */
internal class RecordingElevationEstimator(previous: RecordedActivityPointData? = null) {
    data class Reading(
        val elevationMeters: Double?,
        val gpsElevationMeters: Double?,
        val pressureHpa: Double? = null,
        val gpsOffsetMeters: Double? = null,
        val lastElevationMeters: Double? = elevationMeters,
    )

    private var filteredPressure: Double? = null
    private var pressureTimestampNanos: Long? = null
    private var lastElevation = (previous?.elevationMeters ?: previous?.elevationReferenceMeters)
        ?.takeIf { it.isFinite() }
    private var gpsOffset = previous?.gpsElevationOffsetMeters?.takeIf { it.isFinite() }
        ?: previous?.gpsElevationMeters?.takeIf { previous.pressureHpa != null && it.isFinite() }?.let { gps ->
            lastElevation?.minus(gps)
        }
    // Pauses/restarts cannot distinguish weather drift from movement. Reanchor
    // fresh pressure to the last output instead of interpreting the gap as gain.
    private var referencePressure: Double? = null
    private var referenceElevation: Double? = null
    private var awaitingResumeAnchor = previous?.pressureHpa != null || gpsOffset != null

    fun onPressure(pressureHpa: Double, timestampNanos: Long) {
        if (!validPressure(pressureHpa)) {
            pressureUnavailable()
            return
        }
        if (timestampNanos < 0) return
        val previousTime = pressureTimestampNanos
        if (previousTime != null && timestampNanos <= previousTime) return
        if (previousTime != null && timestampNanos - previousTime > MAX_PRESSURE_AGE_NANOS) {
            referencePressure = null
            referenceElevation = null
        }
        val oldPressure = filteredPressure
        filteredPressure = if (oldPressure == null || previousTime == null ||
            timestampNanos - previousTime > MAX_PRESSURE_AGE_NANOS
        ) {
            pressureHpa
        } else {
            // Time-based low-pass filter: independent of the sensor's sample rate.
            val alpha = 1 - exp(-(timestampNanos - previousTime) / FILTER_TIME_CONSTANT_NANOS)
            oldPressure + alpha * (pressureHpa - oldPressure)
        }
        pressureTimestampNanos = timestampNanos
    }

    fun pressureUnavailable() {
        filteredPressure = null
        pressureTimestampNanos = null
        referencePressure = null
        referenceElevation = null
    }

    fun elevation(gpsElevationMeters: Double?, timestampNanos: Long): Reading {
        val gps = gpsElevationMeters?.takeIf { it.isFinite() }
        val pressureTime = pressureTimestampNanos
        val pressure = filteredPressure?.takeIf {
            pressureTime != null && abs(timestampNanos - pressureTime) <= MAX_PRESSURE_AGE_NANOS
        }
        if (pressure != null) {
            if (referencePressure == null || referenceElevation == null) {
                referenceElevation = lastElevation ?: gps
                referencePressure = pressure
            }
            val reference = referenceElevation
            val baseline = referencePressure
            if (reference != null && baseline != null) {
                val height = reference + 44330.0 * (1 - (pressure / baseline).pow(0.190294957))
                lastElevation = height
                if (gps != null) gpsOffset = height - gps
                awaitingResumeAnchor = false
                return Reading(height, gps, pressure, gpsOffset)
            }
        }

        // Never substitute standard-atmosphere altitude for a missing GPS anchor.
        referencePressure = null
        referenceElevation = null
        if (gps == null) return Reading(
            null, null, gpsOffsetMeters = gpsOffset, lastElevationMeters = lastElevation,
        )
        val height = if (awaitingResumeAnchor && lastElevation != null) {
            lastElevation!!.also { gpsOffset = it - gps }
        } else {
            gps + (gpsOffset ?: 0.0)
        }
        awaitingResumeAnchor = false
        lastElevation = height
        return Reading(height, gps, gpsOffsetMeters = gpsOffset)
    }

    companion object {
        private const val MAX_PRESSURE_AGE_NANOS = 5_000_000_000L
        private const val FILTER_TIME_CONSTANT_NANOS = 2_000_000_000.0

        private fun validPressure(value: Double) = value.isFinite() && value in 100.0..1100.0
    }
}
