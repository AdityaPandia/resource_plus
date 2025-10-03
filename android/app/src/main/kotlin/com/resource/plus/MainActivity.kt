package com.resource.plus

import android.content.Intent
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.resource.plus.core.SipService

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.resource.plus/sip_service"
    private var sipServiceIntent: Intent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        sipServiceIntent = Intent(this, SipService::class.java)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    try {
                        startForegroundService(sipServiceIntent!!)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Failed to start service: ${e.message}", null)
                    }
                }
                "stopService" -> {
                    try {
                        stopService(sipServiceIntent!!)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("SERVICE_ERROR", "Failed to stop service: ${e.message}", null)
                    }
                }
                "isServiceRunning" -> {
                    // Simple check - in a real implementation you'd track service state
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
