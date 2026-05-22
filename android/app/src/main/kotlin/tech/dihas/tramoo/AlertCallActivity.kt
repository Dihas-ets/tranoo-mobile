package tech.dihas.tramoo

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/** Activité plein écran pour alertes (écran verrouillé / hors app). */
class AlertCallActivity : FlutterActivity() {

    companion object {
        const val CHANNEL = "tranoo/alert_launch"
        const val EXTRA_PAYLOAD = "alert_payload"
        const val EXTRA_TITLE = "alert_title"
        const val EXTRA_BODY = "alert_body"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        }
        window.addFlags(
            WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED,
        )
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getPayload" -> {
                        result.success(intent.getStringExtra(EXTRA_PAYLOAD))
                    }
                    "getTitle" -> {
                        result.success(intent.getStringExtra(EXTRA_TITLE))
                    }
                    "getBody" -> {
                        result.success(intent.getStringExtra(EXTRA_BODY))
                    }
                    "finishAlert" -> {
                        finish()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
