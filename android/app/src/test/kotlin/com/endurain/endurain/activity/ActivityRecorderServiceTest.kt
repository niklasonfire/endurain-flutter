package com.endurain.endurain.activity

import android.Manifest
import android.app.Application
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorManager
import android.location.Location
import android.location.LocationManager
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.Shadows.shadowOf
import org.robolectric.android.controller.ServiceController
import org.robolectric.annotation.Config
import org.robolectric.shadows.SensorEventBuilder
import org.robolectric.shadows.ShadowSensor
import java.util.Date

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [35], application = Application::class)
class ActivityRecorderServiceTest {
    private lateinit var application: Application
    private lateinit var store: ActiveActivityStore
    private lateinit var locations: LocationManager
    private val controllers = mutableListOf<ServiceController<ActivityRecorderService>>()

    @Before
    fun setUp() {
        application = RuntimeEnvironment.getApplication()
        shadowOf(application).grantPermissions(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        )
        locations = application.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        shadowOf(locations).setProviderEnabled(LocationManager.GPS_PROVIDER, true)
        store = ActiveActivityStore.of(application)
        store.clear()
    }

    @After
    fun tearDown() {
        controllers.forEach { it.destroy() }
        controllers.clear()
        ActivityRecorderCoordinator.detach()
        store.clear()
    }

    private fun session(status: String = ActiveActivitySessionData.STATUS_RECORDING) =
        ActiveActivitySessionData(
            localSessionId = "existing_session",
            activityType = "ride",
            status = status,
            startedAt = IsoTime.format(Date(System.currentTimeMillis() - 60_000)),
            connectionOrigin = "https://example.test",
            connectionProfileId = "profile_1",
        )

    private fun service(): ServiceController<ActivityRecorderService> =
        Robolectric.buildService(ActivityRecorderService::class.java).create().also {
            controllers.add(it)
        }

    private fun fix(latitude: Double, timeMillis: Long = System.currentTimeMillis(), altitude: Double? = null, speed: Float? = null) {
        shadowOf(Looper.getMainLooper()).idleFor(java.time.Duration.ofSeconds(1))
        shadowOf(locations).simulateLocation(Location(LocationManager.GPS_PROVIDER).apply {
            this.latitude = latitude
            longitude = -8.0
            time = timeMillis
            accuracy = 5f
            if (altitude != null) this.altitude = altitude
            if (speed != null) this.speed = speed
            elapsedRealtimeNanos = android.os.SystemClock.elapsedRealtimeNanos()
        })
        shadowOf(Looper.getMainLooper()).idle()
    }

    private fun pressure(
        manager: SensorManager,
        sensor: Sensor,
        hpa: Float,
        accuracy: Int = SensorManager.SENSOR_STATUS_ACCURACY_HIGH,
    ) {
        shadowOf(manager).sendSensorEventToListeners(SensorEventBuilder.newBuilder()
            .setSensor(sensor)
            .setValues(floatArrayOf(hpa))
            .setAccuracy(accuracy)
            .setTimestamp(android.os.SystemClock.elapsedRealtimeNanos())
            .build())
    }

    @Test
    fun barometerCorrectsPersistedAndEmittedAltitudeAndStopsWhilePaused() {
        val events = mutableListOf<Map<*, *>>()
        ActivityRecorderCoordinator.attach(object : EventChannel.EventSink {
            override fun success(event: Any?) { events.add(event as Map<*, *>) }
            override fun error(code: String, message: String?, details: Any?) = Unit
            override fun endOfStream() = Unit
        })
        val manager = application.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor = ShadowSensor.newInstance(Sensor.TYPE_PRESSURE)
        shadowOf(manager).addSensor(sensor)
        store.saveSession(session())
        val controller = service()
        controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_START), 0, 1)
        assertEquals(1, shadowOf(manager).listeners.size)

        pressure(manager, sensor, 1000f)
        fix(41.1, altitude = 100.0)
        pressure(manager, sensor, 1000f)
        fix(41.1001, altitude = 120.0)
        assertEquals(listOf(100.0, 100.0), store.readPoints().map { it.elevationMeters })
        val emitted = events.last { it["type"] == "pointBatchAvailable" }["points"] as List<*>
        assertEquals(100.0, (emitted.last() as Map<*, *>)["ele"])
        assertEquals(1000.0, store.readPoints().last().pressureHpa!!, 0.0)

        store.saveSession(session(ActiveActivitySessionData.STATUS_PAUSED))
        controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_PAUSE), 0, 2)
        assertTrue(shadowOf(manager).listeners.isEmpty())

        store.saveSession(session())
        controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_RESUME), 0, 3)
        pressure(manager, sensor, 1000f)
        fix(41.1002, altitude = 150.0)
        assertEquals(100.0, store.readPoints().last().elevationMeters!!, 0.01)
        pressure(manager, sensor, 900f, SensorManager.SENSOR_STATUS_UNRELIABLE)
        fix(41.1003, altitude = 150.0)
        assertEquals(100.0, store.readPoints().last().elevationMeters!!, 0.01)
        assertNull(store.readPoints().last().pressureHpa)
        pressure(manager, sensor, 990f)
        fix(41.1004, altitude = 150.0)
        assertEquals(100.0, store.readPoints().last().elevationMeters!!, 0.01)
        pressure(manager, sensor, Float.NaN)
        fix(41.1005, altitude = 150.0)
        assertNull(store.readPoints().last().pressureHpa)
        controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_STOP), 0, 4)
        assertTrue(shadowOf(manager).listeners.isEmpty())
    }

    @Test
    fun automaticPauseReleasesPressureAndResumeDoesNotCountWeatherDrift() {
        val manager = application.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        val sensor = ShadowSensor.newInstance(Sensor.TYPE_PRESSURE)
        shadowOf(manager).addSensor(sensor)
        store.saveSession(session().copy(autoPauseEnabled = true, autoPauseDelaySeconds = 1))
        val controller = service()
        controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_START), 0, 1)
        val start = System.currentTimeMillis()
        pressure(manager, sensor, 1000f)
        fix(41.1, start, altitude = 100.0, speed = 1f)
        pressure(manager, sensor, 1000f)
        fix(41.1, start + 2_000, altitude = 120.0, speed = 0f)
        assertTrue(store.loadSession()!!.pausedAutomatically)
        assertTrue(shadowOf(manager).listeners.isEmpty())
        val count = store.pointCount()
        pressure(manager, sensor, 990f)
        for (index in 1..3) {
            fix(41.1 + index * 0.00001, start + 10_000 + index * 1_000, altitude = 150.0, speed = 1f)
        }
        assertEquals(ActiveActivitySessionData.STATUS_RECORDING, store.loadSession()!!.status)
        assertEquals(count + 1, store.pointCount())
        assertEquals(1, shadowOf(manager).listeners.size)
        assertEquals(100.0, store.readPoints().last().elevationMeters!!, 0.01)
        pressure(manager, sensor, 990f)
        fix(41.10004, start + 14_000, altitude = 150.0, speed = 1f)
        assertEquals(100.0, store.readPoints().last().elevationMeters!!, 0.01)
    }

    @Test
    fun missingOrFailedBarometerKeepsGpsRecordingWorking() {
        val manager = application.getSystemService(Context.SENSOR_SERVICE) as SensorManager
        for (sensorPresent in listOf(false, true)) {
            store.clear()
            if (sensorPresent) {
                shadowOf(manager).addSensor(ShadowSensor.newInstance(Sensor.TYPE_PRESSURE))
                shadowOf(manager).setForceListenersToFail(true)
            }
            store.saveSession(session())
            val controller = service()
            controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_START), 0, 1)
            fix(41.1, altitude = 100.0)
            fix(41.1001, altitude = 110.0)
            assertEquals(listOf(100.0, 110.0), store.readPoints().map { it.elevationMeters })
            assertNull(store.readPoints().last().pressureHpa)
            controller.get().onStartCommand(Intent().setAction(ActivityRecorderService.ACTION_STOP), 0, 2)
        }
    }

    @Test
    fun liveRecoveryAndTaskRemovalKeepTheSameRecordingRunning() {
        val original = session()
        store.saveSession(original)
        val controller = service()
        controller.get().onStartCommand(Intent(application, ActivityRecorderService::class.java).apply {
            action = ActivityRecorderService.ACTION_START
        }, 0, 1)
        fix(41.1)
        assertEquals(1, store.pointCount())

        controller.get().onTaskRemoved(Intent())
        assertEquals(original, ActivityRecorderService.recover(application))
        assertEquals(original, ActivityRecorderService.recover(application))
        assertNull(shadowOf(application).nextStartedService)
        assertFalse(shadowOf(controller.get()).isStoppedBySelf)
        fix(41.2, System.currentTimeMillis() + 1_000)

        assertEquals(listOf(0, 0), store.readPoints().map { it.segmentIndex })
        assertEquals(original.localSessionId, store.loadSession()?.localSessionId)
    }

    @Test
    fun recoveryRestartsCollectionAndBeginsANewSegment() {
        val original = session()
        store.saveSession(original)
        store.appendPoints(listOf(RecordedActivityPointData(
            timestamp = IsoTime.format(Date(System.currentTimeMillis() - 1_000)),
            latitude = 41.1,
            longitude = -8.0,
            segmentIndex = 0,
        )))

        val recovered = ActivityRecorderService.recover(application)!!
        assertEquals(original.localSessionId, recovered.localSessionId)
        assertEquals(original.connectionProfileId, recovered.connectionProfileId)
        assertEquals(ActiveActivitySessionData.STATUS_RECORDING, recovered.status)
        assertNotNull(recovered.resumedAt)
        val intent = shadowOf(application).nextStartedService!!
        val controller = service()
        controller.get().onStartCommand(intent, 0, 1)
        fix(41.2)

        assertEquals(listOf(0, 1), store.readPoints().map { it.segmentIndex })
    }

    @Test
    fun stickyRestartPreservesTheSessionAndRestartsCollection() {
        store.saveSession(session())
        val controller = service()
        assertEquals(android.app.Service.START_STICKY, controller.get().onStartCommand(null, 0, 1))
        fix(41.1)

        assertEquals("existing_session", store.loadSession()?.localSessionId)
        assertEquals(1, store.pointCount())
    }

    @Test
    fun pausedAndFailedSessionsAreNotAutomaticallyStarted() {
        for (status in listOf(
            ActiveActivitySessionData.STATUS_PAUSED,
            ActiveActivitySessionData.STATUS_FAILED,
        )) {
            store.saveSession(session(status))
            val recovered = ActivityRecorderService.recover(application)!!
            assertEquals(ActiveActivitySessionData.STATUS_PAUSED, recovered.status)
            assertEquals("existing_session", recovered.localSessionId)
            assertNull(shadowOf(application).nextStartedService)
        }
    }

    @Test
    fun recoveryBeforeFirstFixDoesNotDiscardTheSession() {
        store.saveSession(session())
        val recovered = ActivityRecorderService.recover(application)!!
        assertEquals(ActiveActivitySessionData.STATUS_RECORDING, recovered.status)
        assertEquals(0, store.pointCount())
        assertNotNull(store.loadSession())
        val controller = service()
        controller.get().onStartCommand(shadowOf(application).nextStartedService!!, 0, 1)
        fix(41.1)
        assertEquals(1, store.pointCount())
    }

    @Test
    fun deniedPermissionKeepsDurablePointsForExplicitRecovery() {
        store.saveSession(session())
        store.appendPoints(listOf(RecordedActivityPointData(
            timestamp = IsoTime.nowUtc(), latitude = 41.1, longitude = -8.0, segmentIndex = 0,
        )))
        shadowOf(application).denyPermissions(
            Manifest.permission.ACCESS_FINE_LOCATION,
            Manifest.permission.ACCESS_COARSE_LOCATION,
        )
        ActivityRecorderService.recover(application)
        val controller = service()
        controller.get().onStartCommand(shadowOf(application).nextStartedService!!, 0, 1)
        shadowOf(Looper.getMainLooper()).idle()

        assertEquals(ActiveActivitySessionData.STATUS_FAILED, store.loadSession()?.status)
        assertEquals(1, store.pointCount())
        assertTrue(shadowOf(controller.get()).isStoppedBySelf)
        assertEquals(
            ActiveActivitySessionData.STATUS_PAUSED,
            ActivityRecorderService.recover(application)?.status,
        )
    }

    @Test
    fun pointEventsIncludeSessionIdentityAndDurableOffset() {
        val events = mutableListOf<Map<*, *>>()
        ActivityRecorderCoordinator.attach(object : EventChannel.EventSink {
            override fun success(event: Any?) { events.add(event as Map<*, *>) }
            override fun error(code: String, message: String?, details: Any?) = Unit
            override fun endOfStream() = Unit
        })
        store.saveSession(session())
        val controller = service()
        controller.get().onStartCommand(Intent(application, ActivityRecorderService::class.java).apply {
            action = ActivityRecorderService.ACTION_START
        }, 0, 1)
        fix(41.1)
        fix(41.2, System.currentTimeMillis() + 1_000)
        val batches = events.filter { it["type"] == "pointBatchAvailable" }

        assertEquals(listOf(0, 1), batches.map { it["pointOffset"] })
        assertTrue(batches.all { it["localSessionId"] == "existing_session" })
        assertTrue(batches.all { it["version"] == ActivityRecorderChannel.PAYLOAD_VERSION })
    }
}
