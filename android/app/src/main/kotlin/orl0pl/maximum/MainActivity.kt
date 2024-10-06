package orl0pl.maximum

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.text.SimpleDateFormat
import java.util.*

class MainActivity: FlutterActivity() {
    private val alarmChannel = "orl0pl.maximum/alarm"

    override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    val binaryMessenger = flutterEngine?.dartExecutor?.binaryMessenger ?: return

    MethodChannel(binaryMessenger, alarmChannel).setMethodCallHandler { call, result ->
        if (call.method == "getNextAlarm") {
            val nextAlarm = getNextAlarm()
            result.success(nextAlarm)
        } else {
            result.notImplemented()
        }
    }
}

    private fun getNextAlarm(): Long? {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val alarmInfo = alarmManager.nextAlarmClock

        return if (alarmInfo != null) {
            alarmInfo.triggerTime
        } else {
            null
        }
    }
}
