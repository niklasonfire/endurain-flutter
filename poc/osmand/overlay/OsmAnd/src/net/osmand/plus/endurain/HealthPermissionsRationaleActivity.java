package net.osmand.plus.endurain;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;
import net.osmand.plus.R;

/** Health Connect privacy rationale, matching the Endurain client. */
public class HealthPermissionsRationaleActivity extends Activity {
    @Override public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TextView text = new TextView(this);
        text.setText(R.string.endurain_health_rationale);
        text.setPadding(48, 48, 48, 48);
        setContentView(text);
    }
}
