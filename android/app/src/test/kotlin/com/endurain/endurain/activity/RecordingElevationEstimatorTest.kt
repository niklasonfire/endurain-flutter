package com.endurain.endurain.activity

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.pow

class RecordingElevationEstimatorTest {
    private fun nanos(seconds: Long) = seconds * 1_000_000_000L
    private fun pressureAt(height: Double) = 1000.0 * (1 - height / 44330.0).pow(1 / 0.190294957)

    @Test
    fun noPressureLeavesGpsUnchanged() {
        val estimator = RecordingElevationEstimator()
        for ((index, gps) in listOf(100.0, 105.0, 98.0, 110.0).withIndex()) {
            val reading = estimator.elevation(gps, nanos(index.toLong()))
            assertEquals(gps, reading.elevationMeters!!, 0.0)
            assertNull(reading.pressureHpa)
        }
        assertNull(estimator.elevation(null, nanos(10)).elevationMeters)
        assertNull(estimator.elevation(Double.NaN, nanos(11)).elevationMeters)
    }

    @Test
    fun gpsOnlyRecordingKeepsRawGpsAltitudeAfterPauseOrRestart() {
        val restored = RecordingElevationEstimator(RecordedActivityPointData(
            timestamp = "2026-10-22T13:00:00.000Z", latitude = 50.0, longitude = 7.0,
            segmentIndex = 0, elevationMeters = 100.0, gpsElevationMeters = 100.0,
        ))
        assertEquals(150.0, restored.elevation(150.0, nanos(1)).elevationMeters!!, 0.0)
        assertEquals(155.0, restored.elevation(155.0, nanos(2)).elevationMeters!!, 0.0)
    }

    @Test
    fun flatPressureRejectsHundredsOfMetresOfGpsAscent() {
        val estimator = RecordingElevationEstimator()
        val heights = (0L..300L).map { second ->
            estimator.onPressure(1000.0, nanos(second))
            estimator.elevation(if (second % 2 == 0L) 100.0 else 107.0, nanos(second)).elevationMeters!!
        }
        val gain = heights.zipWithNext().sumOf { (a, b) -> (b - a).coerceAtLeast(0.0) }
        assertEquals(0.0, gain, 0.001)
        assertTrue(heights.all { it == 100.0 })
    }

    @Test
    fun recordedHeightsPreserveRealClimbAndDescentDespiteNoisyGps() {
        val estimator = RecordingElevationEstimator()
        val heights = (0L..160L).map { second ->
            val trueHeight = when {
                second < 20 -> 0.0
                second < 70 -> (second - 20) / 10.0
                second < 90 -> 5.0
                second < 160 -> 5.0 - (second - 90) / 10.0
                else -> -2.0
            }
            estimator.onPressure(pressureAt(trueHeight), nanos(second))
            estimator.elevation(if (second % 2 == 0L) 100.0 else 107.0, nanos(second)).elevationMeters!!
        }
        val gain = heights.zipWithNext().sumOf { (a, b) -> (b - a).coerceAtLeast(0.0) }
        val loss = heights.zipWithNext().sumOf { (a, b) -> (a - b).coerceAtLeast(0.0) }
        assertEquals(5.0, gain, 0.2)
        assertEquals(7.0, loss, 0.3)
    }

    @Test
    fun pressureNeedsAnAbsoluteAnchorButThenWorksWithoutGpsAltitude() {
        val estimator = RecordingElevationEstimator()
        estimator.onPressure(1000.0, nanos(1))
        assertNull(estimator.elevation(null, nanos(1)).elevationMeters)
        assertEquals(100.0, estimator.elevation(100.0, nanos(1)).elevationMeters!!, 0.0)
        for (second in 2L..20L) estimator.onPressure(pressureAt(5.0), nanos(second))
        assertEquals(105.0, estimator.elevation(null, nanos(20)).elevationMeters!!, 0.01)
    }

    @Test
    fun latePressureAndDropoutDoNotSwitchAbsoluteHeightReferences() {
        val estimator = RecordingElevationEstimator()
        assertEquals(100.0, estimator.elevation(100.0, nanos(0)).elevationMeters!!, 0.0)
        estimator.onPressure(1000.0, nanos(1))
        assertEquals(100.0, estimator.elevation(120.0, nanos(1)).elevationMeters!!, 0.0)
        // GPS now has a -20 m offset, maintained when pressure becomes stale.
        val fallback = estimator.elevation(120.0, nanos(7))
        assertEquals(100.0, fallback.elevationMeters!!, 0.0)
        assertNull(fallback.pressureHpa)
        assertEquals(102.0, estimator.elevation(122.0, nanos(8)).elevationMeters!!, 0.0)
        // Recovered pressure may be completely different after a long outage.
        estimator.onPressure(990.0, nanos(9))
        assertEquals(102.0, estimator.elevation(122.0, nanos(9)).elevationMeters!!, 0.0)
    }

    @Test
    fun invalidOutOfOrderAndOldPressureCannotReplaceGps() {
        for (pressure in listOf(Double.NaN, Double.POSITIVE_INFINITY, 0.0, -1.0, 2000.0)) {
            val estimator = RecordingElevationEstimator()
            estimator.onPressure(pressure, nanos(1))
            assertNull(estimator.elevation(100.0, nanos(1)).pressureHpa)
        }
        val estimator = RecordingElevationEstimator()
        estimator.onPressure(1000.0, nanos(10))
        estimator.onPressure(990.0, nanos(9))
        estimator.onPressure(990.0, nanos(10))
        assertEquals(1000.0, estimator.elevation(100.0, nanos(10)).pressureHpa!!, 0.0)
        assertNull(estimator.elevation(100.0, nanos(4)).pressureHpa)
        assertNull(estimator.elevation(100.0, nanos(16)).pressureHpa)
    }

    @Test
    fun smoothingReducesPressureNoiseAcrossDifferentSamplingRates() {
        for (interval in listOf(100_000_000L, 1_000_000_000L)) {
            val estimator = RecordingElevationEstimator()
            estimator.onPressure(1000.0, 0)
            estimator.elevation(100.0, 0)
            var maxError = 0.0
            for (index in 1..100) {
                val timestamp = index * interval
                estimator.onPressure(pressureAt(if (index % 2 == 0) 0.3 else -0.3), timestamp)
                maxError = maxOf(maxError, kotlin.math.abs(estimator.elevation(100.0, timestamp).elevationMeters!! - 100.0))
            }
            assertTrue("Filtered noise: $maxError", maxError < 0.15)
        }
    }

    @Test
    fun restartedRecorderReanchorsPressureWithoutInventingHeightDuringTheGap() {
        val previous = RecordedActivityPointData(
            timestamp = "2026-10-22T13:00:00.000Z", latitude = 50.0, longitude = 7.0,
            segmentIndex = 0, elevationMeters = 100.0, gpsElevationMeters = 120.0,
            pressureHpa = 1000.0,
        )
        val restored = RecordedActivityPointData.tryParseLine(previous.toJsonLine())!!
        assertEquals(previous, restored)
        val estimator = RecordingElevationEstimator(restored)
        estimator.onPressure(pressureAt(5.0), nanos(1))
        assertEquals(100.0, estimator.elevation(150.0, nanos(1)).elevationMeters!!, 0.01)
        // The native-only reference must not replace `ele` on the Flutter channel.
        assertEquals(100.0, restored.toMap()["ele"])
        assertTrue(!restored.toMap().containsKey("gpsEle"))

        val noSensorAfterRestart = RecordingElevationEstimator(restored)
        assertEquals(100.0, noSensorAfterRestart.elevation(120.0, nanos(1)).elevationMeters!!, 0.0)
    }
    @Test
    fun gpsFirstRecoveryKeepsHeightAndReanchorsFreshPressure() {
        val estimator = RecordingElevationEstimator(RecordedActivityPointData(
            timestamp = "2026-10-22T13:00:00.000Z", latitude = 50.0, longitude = 7.0,
            segmentIndex = 0, elevationMeters = 100.0, gpsElevationMeters = 120.0,
            pressureHpa = 1000.0,
        ))
        assertEquals(100.0, estimator.elevation(150.0, nanos(1)).elevationMeters!!, 0.0)
        estimator.onPressure(990.0, nanos(2))
        assertEquals(100.0, estimator.elevation(150.0, nanos(2)).elevationMeters!!, 0.0)
    }

    @Test
    fun pressureOnlyLastPointPreservesGpsFallbackOffsetAcrossRestart() {
        val estimator = RecordingElevationEstimator()
        estimator.onPressure(1000.0, nanos(0))
        estimator.elevation(120.0, nanos(0))
        estimator.onPressure(1000.0, nanos(1))
        estimator.elevation(140.0, nanos(1))
        val pressureOnly = estimator.elevation(null, nanos(1))
        val stored = RecordedActivityPointData(
            timestamp = "2026-10-22T13:00:00.000Z", latitude = 50.0, longitude = 7.0,
            segmentIndex = 0, elevationMeters = pressureOnly.elevationMeters,
            pressureHpa = pressureOnly.pressureHpa,
            gpsElevationOffsetMeters = pressureOnly.gpsOffsetMeters,
        )
        val restored = RecordingElevationEstimator(RecordedActivityPointData.tryParseLine(stored.toJsonLine()))
        assertEquals(120.0, restored.elevation(140.0, nanos(10)).elevationMeters!!, 0.0)
        assertEquals(121.0, restored.elevation(141.0, nanos(11)).elevationMeters!!, 0.0)
    }

    @Test
    fun lastKnownHeightSurvivesRestartAfterBothAltitudeSourcesAreMissing() {
        val previous = RecordedActivityPointData(
            timestamp = "2026-10-22T13:00:00.000Z", latitude = 50.0, longitude = 7.0,
            segmentIndex = 0, elevationReferenceMeters = 100.0,
            gpsElevationOffsetMeters = -20.0,
        )
        val restored = RecordedActivityPointData.tryParseLine(previous.toJsonLine())!!
        val gpsFirst = RecordingElevationEstimator(restored)
        assertEquals(100.0, gpsFirst.elevation(150.0, nanos(1)).elevationMeters!!, 0.0)
        val pressureFirst = RecordingElevationEstimator(restored)
        pressureFirst.onPressure(990.0, nanos(1))
        assertEquals(100.0, pressureFirst.elevation(null, nanos(1)).elevationMeters!!, 0.0)
    }

    @Test
    fun invalidAndMissingPressureReanchorEvenWithoutGpsDuringOutage() {
        for (invalidate in listOf(true, false)) {
            val estimator = RecordingElevationEstimator()
            estimator.onPressure(1000.0, nanos(0))
            estimator.elevation(100.0, nanos(0))
            if (invalidate) {
                estimator.onPressure(Double.NaN, nanos(1))
                assertNull(estimator.elevation(null, nanos(1)).pressureHpa)
            } else {
                assertNull(estimator.elevation(null, nanos(6)).pressureHpa)
            }
            estimator.onPressure(990.0, nanos(10))
            assertEquals(100.0, estimator.elevation(null, nanos(10)).elevationMeters!!, 0.0)
        }
    }
}
