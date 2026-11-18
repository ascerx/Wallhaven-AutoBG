package com.example.wallhaven_client

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.app.WallpaperManager
import android.content.Context
import android.content.Intent
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.io.FileInputStream
import java.net.HttpURLConnection
import java.net.URL
import java.net.URLEncoder
import kotlin.random.Random

/**
 * Foreground service that keeps rotating wallpapers with the app closed.
 *
 * Runs fully natively: reads the saved search config from the app's
 * SharedPreferences, calls the Wallhaven API, downloads a random wallpaper
 * and applies it with WallpaperManager. Survives the app being swiped away
 * (START_STICKY) and shows a persistent low-priority notification.
 */
class WallpaperSchedulerService : Service() {
    private val handler = Handler(Looper.getMainLooper())
    private val channelId = "wallhaven_background"
    private var intervalMinutes = 30L
    private var configJson = ""
    private var running = false

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.getStringExtra("action") == "stop") {
            handler.removeCallbacksAndMessages(null)
            running = false
            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
            return START_NOT_STICKY
        }
        intervalMinutes = intent?.getLongExtra("intervalMinutes", 30L) ?: 30L
        configJson = intent?.getStringExtra("config") ?: ""
        startForeground(1, buildNotification())
        if (!running) {
            running = true
            scheduleNext(0) // first change right away
        }
        return START_STICKY
    }

    private fun scheduleNext(delayMinutes: Long) {
        handler.postDelayed({ doChange() }, delayMinutes * 60_000)
    }

    private fun doChange() {
        Thread {
            try {
                applyRandomWallpaper()
            } catch (e: Exception) {
                android.util.Log.w("WallhavenAutoBG", "rotation failed: ${e.message}")
            }
            if (running) scheduleNext(intervalMinutes)
        }.start()
    }

    private fun applyRandomWallpaper() {
        val cfg = if (configJson.isNotEmpty()) JSONObject(configJson) else JSONObject()
        val apiKey = readApiKey()
        val collectionUser = cfg.optString("collectionUser", "")
        val collectionId = cfg.optString("collectionId", "")

        val params = StringBuilder()
        params.append("purity=").append(cfg.purityParam(hasApiKey = apiKey.isNotEmpty()))
        if (collectionUser.isNotEmpty() && collectionId.isNotEmpty() && collectionId != "null") {
            // Collections only support the purity filter.
        } else {
            params.append("&categories=").append(cfg.categoriesParam())
            val query = cfg.optString("query", "")
            if (query.isNotEmpty()) {
                params.append("&q=").append(URLEncoder.encode(query, "UTF-8"))
            }
            val atleast = cfg.optString("atleast", "")
            if (atleast.isNotEmpty() && atleast != "null") {
                params.append("&atleast=").append(atleast)
            }
            joinListParam(cfg, "ratios")?.let { params.append("&ratios=").append(it) }
            joinListParam(cfg, "resolutions")?.let { params.append("&resolutions=").append(it) }
            val color = cfg.optString("color", "")
            if (color.isNotEmpty() && color != "null") {
                params.append("&colors=").append(color)
            }
            val sorting = cfg.optString("sorting", "random")
            params.append("&sorting=").append(sorting)
            params.append("&order=").append(cfg.optString("order", "desc"))
            if (sorting == "toplist") {
                params.append("&topRange=").append(cfg.optString("topRange", "1M"))
            }
        }
        params.append("&page=").append(Random.nextInt(1, 6))

        val path = if (collectionUser.isNotEmpty() && collectionId.isNotEmpty() && collectionId != "null") {
            "/api/v1/collections/$collectionUser/$collectionId"
        } else {
            "/api/v1/search"
        }
        val url = URL("https://wallhaven.cc$path?$params")
        val conn = url.openConnection() as HttpURLConnection
        conn.connectTimeout = 15000
        conn.readTimeout = 30000
        if (apiKey.isNotEmpty()) conn.setRequestProperty("X-API-Key", apiKey)
        val body = conn.inputStream.bufferedReader().use { it.readText() }
        val json = JSONObject(body)
        val data = json.getJSONArray("data")
        if (data.length() == 0) throw Exception("no results")
        val pick = data.getJSONObject(Random.nextInt(data.length()))
        val fileUrl = pick.getString("path")
        val id = pick.getString("id")

        val dir = File(getFilesDir(), "wallpapers")
        dir.mkdirs()
        val ext = if (fileUrl.endsWith(".png")) "png" else "jpg"
        val outFile = File(dir, "wallhaven-$id.$ext")
        val dlConn = URL(fileUrl).openConnection() as HttpURLConnection
        dlConn.connectTimeout = 15000
        dlConn.readTimeout = 60000
        dlConn.inputStream.use { input ->
            outFile.outputStream().use { output -> input.copyTo(output) }
        }

        val manager = WallpaperManager.getInstance(this)
        FileInputStream(outFile).use { manager.setStream(it) }
    }

    private fun JSONObject.listValues(key: String): List<String> {
        val arr = optJSONArray(key) ?: return emptyList()
        return (0 until arr.length()).map { arr.getString(it) }
    }

    private fun joinListParam(cfg: JSONObject, key: String): String? {
        val values = cfg.listValues(key)
        return if (values.isEmpty()) null else values.joinToString(",")
    }

    private fun JSONObject.categoriesParam(): String {
        val selected = listValues("categories")
        fun flag(name: String) = if (selected.contains(name)) '1' else '0'
        return "${flag("general")}${flag("anime")}${flag("people")}"
    }

    private fun JSONObject.purityParam(hasApiKey: Boolean): String {
        var selected = listValues("purity")
        if (!hasApiKey) selected = selected.filter { it != "nsfw" }
        if (selected.isEmpty()) return "100"
        fun flag(name: String) = if (selected.contains(name)) '1' else '0'
        return "${flag("sfw")}${flag("sketchy")}${flag("nsfw")}"
    }

    private fun readApiKey(): String {
        val prefs = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
        val raw = prefs.getString("flutter.wallhaven.settings.v1", "") ?: ""
        return try {
            JSONObject(raw).optString("apiKey", "")
        } catch (e: Exception) {
            ""
        }
    }

    private fun buildNotification(): Notification {
        val nm = getSystemService(NotificationManager::class.java)
        if (android.os.Build.VERSION.SDK_INT >= 26) {
            nm.createNotificationChannel(
                NotificationChannel(
                    channelId, "Wallhaven AutoBG",
                    NotificationManager.IMPORTANCE_LOW,
                ),
            )
        }
        val launch = packageManager.getLaunchIntentForPackage(packageName)
        val pi = PendingIntent.getActivity(
            this, 0, launch,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val builder = if (android.os.Build.VERSION.SDK_INT >= 26) {
            Notification.Builder(this, channelId)
        } else {
            Notification.Builder(this)
        }
        builder
            .setContentTitle("Wallhaven AutoBG")
            .setContentText("Rotating wallpapers automatically")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pi)
            .setOngoing(true)
        return builder.build()
    }
}
