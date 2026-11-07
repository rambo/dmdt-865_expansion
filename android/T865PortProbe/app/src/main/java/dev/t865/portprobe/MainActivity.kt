package dev.t865.portprobe

import android.app.Activity
import android.app.AlertDialog
import android.content.ClipData
import android.content.ClipboardManager
import android.graphics.Typeface
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import android.widget.Toast
import java.time.Instant
import java.util.concurrent.Executors

class MainActivity : Activity() {
    private external fun inspect(probeDevices: Boolean): ByteArray

    private val worker = Executors.newSingleThreadExecutor()
    private lateinit var reportView: TextView
    private lateinit var status: TextView
    private lateinit var scanButton: Button
    private lateinit var probeButton: Button
    private var report = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(16, 16, 16, 16)
        }
        root.setOnApplyWindowInsetsListener { view, insets ->
            if (Build.VERSION.SDK_INT >= 30) {
                val bars = insets.getInsets(WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout())
                view.setPadding(bars.left + 16, bars.top + 16, bars.right + 16, bars.bottom + 16)
            } else {
                @Suppress("DEPRECATION")
                view.setPadding(insets.systemWindowInsetLeft + 16, insets.systemWindowInsetTop + 16,
                    insets.systemWindowInsetRight + 16, insets.systemWindowInsetBottom + 16)
            }
            insets
        }
        root.addView(TextView(this).apply {
            text = "T865 Port Probe"
            textSize = 22f
            accessibilityHeadingCompat()
        })
        root.addView(TextView(this).apply {
            text = "Metadata first. Optional probe opens and immediately closes devices; no device reads, writes, ioctl or serial configuration. Open/close itself may affect hardware."
        })
        scanButton = Button(this).apply {
            text = "Inspect metadata"
            setOnClickListener { runInspection(false) }
        }
        probeButton = Button(this).apply {
            text = "Probe read-only opens…"
            setOnClickListener {
                AlertDialog.Builder(this@MainActivity)
                    .setTitle("Open device nodes?")
                    .setMessage("This opens /dev/ttysWK0–3, /dev/spidev0.1–0.6 and other discovered numeric SPI nodes, then closes them. /dev/spidev0.0 is excluded because it may serve the SPI-UART. Opens are read-only and nonblocking; no device data is read or written and no configuration calls are made. Vendor open/close handlers may change power or signals. Use metadata only if zero hardware interaction is required.")
                    .setNegativeButton("Cancel", null)
                    .setPositiveButton("Open and close") { _, _ -> runInspection(true) }
                    .show()
            }
        }
        root.addView(scanButton)
        root.addView(probeButton)
        root.addView(Button(this).apply {
            text = "Copy report"
            setOnClickListener {
                getSystemService(ClipboardManager::class.java)
                    .setPrimaryClip(ClipData.newPlainText("T865 Port Probe", report))
                Toast.makeText(this@MainActivity, "Report copied", Toast.LENGTH_SHORT).show()
            }
        })
        status = TextView(this)
        root.addView(status)
        reportView = TextView(this).apply {
            typeface = Typeface.MONOSPACE
            textSize = 12f
            setTextIsSelectable(true)
        }
        root.addView(ScrollView(this).apply { addView(reportView) },
            LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, 0, 1f))
        setContentView(root)
        root.requestApplyInsets()
        runInspection(false)
    }

    private fun View.accessibilityHeadingCompat() {
        if (Build.VERSION.SDK_INT >= 28) isAccessibilityHeading = true
    }

    private fun runInspection(probe: Boolean) {
        scanButton.isEnabled = false
        probeButton.isEnabled = false
        status.text = if (probe) "Probing… vendor drivers may ignore nonblocking opens." else "Inspecting…"
        worker.execute {
            val result = try {
                "T865 Port Probe 1.1 — ${Instant.now()}\n" +
                    "Model: ${Build.MANUFACTURER} ${Build.MODEL}\n" +
                    "Android: ${Build.VERSION.RELEASE}, API ${Build.VERSION.SDK_INT}\n" +
                    "ABIs: ${Build.SUPPORTED_ABIS.joinToString()}\n" +
                    inspect(probe).toString(Charsets.UTF_8)
            } catch (error: Exception) {
                "Inspection failed: $error"
            } catch (error: UnsatisfiedLinkError) {
                "Native library unavailable: $error"
            }
            runOnUiThread {
                if (!isDestroyed) {
                    report = result
                    reportView.text = result
                    status.text = "Finished. Copy the report to retain it."
                    scanButton.isEnabled = true
                    probeButton.isEnabled = true
                }
            }
        }
    }

    override fun onDestroy() {
        worker.shutdown()
        super.onDestroy()
    }

    companion object {
        init { System.loadLibrary("portprobe") }
    }
}
