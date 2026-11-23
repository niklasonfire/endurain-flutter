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

    private data class AnchorSample(
        val gpsElevationMeters: Double,
        val pressureHpa: Double,
        val locationTimeNanos: Long,
        val pressureTimeNanos: Long,
    )

    private data class GpsHandoff(val initialOffsetMeters: Double, val startedAtNanos: Long)

    private val anchorSamples = ArrayDeque<AnchorSample>()
    private var firstCalibrationFixTimeNanos: Long? = null
    private var receivedPressureResult = false
    private var gpsHandoff: GpsHandoff? = null
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
    private var hasBarometricReference = previous?.pressureHpa != null || gpsOffset != null
    private var awaitingResumeAnchor = hasBarometricReference

    fun onPressure(pressureHpa: Double, timestampNanos: Long) {
        receivedPressureResult = true
        if (!validPressure(pressureHpa)) {
            pressureUnavailable()
            return
        }
        if (timestampNanos < 0) return
        val previousTime = pressureTimestampNanos
        if (previousTime != null && timestampNanos <= previousTime) return
        if (previousTime != null && timestampNanos - previousTime > MAX_PRESSURE_AGE_NANOS) {
            resetPressureReference()
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
        receivedPressureResult = true
        filteredPressure = null
        pressureTimestampNanos = null
        resetPressureReference()
    }

    fun elevation(
        gpsElevationMeters: Double?,
        timestampNanos: Long,
        gpsVerticalAccuracyMeters: Double? = null,
        pressureSensorRegistered: Boolean = false,
    ): Reading {
        val gps = gpsElevationMeters?.takeIf { it.isFinite() }
        val pressureTime = pressureTimestampNanos
        val pressure = filteredPressure
        if (pressure != null && pressureTime != null && timestampNanos >= 0 &&
            abs(timestampNanos - pressureTime) <= MAX_PRESSURE_AGE_NANOS
        ) {
            if (referencePressure == null) {
                val anchor = if (hasBarometricReference) {
                    lastElevation
                } else {
                    initialAnchor(gps, gpsVerticalAccuracyMeters, pressure, timestampNanos, pressureTime)
                }
                if (anchor != null) {
                    if (!hasBarometricReference) {
                        // GPS may already have been used while the sensor was absent or after
                        // the initial window expired. Blend from that output across the handoff.
                        gpsHandoff = lastElevation?.let { GpsHandoff(it - anchor, timestampNanos) }
                    }
                    referenceElevation = anchor
                    referencePressure = pressure
                    hasBarometricReference = true
                }
            }
            val reference = referenceElevation
            val baseline = referencePressure
            if (reference != null && baseline != null) {
                val height = reference + pressureHeightChange(pressure, baseline) + handoffOffset(timestampNanos)
                lastElevation = height
                if (gps != null) gpsOffset = height - gps
                awaitingResumeAnchor = false
                return Reading(height, gps, pressure, gpsOffset)
            }
            if (calibrationElapsedNanos(timestampNanos) < ANCHOR_WINDOW_NANOS) {
                // The route still records during calibration. Leaving elevation unset prevents
                // an uncertain early GPS value from turning the first anchored point into a climb.
                return Reading(null, gps, lastElevationMeters = lastElevation)
            }
        } else {
            resetPressureReference()
            if (pressureSensorRegistered && !receivedPressureResult && !hasBarometricReference &&
                timestampNanos >= 0 && calibrationElapsedNanos(timestampNanos) < INITIAL_PRESSURE_WAIT_NANOS
            ) {
                return Reading(null, gps, lastElevationMeters = lastElevation)
            }
        }

        // Never substitute standard-atmosphere altitude for a missing GPS anchor.
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

    private fun calibrationElapsedNanos(timestampNanos: Long): Long {
        val startedAt = firstCalibrationFixTimeNanos
            ?: timestampNanos.also { firstCalibrationFixTimeNanos = it }
        return timestampNanos - startedAt
    }

    private fun initialAnchor(
        gps: Double?,
        gpsVerticalAccuracyMeters: Double?,
        pressure: Double,
        timestampNanos: Long,
        pressureTimeNanos: Long,
    ): Double? {
        if (gps == null || !hasUsableAccuracy(gpsVerticalAccuracyMeters) ||
            abs(timestampNanos - pressureTimeNanos) > MAX_GPS_PRESSURE_SEPARATION_NANOS
        ) return null

        while (anchorSamples.firstOrNull()?.let { timestampNanos - it.locationTimeNanos > ANCHOR_WINDOW_NANOS } == true) {
            anchorSamples.removeFirst()
        }
        val previous = anchorSamples.lastOrNull()
        if (previous != null &&
            (timestampNanos - previous.locationTimeNanos < ANCHOR_SAMPLE_INTERVAL_NANOS ||
                pressureTimeNanos <= previous.pressureTimeNanos)
        ) return null
        anchorSamples.addLast(AnchorSample(gps, pressure, timestampNanos, pressureTimeNanos))
        if (anchorSamples.size < REQUIRED_ANCHOR_SAMPLES) return null

        // Translate each GPS altitude to the latest pressure before averaging. The
        // calibration window can contain a real climb or descent.
        val anchor = anchorSamples
            .map { it.gpsElevationMeters + pressureHeightChange(pressure, it.pressureHpa) }
            .average()
        anchorSamples.clear()
        return anchor
    }

    private fun handoffOffset(timestampNanos: Long): Double {
        val handoff = gpsHandoff ?: return 0.0
        val elapsed = timestampNanos - handoff.startedAtNanos
        if (elapsed >= GPS_HANDOFF_DURATION_NANOS) {
            gpsHandoff = null
            return 0.0
        }
        return handoff.initialOffsetMeters * (1 - elapsed.coerceAtLeast(0) / GPS_HANDOFF_DURATION_NANOS)
    }

    private fun resetPressureReference() {
        referencePressure = null
        referenceElevation = null
        anchorSamples.clear()
        gpsHandoff = null
    }

    companion object {
        private const val MAX_PRESSURE_AGE_NANOS = 5_000_000_000L
        private const val MAX_GPS_PRESSURE_SEPARATION_NANOS = 2_000_000_000L
        private const val FILTER_TIME_CONSTANT_NANOS = 2_000_000_000.0
        private const val INITIAL_PRESSURE_WAIT_NANOS = 2_000_000_000L
        private const val ANCHOR_WINDOW_NANOS = 15_000_000_000L
        private const val ANCHOR_SAMPLE_INTERVAL_NANOS = 1_000_000_000L
        private const val REQUIRED_ANCHOR_SAMPLES = 3
        private const val MAX_VERTICAL_ACCURACY_METERS = 15.0
        private const val GPS_HANDOFF_DURATION_NANOS = 30_000_000_000.0

        private fun pressureHeightChange(pressure: Double, baseline: Double) =
            44330.0 * (1 - (pressure / baseline).pow(0.190294957))

        private fun hasUsableAccuracy(meters: Double?) =
            meters != null && meters > 0.0 && meters <= MAX_VERTICAL_ACCURACY_METERS

        private fun validPressure(value: Double) = value.isFinite() && value in 100.0..1100.0
    }
}
