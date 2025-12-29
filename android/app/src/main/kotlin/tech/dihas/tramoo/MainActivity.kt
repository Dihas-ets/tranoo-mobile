package tech.dihas.tramoo

import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Activer l'affichage bord à bord pour Android 15+ (SDK 35+)
        // Cette API remplace les méthodes obsolètes setStatusBarColor, setNavigationBarColor, etc.
        if (Build.VERSION.SDK_INT >= 35) {
            WindowCompat.setDecorFitsSystemWindows(window, false)
        }
        super.onCreate(savedInstanceState)
    }
}
