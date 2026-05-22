package tech.dihas.tramoo

import android.content.Intent
import com.google.firebase.messaging.RemoteMessage
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService
import org.json.JSONObject

/**
 * Ouvre l'écran appel plein écran dès réception d'une alerte (app en arrière-plan).
 */
class TranooAlertMessagingService : FlutterFirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        if (isAlertMessage(data)) {
            try {
                val payload = JSONObject(data as Map<*, *>).toString()
                val intent = Intent(applicationContext, AlertCallActivity::class.java).apply {
                    addFlags(
                        Intent.FLAG_ACTIVITY_NEW_TASK or
                            Intent.FLAG_ACTIVITY_SINGLE_TOP or
                            Intent.FLAG_ACTIVITY_CLEAR_TOP,
                    )
                    putExtra(AlertCallActivity.EXTRA_PAYLOAD, payload)
                    putExtra(
                        AlertCallActivity.EXTRA_TITLE,
                        message.notification?.title
                            ?: data["title"]
                            ?: "Nouvelle proposition",
                    )
                    putExtra(
                        AlertCallActivity.EXTRA_BODY,
                        message.notification?.body
                            ?: data["message"]
                            ?: data["body"]
                            ?: "Un vendeur a répondu à votre alerte",
                    )
                }
                applicationContext.startActivity(intent)
            } catch (_: Exception) {
                // fallback: FCM / Dart handler
            }
        }
        super.onMessageReceived(message)
    }

    private fun isAlertMessage(data: Map<String, String>): Boolean {
        val type = data["type"] ?: ""
        if (type == "alerte" || type == "proposition_alerte") return true
        if (data["action"] == "view_proposal") return true
        val requestType = data["requestType"] ?: ""
        return requestType == "vehicle_search" || requestType == "piece_search"
    }
}
