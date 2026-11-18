package com.example.wallhaven_client

import android.app.WallpaperManager
import android.content.Intent
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val channelName = "wallhaven_client/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val path = call.argument<String>("path")
                        if (path == null) {
                            result.error("bad_args", "path missing", null)
                            return@setMethodCallHandler
                        }
                        // WallpaperManager I/O is slow: run off the UI thread.
                        Thread {
                            try {
                                val manager =
                                    WallpaperManager.getInstance(applicationContext)
                                val file = File(path)
                                FileInputStream(file).use { stream ->
                                    manager.setStream(stream)
                                }
                                runOnUiThread { result.success(true) }
                            } catch (e: Exception) {
                                runOnUiThread {
                                    result.error("wallpaper_error", e.message, null)
                                }
                            }
                        }.start()
                    }
                    "startBackgroundService" -> {
                        val intent = Intent(this, WallpaperSchedulerService::class.java)
                        intent.putExtra(
                            "intervalMinutes",
                            (call.argument<Number>("intervalMinutes")?.toLong()) ?: 30L,
                        )
                        intent.putExtra("config", call.argument<String>("config") ?: "")
                        ContextCompat.startForegroundService(this, intent)
                        result.success(true)
                    }
                    "stopBackgroundService" -> {
                        val intent = Intent(this, WallpaperSchedulerService::class.java)
                        intent.putExtra("action", "stop")
                        startService(intent)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
