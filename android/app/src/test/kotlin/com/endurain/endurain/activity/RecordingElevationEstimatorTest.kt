package com.endurain.endurain.activity

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import kotlin.math.pow

class RecordingElevationEstimatorTest {
    private fun nanos(seconds: Long) = seconds * 1_000_000_000L
    private fun pressureAt(height: Double) = 1000.0 * (1 - height / 44330.0).pow(1 / 0.190294957)

    private fun calibrateAt(estimator: RecordingElevationEstimator, height: Double, start: Long = 0L) {
        for (second in start..start + 2L) {
            estimator.onPressure(1000.0, nanos(second))
            estimator.elevation(height, nanos(second), gpsVerticalAccuracyMeters = 5.0)
        }
    }

    @Test
    fun poorInitialGpsDoesNotSetTheBarometricReference() {
        val estimator = RecordingElevationEstimator()
        estimator.onPressure(1000.0, nanos(1))
        val poor = estimator.elevation(180.0, nanos(1), gpsVerticalAccuracyMeters = 45.0)
        assertEquals(180.0, poor.gpsElevationMeters!!, 0.0)
        assertNull(poor.elevationMeters)

        for (second in 2L..4L) {
            estimator.onPressure(1000.0, nanos(second))
            val reading = estimator.elevation(100.0, nanos(second), gpsVerticalAccuracyMeters = 5.0)
            if (second < 4) {
                assertNull(reading.elevationMeters)
            } else {
                assertEquals(100.0, reading.elevationMeters!!, 0.001)
                assertEquals(1000.0, reading.pressureHpa!!, 0.001)
            }
        }
    }

    @Test
    fun initialAnchorAccountsForAClimbDuringCalibration() {
        val estimator = RecordingElevationEstimator()
        estimator.onPressure(1000.0, nanos(0))
        assertNull(estimator.elevation(100.0, nanos(0), 5.0).elevationMeters)

        // Pressure and GPS observe a 15 m climb during calibration.
        for (second in 1L..10L) {
            estimator.onPressure(pressureAt(15.0), nanos(second))
            if (second == 5L) assertNull(estimator.elevation(115.0, nanos(second), 5.0).elevationMeters)
        }
        val anchored = estimator.elevation(115.0, nanos(10), 5.0)
        assertEquals(115.0, anchored.elevationMeters!!, 1.0)
    }

    @Test
    fun sensorWithNoReliableGpsFallsBackAndCanCalibrateLater() {
        val estimator = RecordingElevationEstimator()
        for (second in 0L..18L) {
            estimator.onPressure(1000.0, nanos(second))
            val reading = estimator.elevation(100.0, nanos(second))
            assertNull(reading.pressureHpa)
            if (second < 15) {
                assertNull(reading.elevationMeters)
            } else {
                assertEquals(100.0, reading.elevationMeters!!, 0.0)
            }
        }
        for (second in 19L..20L) {
            estimator.onPressure(1000.0, nanos(second))
            estimator.elevation(100.0, nanos(second), 5.0)
        }
        estimator.onPressure(1000.0, nanos(21))
        val blended = estimator.elevation(103.0, nanos(21), 5.0)
        assertEquals(100.0, blended.elevationMeters!!, 0.0)
        assertEquals(1000.0, blended.pressureHpa!!, 0.0)

        var current = 100.0
        for (second in 22L..51L) {
            estimator.onPressure(1000.0, nanos(second))
            current = estimator.elevation(101.0, nanos(second), 5.0).elevationMeters!!
        }
        assertTrue("Slow correction after calibration: $current m", current > 100.0 && current < 100.2)
    }

    @Test
    fun calibrationRequiresDistinctLocationAndPressureSamples() {
        val estimator = RecordingElevationEstimator()
        estimator.onPressure(1000.0, nanos(0))
        for (second in 0L..3L) {
            assertNull(estimator.elevation(100.0, nanos(second), 5.0).pressureHpa)
        }
        estimator.onPressure(1000.0, nanos(4))
        assertNull(estimator.elevation(100.0, nanos(4), 5.0).pressureHpa)
        assertNull(estimator.elevation(100.0, nanos(4), 5.0).pressureHpa)
        estimator.onPressure(1000.0, nanos(5))
        assertEquals(100.0, estimator.elevation(100.0, nanos(5), 5.0).elevationMeters!!, 0.0)
    }

    @Test
    fun registeredBarometerCanAvoidWritingPoorGpsBeforeTheFirstPressureEvent() {
        val estimator = RecordingElevationEstimator()
        val initial = estimator.elevation(185.0, nanos(0), 45.0, pressureSensorRegistered = true)
        assertEquals(185.0, initial.gpsElevationMeters!!, 0.0)
        assertNull(initial.elevationMeters)

        calibrateAt(estimator, 100.0, start = 1L)
        assertEquals(100.0, estimator.elevation(100.0, nanos(3), 5.0).elevationMeters!!, 0.0)
    }

    @Test
    fun registeredButSilentBarometerUsesGpsAfterShortStartupWait() {
        val estimator = RecordingElevationEstimator()
        for (second in 0L..1L) {
            assertNull(estimator.elevation(100.0, nanos(second), 5.0, pressureSensorRegistered = true).elevationMeters)
        }
        assertEquals(
            102.0,
            estimator.elevation(102.0, nanos(2), 5.0, pressureSensorRegistered = true).elevationMeters!!,
            0.0,
        )
    }

    @Test
    fun slowCorrectionReducesWeatherDrift() {
        val estimator = RecordingElevationEstimator()
        calibrateAt(estimator, 100.0)
        var height = 100.0
        for (second in 3L..1202L) {
            // Air pressure falls on flat ground, mimicking a 12 m climb over ten minutes.
            val weatherDrift = ((second - 2L) / 50.0).coerceAtMost(12.0)
            estimator.onPressure(pressureAt(weatherDrift), nanos(second))
            height = estimator.elevation(100.0, nanos(second), 5.0).elevationMeters!!
            if (second == 602L) assertTrue("Gradual correction: $height", height in 103.0..107.0)
        }
        assertEquals(100.0, height, 1.0)
    }

    @Test
    fun driftCorrectionFavorsMoreAccurateGpsAndPreservesClimbs() {
        fun withGpsAccuracy(accuracy: Double): Double {
            val estimator = RecordingElevationEstimator()
            calibrateAt(estimator, 100.0)
            var height = 100.0
            for (second in 3L..602L) {
                estimator.onPressure(1000.0, nanos(second))
                height = estimator.elevation(106.0, nanos(second), accuracy).elevationMeters!!
            }
            return height
        }

        assertTrue(withGpsAccuracy(5.0) > withGpsAccuracy(12.0) + 2.0)
        assertEquals(100.0, withGpsAccuracy(25.0), 0.0)

        val estimator = RecordingElevationEstimator()
        calibrateAt(estimator, 100.0)
        var height = 100.0
        for (second in 3L..62L) {
            val climb = (second - 2L) * 0.5
            val gpsNoise = if (second % 2 == 0L) -4.0 else 4.0
            estimator.onPressure(pressureAt(climb), nanos(second))
            height = estimator.elevation(100.0 + climb + gpsNoise, nanos(second), 5.0).elevationMeters!!
        }
        assertEquals(130.0, height, 2.0)
    }

    @Test
    fun gpsReturningAfterAWeakOrSparsePeriodDoesNotJump() {
        val estimator = RecordingElevationEstimator()
        calibrateAt(estimator, 100.0)
        for (second in 3L..302L) {
            estimator.onPressure(1000.0, nanos(second))
            estimator.elevation(null, nanos(second))
        }
        estimator.onPressure(1000.0, nanos(303))
        val next = estimator.elevation(125.0, nanos(303), 5.0).elevationMeters!!
        assertTrue(next in 100.0..100.1)
        assertEquals(next, estimator.elevation(125.0, nanos(303), 5.0).elevationMeters!!, 0.0)
        assertEquals(next, estimator.elevation(125.0, nanos(302), 5.0).elevationMeters!!, 0.0)

        for (second in 304L..602L) estimator.onPressure(1000.0, nanos(second))
        val sparse = estimator.elevation(130.0, nanos(602), 5.0).elevationMeters!!
        assertTrue(sparse in next..next + 0.5)
    }

    @Test
    fun unreliableOrUnpairedGpsDoesNotPoisonTheFallbackReference() {
        val estimator = RecordingElevationEstimator()
        calibrateAt(estimator, 100.0)

        estimator.onPressure(1000.0, nanos(3))
        assertEquals(100.0, estimator.elevation(170.0, nanos(3), 60.0).elevationMeters!!, 0.0)
        // The pressure reading is usable for relative elevation, but too old to pair with this fix.
        assertEquals(100.0, estimator.elevation(160.0, nanos(6), 5.0).elevationMeters!!, 0.0)

        val fallback = estimator.elevation(100.0, nanos(9), 5.0)
        assertEquals(100.0, fallback.elevationMeters!!, 0.0)
        assertNull(fallback.pressureHpa)

        estimator.onPressure(1000.0, nanos(10))
        val pressureRestored = estimator.elevation(100.0, nanos(10), 5.0)
        assertEquals(100.0, pressureRestored.elevationMeters!!, 0.0)
        assertEquals(1000.0, pressureRestored.pressureHpa!!, 0.0)
    }

    @Test
    fun latePressureDoesNotTurnABiasedGpsAltitudeIntoAClimb() {
        val estimator = RecordingElevationEstimator()
        assertEquals(50.0, estimator.elevation(50.0, nanos(0), 60.0).elevationMeters!!, 0.0)
        calibrateAt(estimator, 100.0, start = 1L)
        var height = estimator.elevation(100.0, nanos(3), 5.0).elevationMeters!!
        assertEquals(50.0, height, 0.0)

        for (second in 4L..33L) {
            estimator.onPressure(1000.0, nanos(second))
            val next = estimator.elevation(100.0, nanos(second), 5.0).elevationMeters!!
            assertTrue("Handoff step: ${next - height} m", next - height in 0.0..0.1)
            height = next
        }
        assertTrue("False gain after 30 seconds: ${height - 50.0} m", height - 50.0 in 0.0..1.0)
    }

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
        calibrateAt(estimator, 100.0)
        val heights = (3L..303L).map { second ->
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
        calibrateAt(estimator, 100.0)
        val heights = (3L..160L).map { second ->
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
        calibrateAt(estimator, 100.0, start = 1L)
        for (second in 4L..20L) estimator.onPressure(pressureAt(5.0), nanos(second))
        assertEquals(105.0, estimator.elevation(null, nanos(20)).elevationMeters!!, 0.01)
    }

    @Test
    fun latePressureAndDropoutDoNotSwitchAbsoluteHeightReferences() {
        val estimator = RecordingElevationEstimator()
        assertEquals(100.0, estimator.elevation(100.0, nanos(0)).elevationMeters!!, 0.0)
        calibrateAt(estimator, 120.0, start = 1L)
        // GPS now has a -20 m offset, maintained when pressure becomes stale.
        val fallback = estimator.elevation(120.0, nanos(9))
        assertEquals(100.0, fallback.elevationMeters!!, 0.0)
        assertNull(fallback.pressureHpa)
        assertEquals(102.0, estimator.elevation(122.0, nanos(10)).elevationMeters!!, 0.0)
        // Recovered pressure may be completely different after a long outage.
        estimator.onPressure(990.0, nanos(11))
        assertEquals(102.0, estimator.elevation(122.0, nanos(11)).elevationMeters!!, 0.0)
    }

    @Test
    fun invalidOutOfOrderAndOldPressureCannotReplaceGps() {
        for (pressure in listOf(Double.NaN, Double.POSITIVE_INFINITY, 0.0, -1.0, 2000.0)) {
            val estimator = RecordingElevationEstimator()
            estimator.onPressure(pressure, nanos(1))
            assertNull(estimator.elevation(100.0, nanos(1)).pressureHpa)
        }
        val estimator = RecordingElevationEstimator()
        calibrateAt(estimator, 100.0, start = 10L)
        estimator.onPressure(990.0, nanos(11))
        estimator.onPressure(990.0, nanos(12))
        assertEquals(1000.0, estimator.elevation(100.0, nanos(12)).pressureHpa!!, 0.0)
        assertNull(estimator.elevation(100.0, nanos(6)).pressureHpa)
        assertNull(estimator.elevation(100.0, nanos(18)).pressureHpa)
    }

    @Test
    fun smoothingReducesPressureNoiseAcrossDifferentSamplingRates() {
        for (interval in listOf(100_000_000L, 1_000_000_000L)) {
            val estimator = RecordingElevationEstimator()
            calibrateAt(estimator, 100.0)
            var maxError = 0.0
            for (index in 1..100) {
                val timestamp = nanos(2) + index * interval
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
        assertEquals(100.0, estimator.elevation(150.0, nanos(1), 5.0).elevationMeters!!, 0.0)
        estimator.onPressure(990.0, nanos(2))
        assertEquals(100.0, estimator.elevation(150.0, nanos(2)).elevationMeters!!, 0.0)
    }

    @Test
    fun pressureOnlyLastPointPreservesGpsFallbackOffsetAcrossRestart() {
        val estimator = RecordingElevationEstimator()
        calibrateAt(estimator, 120.0)
        estimator.onPressure(1000.0, nanos(3))
        estimator.elevation(140.0, nanos(3), 5.0)
        val pressureOnly = estimator.elevation(null, nanos(3))
        val stored = RecordedActivityPointData(
            timestamp = "2026-10-22T13:00:00.000Z", latitude = 50.0, longitude = 7.0,
            segmentIndex = 0, elevationMeters = pressureOnly.elevationMeters,
            pressureHpa = pressureOnly.pressureHpa,
            gpsElevationOffsetMeters = pressureOnly.gpsOffsetMeters,
        )
        val restored = RecordingElevationEstimator(RecordedActivityPointData.tryParseLine(stored.toJsonLine()))
        val lastHeight = pressureOnly.elevationMeters!!
        assertEquals(lastHeight, restored.elevation(140.0, nanos(10)).elevationMeters!!, 0.001)
        assertEquals(lastHeight + 1.0, restored.elevation(141.0, nanos(11)).elevationMeters!!, 0.001)
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
        val weakGps = gpsFirst.elevation(150.0, nanos(1), 60.0)
        assertEquals(130.0, weakGps.elevationMeters!!, 0.0)
        assertEquals(-20.0, weakGps.gpsOffsetMeters!!, 0.0)

        val reliableGpsFirst = RecordingElevationEstimator(restored)
        assertEquals(100.0, reliableGpsFirst.elevation(150.0, nanos(1), 5.0).elevationMeters!!, 0.0)
        val pressureFirst = RecordingElevationEstimator(restored)
        pressureFirst.onPressure(990.0, nanos(1))
        assertEquals(100.0, pressureFirst.elevation(null, nanos(1)).elevationMeters!!, 0.0)
    }

    @Test
    fun invalidAndMissingPressureReanchorEvenWithoutGpsDuringOutage() {
        for (invalidate in listOf(true, false)) {
            val estimator = RecordingElevationEstimator()
            calibrateAt(estimator, 100.0)
            if (invalidate) {
                estimator.onPressure(Double.NaN, nanos(3))
                assertNull(estimator.elevation(null, nanos(3)).pressureHpa)
            } else {
                assertNull(estimator.elevation(null, nanos(8)).pressureHpa)
            }
            estimator.onPressure(990.0, nanos(10))
            assertEquals(100.0, estimator.elevation(null, nanos(10)).elevationMeters!!, 0.0)
        }
    }
}
