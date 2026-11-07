package dev.t865.uarttx

import android.app.Activity
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowInsets
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledFuture
import java.util.concurrent.TimeUnit

class MainActivity : Activity() {
    private external fun openUart()
    private external fun sendFrame(): Int
    private external fun readUart(): ByteArray
    private external fun closeUart()

    // Only the worker accesses the native session and scheduled task.
    private var task: ScheduledFuture<*>? = null
    private var receiver: ScheduledFuture<*>? = null
    private var opened = false
    private var count = 0L
    private lateinit var status: TextView
    private lateinit var start: Button
    private lateinit var stop: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL }
        root.setOnApplyWindowInsetsListener { view, insets ->
            if (Build.VERSION.SDK_INT >= 30) {
                val bars = insets.getInsets(WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout())
                view.setPadding(bars.left + 24, bars.top + 24, bars.right + 24, bars.bottom + 24)
            } else {
                @Suppress("DEPRECATION")
                view.setPadding(insets.systemWindowInsetLeft + 24, insets.systemWindowInsetTop + 24,
                    insets.systemWindowInsetRight + 24, insets.systemWindowInsetBottom + 24)
            }
            insets
        }
        root.addView(TextView(this).apply { text = "T865 UART TX"; textSize = 24f })
        root.addView(TextView(this).apply {
            text = "/dev/ttysWK2 · 9600 baud · 8N1 · no flow control\n" +
                "Sends ASCII UUUU T865 UART WK2 + CR/LF once per second.\n" +
                "Idle mode sends nothing and logs received bytes.\n" +
                "Writes to hardware. Keep DMD LoRa off. Stops when this app leaves the foreground."
        })
        start = Button(this).apply { text = "Start transmitting"; setOnClickListener { begin() } }
        stop = Button(this).apply { text = "Stop and restore UART"; setOnClickListener { halt() } }
        root.addView(start); root.addView(stop)
        root.addView(Button(this).apply {
            text = "Receive only / TX idle"
            setOnClickListener { holdIdle() }
        })
        status = TextView(this)
        root.addView(status)
        setContentView(root)
        idle("Stopped. No device opened.")
        handle(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handle(intent)
    }

    private fun handle(intent: Intent) {
        if (intent.getBooleanExtra("stop", false)) halt()
        else if (intent.getBooleanExtra("idle", false)) holdIdle()
        else if (intent.getBooleanExtra("start", false)) begin()
    }

    private fun holdIdle() {
        start.isEnabled = false
        stop.isEnabled = true
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        worker.execute {
            task?.cancel(false)
            task = null
            try {
                if (!opened) { openUart(); opened = true }
                monitorRx()
                val message = "UART IDLE: WK2 open at 9600/8N1; no writes; RX monitor active."
                Log.i(TAG, message)
                runOnUiThread {
                    if (!isDestroyed) { status.text = message; start.isEnabled = true }
                }
            } catch (error: Exception) {
                finishSession("Idle open failed: $error")
            }
        }
    }

    private fun monitorRx() {
        if (receiver != null) return
        receiver = worker.scheduleWithFixedDelay({
            try {
                val bytes = readUart()
                if (bytes.isNotEmpty()) {
                    val hex = bytes.joinToString(" ") { "%02X".format(it.toInt() and 255) }
                    val text = bytes.joinToString("") {
                        val value = it.toInt() and 255
                        if (value in 32..126 && value != 92) value.toChar().toString()
                        else "\\x%02X".format(value)
                    }
                    val message = "RX ${bytes.size} bytes hex=[$hex] ascii=[$text]"
                    Log.i(TAG, message)
                    runOnUiThread { if (!isDestroyed) status.text = message }
                }
            } catch (error: Exception) {
                finishSession("RX failed: $error")
            }
        }, 0, 50, TimeUnit.MILLISECONDS)
    }

    private fun idle(message: String) {
        if (isDestroyed) return
        start.isEnabled = true
        stop.isEnabled = false
        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        status.text = message
    }

    private fun begin() {
        if (!start.isEnabled) return
        start.isEnabled = false
        stop.isEnabled = true
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        status.text = "Opening WK2…"
        worker.execute {
            try {
                if (!opened) { openUart(); opened = true }
                monitorRx()
                count = 0
                Log.i(TAG, "OPEN /dev/ttysWK2 9600/8N1 raw, flow control off; app UID=${android.os.Process.myUid()}")
                task = worker.scheduleWithFixedDelay({
                    try {
                        val bytes = sendFrame()
                        count++
                        Log.i(TAG, "TX #$count $bytes bytes: UUUU T865 UART WK2\\r\\n")
                        runOnUiThread { if (!isDestroyed) status.text = "Transmitting: $count frames, $bytes bytes/frame" }
                    } catch (error: Exception) {
                        finishSession("TX failed: $error")
                    }
                }, 0, 1, TimeUnit.SECONDS)
            } catch (error: Exception) {
                finishSession("Open failed: $error")
            }
        }
    }

    private fun finishSession(message: String) {
        task?.cancel(false)
        task = null
        receiver?.cancel(false)
        receiver = null
        var result = message
        try { closeUart() } catch (error: Exception) { result += "\nRestore/close failed: $error" }
        opened = false
        Log.i(TAG, result)
        runOnUiThread { idle(result) }
    }

    private fun halt() {
        start.isEnabled = false
        stop.isEnabled = false
        worker.execute { finishSession("STOP: original termios restored and descriptor closed unless an error is shown.") }
    }

    override fun onStop() {
        halt()
        super.onStop()
    }

    companion object {
        private const val TAG = "T865UartTx"
        // One queue makes an old Activity's stop finish before a recreated Activity opens.
        private val worker = Executors.newSingleThreadScheduledExecutor()
        init { System.loadLibrary("uarttx") }
    }
}
