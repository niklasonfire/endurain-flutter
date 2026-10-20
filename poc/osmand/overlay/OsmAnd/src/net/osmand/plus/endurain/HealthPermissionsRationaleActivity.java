package net.osmand.plus.endurain;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

/** Health Connect privacy rationale, matching the Endurain client. */
public class HealthPermissionsRationaleActivity extends Activity {
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TextView text = new TextView(this);
        text.setText("Endurain health data\n\nEndurain reads workouts, routes, heart rate, distance, calories, and steps only to import selected activities.\n\nSelected route data is stored on this device and uploaded only to the Endurain server you connect.");
        text.setPadding(48, 48, 48, 48);
        setContentView(text);
    }
}
