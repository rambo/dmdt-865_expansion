package dev.t865.mesh

import android.app.*
import android.content.Intent
import android.os.IBinder
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.util.Log
import org.json.JSONObject
import java.net.InetSocketAddress
import java.net.Socket
import java.net.SocketTimeoutException
import java.security.SecureRandom
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit

class MeshService : Service() {
    private val worker = Executors.newSingleThreadScheduledExecutor()
    private var poller: ScheduledFuture<*>? = null
    private var socket: Socket? = null
    private var uart = false
    private var powered = false
    @Volatile private var active = false
    private val main = Handler(Looper.getMainLooper())
    @Volatile private var latestStartId = 0
    @Volatile private var connectionRequestId = 0
    private var sessionStartId = 0
    private var idleStop: Runnable? = null
    private var wake: PowerManager.WakeLock? = null
    private var lastHeartbeat = 0L
    private var configDeadline = 0L
    private var ready = false
    private val report = StringBuilder()

    override fun onCreate() {
        super.onCreate()
        val channel = NotificationChannel(CHANNEL, "Active mesh connection", NotificationManager.IMPORTANCE_LOW)
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) { stopSelf(); return START_NOT_STICKY }
        latestStartId = startId
        idleStop?.let { main.removeCallbacks(it) }
        // No automatic radio startup after a process restart.
        val action = intent.getStringExtra("command") ?: "selftest"
        if (action == "connect" || action == "capture") connectionRequestId = startId
        startForeground(1, notification("T865 mesh bench: $action"))
        worker.execute {
            try {
                when (action) {
                    "connect" -> { sessionStartId = startId; connect() }
                    "capture" -> { sessionStartId = startId; capture(intent.getIntExtra("baud", 9600), intent.getBooleanExtra("exclusive", false), intent.getBooleanExtra("power", false)) }
                    "send" -> send(intent)
                    "stop" -> { closeSession(); scheduleIdleStop(startId) }
                    "decode" -> { decode(intent); if (!active) scheduleIdleStop(startId) }
                    else -> {
                        append("SELFTEST ${Native.call("selftest")}")
                        append("CAPABILITIES ${Native.call("capabilities")}")
                        if (!active) scheduleIdleStop(startId)
                    }
                }
            } catch (e: Exception) {
                append("ERROR ${e.message}")
                closeSession()
                scheduleIdleStop(startId)
            }
        }
        return START_NOT_STICKY
    }

    private fun scheduleIdleStop(startId: Int) {
        // ADB may deliver selftest/decode/connect in one burst. Defer idle teardown
        // so a completed one-shot cannot destroy a newer queued connection.
        main.post {
            if (latestStartId != startId || active) return@post
            idleStop?.let { main.removeCallbacks(it) }
            val stop = Runnable {
                if (latestStartId == startId && !active) {
                    stopForeground(STOP_FOREGROUND_REMOVE)
                    stopSelfResult(startId)
                }
            }
            idleStop = stop
            main.postDelayed(stop, 500)
        }
    }

    private fun notification(message: String): Notification {
        val open = PendingIntent.getActivity(this, 0, Intent(this, MainActivity::class.java), PendingIntent.FLAG_IMMUTABLE)
        val stop = PendingIntent.getService(this, 1, Intent(this, MeshService::class.java).putExtra("command", "stop"), PendingIntent.FLAG_IMMUTABLE)
        return Notification.Builder(this, CHANNEL).setSmallIcon(android.R.drawable.ic_menu_compass)
            .setContentTitle("T865 Mesh Bench").setContentText(message).setContentIntent(open)
            .setOngoing(true).addAction(Notification.Action.Builder(null, "Stop", stop).build()).build()
    }

    private fun holdWake() {
        wake = (getSystemService(POWER_SERVICE) as PowerManager).newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "T865Mesh:session").apply { acquire() }
    }

    private fun connect() {
        closeSession()
        append("Connecting to computer USB bridge at 127.0.0.1:4403. Routing runs on the official node in this mode.")
        val s = Socket()
        try { s.connect(InetSocketAddress("127.0.0.1", 4403), 3000) }
        catch (e: Exception) { s.close(); throw e }
        s.soTimeout = 100
        s.tcpNoDelay = true
        socket = s
        active = true
        holdWake()
        val nonce = SecureRandom().nextInt().toLong() and 0xffffffffL
        write(Native.call("api_start", "nonce" to nonce.coerceAtLeast(1)))
        lastHeartbeat = android.os.SystemClock.elapsedRealtime()
        configDeadline = lastHeartbeat + 20000
        ready = false
        state = "USB peer: waiting for config"
        poller = worker.scheduleWithFixedDelay({
            try {
                val bytes = ByteArray(512)
                val n = try { s.getInputStream().read(bytes) } catch (_: SocketTimeoutException) { 0 }
                if (n < 0) throw IllegalStateException("USB bridge disconnected")
                if (n > 0) {
                    val events = Native.call("api_feed", "hex" to Native.hex(bytes.copyOf(n))).getJSONArray("events")
                    for (i in 0 until events.length()) {
                        val event = events.getJSONObject(i)
                        if (event.optString("kind") == "config_complete" && event.optBoolean("matched")) {
                            ready = true
                            state = "USB peer: ready (official node routes)"
                        }
                        if (event.optString("kind") == "rebooted" && event.optBoolean("value") && ready) throw IllegalStateException("Peer rebooted; reconnect to reload config")
                        if (event.optString("kind") !in listOf("other", "config")) append("PEER $event")
                    }
                }
                val now = android.os.SystemClock.elapsedRealtime()
                if (!ready && now > configDeadline) throw IllegalStateException("Configuration handshake timed out")
                if (now - lastHeartbeat > 30000) { write(Native.call("api_heartbeat")); lastHeartbeat = now }
            } catch (e: Exception) { failSession(e) }
        }, 0, 20, TimeUnit.MILLISECONDS)
    }

    private fun capture(baud: Int, exclusive: Boolean, power: Boolean) {
        if (!exclusive) throw IllegalStateException("Confirm DMD LoRa and UART TX app are stopped before capture")
        closeSession()
        append("Opening WK2 at $baud/8N1 for RX capture. No UART writes. Read chunks are not RF packets.")
        if (power) {
            append("POWER ${Native.call("power_on")}; accepted ioctl does not prove voltage")
            powered = true
        }
        append("UART ${Native.call("uart_open", "baud" to baud)}")
        uart = true
        active = true
        holdWake()
        state = "E220 UART capture only; native RF TX blocked"
        poller = worker.scheduleWithFixedDelay({
            try {
                val hex = Native.call("uart_read").optString("stream_hex")
                if (hex.isNotEmpty()) append("UART_STREAM $hex")
            } catch (e: Exception) { failSession(e) }
        }, 0, 25, TimeUnit.MILLISECONDS)
    }

    private fun send(intent: Intent) {
        if (socket == null || !ready) throw IllegalStateException("Connect to the USB peer and wait for config first; E220 native RF transmit is unqualified")
        val destination = intent.getStringExtra("to") ?: "!ffffffff"
        val to = destination.removePrefix("!").toLongOrNull(16)
            ?.takeIf { it in 1..0xffffffffL } ?: throw IllegalArgumentException("Destination must be a valid nonzero hex node ID")
        val text = intent.getStringExtra("text") ?: throw IllegalArgumentException("Missing text")
        write(Native.call("api_text", "to" to to, "channel" to intent.getIntExtra("channel", 0), "hops" to intent.getIntExtra("hops", 3), "text" to text))
        append("SEND accepted by USB stream; official firmware allocates the packet ID. Awaiting peer queue/routing status; this is not delivery confirmation.")
    }

    private fun decode(intent: Intent) {
        val result = Native.call("raw_decode", "hex" to (intent.getStringExtra("frame") ?: ""),
            "name" to (intent.getStringExtra("name") ?: "LongFast"), "key_hex" to (intent.getStringExtra("key") ?: "01"))
        append("RAW_FRAME $result")

    }

    private fun write(result: JSONObject) {
        val s = socket ?: throw IllegalStateException("Disconnected")
        s.getOutputStream().write(Native.unhex(result.getString("bytes_hex")))
        s.getOutputStream().flush()
    }

    private fun failSession(error: Exception) {
        append("ERROR ${error.message}")
        closeSession()
        if (connectionRequestId == sessionStartId) scheduleIdleStop(latestStartId)
    }

    private fun closeSession() {
        poller?.cancel(false)
        poller = null
        socket?.let { s ->
            // Close the socket directly: no blocking shutdown write during disconnect.
            try { s.close() } catch (e: Exception) { append("CLOSE ${e.message}") }
        }
        socket = null
        if (uart) {
            try { append("UART ${Native.call("uart_close")}") } catch (e: Exception) { append("RESTORE ERROR ${e.message}") }
        }
        uart = false
        if (powered) {
            try { append("POWER ${Native.call("power_off")}") } catch (e: Exception) { append("POWER OFF ERROR ${e.message}") }
        }
        powered = false
        ready = false
        active = false
        wake?.let { if (it.isHeld) it.release() }
        wake = null
        state = "Stopped"
    }

    private fun append(text: String) {
        val line = "${java.time.Instant.now()} $text"
        Log.i("T865Mesh", line)
        report.append(line).append('\n')
        if (report.length > 24000) report.delete(0, report.length - 20000)
        snapshot = report.toString()
        // A bounded private report remains readable through run-as after the service stops.
        try { java.io.File(filesDir, "latest-report.md").writeText("# T865 Mesh Bench report\n\n```text\n${report}```\n") }
        catch (e: Exception) { Log.w("T865Mesh", "Cannot save report", e) }
    }

    override fun onDestroy() {
        idleStop?.let { main.removeCallbacks(it) }
        // Let in-flight IO finish before close; no close/read descriptor race.
        worker.execute { closeSession() }
        worker.shutdown()
        super.onDestroy()
    }
    override fun onBind(intent: Intent?): IBinder? = null
    companion object {
        private const val CHANNEL = "mesh_connection"
        @Volatile var snapshot = "No session started."
        @Volatile var state = "Stopped"
    }
}
