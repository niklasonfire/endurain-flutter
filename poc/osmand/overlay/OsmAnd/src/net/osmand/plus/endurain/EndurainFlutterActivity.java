package net.osmand.plus.endurain;

import android.app.Activity;
import android.app.Application;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.view.Gravity;
import android.widget.Button;
import android.widget.FrameLayout;
import android.icu.util.LocaleData;
import android.icu.util.ULocale;
import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterFragmentActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import net.osmand.plus.OsmandApplication;
import net.osmand.plus.activities.MapActivity;
import net.osmand.plus.plugins.PluginsHelper;
import net.osmand.plus.plugins.monitoring.OsmandMonitoringPlugin;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** Flutter is a client UI; unchanged OsmAnd services exclusively own recording. */
public class EndurainFlutterActivity extends FlutterFragmentActivity {
    private ExecutorService files;
    private MethodChannel deviceSettings;
    private final Handler main = new Handler(Looper.getMainLooper());
    private MethodChannel channel;
    private static boolean recordingRequested;
    private static boolean lifecycleRegistered;
    private static final long MAX_GPX_BYTES = 64L * 1024 * 1024;

    @Override public void configureFlutterEngine(@NonNull FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        OsmandApplication app = (OsmandApplication) getApplication();
        registerMapLifecycle(app);
        files = Executors.newSingleThreadExecutor();
        deviceSettings = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "endurain/device_settings");
        deviceSettings.setMethodCallHandler((call, result) -> {
            if (!call.method.equals("getMeasurementSystem")) { result.notImplemented(); return; }
            LocaleData.MeasurementSystem system = LocaleData.getMeasurementSystem(ULocale.forLocale(java.util.Locale.getDefault()));
            result.success(system == LocaleData.MeasurementSystem.SI ? "metric" : "imperial");
        });
        channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), "endurain/osmand_host");
        channel.setMethodCallHandler((call, result) -> {
            if (call.method.equals("isAvailable")) { result.success(true); return; }
            if (call.method.equals("openMap") || call.method.equals("openRecording")) {
                recordingRequested = call.method.equals("openRecording");
                startActivity(new Intent(this, MapActivity.class).addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT));
                result.success(null);
                return;
            }
            if (call.method.equals("listCompletedRecordings") || call.method.equals("readCompletedRecording")) {
                files.execute(() -> {
                    try {
                        File root = app.getAppCustomization().getTracksDir().getCanonicalFile();
                        List<File> recordings = new ArrayList<>();
                        collect(root, root, recordings);
                        recordings.sort(Comparator.comparingLong(File::lastModified).reversed());
                        Object answer;
                        if (call.method.equals("listCompletedRecordings")) {
                            List<Map<String, Object>> entries = new ArrayList<>();
                            for (File file : recordings) {
                                Map<String, Object> entry = new HashMap<>();
                                entry.put("id", identity(root, file));
                                entry.put("name", root.toPath().relativize(file.toPath()).toString());
                                entry.put("size", file.length());
                                entry.put("modifiedAt", file.lastModified());
                                entries.add(entry);
                            }
                            answer = entries;
                        } else {
                            String wanted = call.argument("id");
                            File selected = null;
                            for (File file : recordings) if (identity(root, file).equals(wanted)) { selected = file; break; }
                            if (selected == null) throw new IllegalArgumentException("Saved recording no longer exists; refresh the list.");
                            String before = identity(root, selected);
                            byte[] bytes = Files.readAllBytes(selected.toPath());
                            if (!before.equals(identity(root, selected)) || bytes.length > MAX_GPX_BYTES)
                                throw new IllegalStateException("Recording changed during import; try again after saving.");
                            String xml = new String(bytes, StandardCharsets.UTF_8);
                            if (!xml.contains("</gpx>")) throw new IllegalStateException("Recording has not finished saving.");
                            answer = bytes;
                        }
                        Object value = answer;
                        main.post(() -> result.success(value));
                    } catch (Exception e) {
                        main.post(() -> result.error("osmand_recording_read_failed", e.getMessage(), null));
                    }
                });
                return;
            }
            result.notImplemented();
        });
    }

    private static void collect(File root, File directory, List<File> found) throws Exception {
        File[] children = directory.listFiles();
        if (children == null) return;
        for (File child : children) {
            File canonical = child.getCanonicalFile();
            // Ignore links outside recorded tracks; never inspect active recording SQLite.
            if (!canonical.toPath().startsWith(root.toPath()) || !canonical.equals(child.getAbsoluteFile())) continue;
            if (canonical.isDirectory()) collect(root, canonical, found);
            else if (canonical.isFile() && canonical.getName().endsWith(".gpx")
                    && canonical.length() > 0 && canonical.length() <= MAX_GPX_BYTES) found.add(canonical);
        }
    }

    private static String identity(File root, File file) throws Exception {
        String value = root.toPath().relativize(file.toPath()) + ":" + file.length() + ":" + file.lastModified();
        byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
        StringBuilder hex = new StringBuilder();
        for (byte b : digest) hex.append(String.format(java.util.Locale.ROOT, "%02x", b & 255));
        return hex.toString();
    }

    private static synchronized void registerMapLifecycle(OsmandApplication app) {
        if (lifecycleRegistered) return;
        lifecycleRegistered = true;
        app.registerActivityLifecycleCallbacks(new Application.ActivityLifecycleCallbacks() {
            @Override public void onActivityResumed(Activity activity) {
                if (!(activity instanceof MapActivity)) return;
                addReturnButton(activity);
                if (recordingRequested) showRecorderWhenReady(app, (MapActivity) activity);
            }
            @Override public void onActivityCreated(Activity a, Bundle b) { }
            @Override public void onActivityStarted(Activity a) { }
            @Override public void onActivityPaused(Activity a) { }
            @Override public void onActivityStopped(Activity a) { }
            @Override public void onActivitySaveInstanceState(Activity a, Bundle b) { }
            @Override public void onActivityDestroyed(Activity a) { }
        });
    }

    private static void addReturnButton(Activity activity) {
        if (activity.getWindow().getDecorView().findViewWithTag("endurain-return") != null) return;
        Button button = new Button(activity);
        button.setTag("endurain-return");
        button.setText(net.osmand.plus.R.string.endurain_return_to_frontend);
        button.setContentDescription(activity.getString(net.osmand.plus.R.string.endurain_return_to_frontend));
        button.setOnClickListener(v -> activity.startActivity(new Intent(activity, EndurainFlutterActivity.class)
                .addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)));
        FrameLayout.LayoutParams position = new FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.WRAP_CONTENT, FrameLayout.LayoutParams.WRAP_CONTENT, Gravity.TOP | Gravity.CENTER_HORIZONTAL);
        position.topMargin = activity.getResources().getDimensionPixelSize(net.osmand.plus.R.dimen.endurain_return_button_top_margin);
        activity.addContentView(button, position);
    }

    private static void showRecorderWhenReady(OsmandApplication app, MapActivity activity) {
        activity.getWindow().getDecorView().postDelayed(() -> {
            if (activity.isFinishing() || activity.isDestroyed() || !recordingRequested) return;
            if (app.isApplicationInitializing() || activity.getSupportFragmentManager().isStateSaved()) {
                showRecorderWhenReady(app, activity);
                return;
            }
            OsmandMonitoringPlugin plugin = PluginsHelper.getPlugin(OsmandMonitoringPlugin.class);
            if (plugin != null) {
                PluginsHelper.enablePlugin(activity, app, plugin, true);
                recordingRequested = false;
                plugin.askShowTripRecordingDialog(activity);
            }
        }, 250);
    }

    @Override public void cleanUpFlutterEngine(@NonNull FlutterEngine engine) {
        if (channel != null) channel.setMethodCallHandler(null);
        channel = null;
        if (deviceSettings != null) deviceSettings.setMethodCallHandler(null);
        deviceSettings = null;
        if (files != null) files.shutdown();
        super.cleanUpFlutterEngine(engine);
    }
}
