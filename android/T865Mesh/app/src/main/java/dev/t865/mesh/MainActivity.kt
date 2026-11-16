package dev.t865.mesh

import android.Manifest
import android.app.Activity
import android.content.*
import android.os.*
import android.view.WindowInsets
import android.widget.*

class MainActivity : Activity() {
    private val handler = Handler(Looper.getMainLooper())
    private lateinit var log: TextView
    private lateinit var state: TextView
    private lateinit var message: EditText
    private lateinit var destination: EditText
    private lateinit var channel: EditText
    private lateinit var baud: EditText
    private lateinit var exclusive: CheckBox
    private lateinit var power: CheckBox
    private val refresh = object : Runnable {
        override fun run() {
            if (::log.isInitialized) { log.text = MeshService.snapshot; state.text = MeshService.state }
            handler.postDelayed(this, 500)
        }
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val layout = LinearLayout(this).apply { orientation = LinearLayout.VERTICAL; setPadding(24, 24, 24, 24) }
        layout.setOnApplyWindowInsetsListener { view, insets ->
            if (Build.VERSION.SDK_INT >= 30) {
                val bars = insets.getInsets(WindowInsets.Type.systemBars() or WindowInsets.Type.displayCutout())
                view.setPadding(24 + bars.left, 24 + bars.top, 24 + bars.right, 24 + bars.bottom)
            }; insets
        }
        fun label(text: String, size: Float = 15f) = TextView(this).apply { this.text = text; textSize = size }.also { layout.addView(it) }
        fun button(text: String, action: () -> Unit) = Button(this).apply { this.text = text; setOnClickListener { action() } }.also { layout.addView(it) }
        fun edit(hint: String, value: String) = EditText(this).apply { this.hint = hint; setText(value); isSingleLine = true }.also { layout.addView(it) }
        label("T865 Mesh Bench", 24f)
        label("USB peer: official node handles RF and routing.\nE220: UART capture only; stock Meshtastic RF compatibility is unverified. Native Rust mesh runs in bench tests.")
        state = label("Stopped", 18f)
        button("Run Rust mesh self-test") { launch("selftest") }
        button("Connect to computer’s USB node") { launch("connect") }
        destination = edit("Destination hex (!ffffffff = broadcast)", "!ffffffff")
        channel = edit("Peer channel index", "0")
        message = edit("Message", "T865 interoperability test")
        button("Send once through USB node") {
            launch("send") { putExtra("text", message.text.toString()); putExtra("to", destination.text.toString()); putExtra("channel", channel.text.toString().toIntOrNull() ?: -1) }
        }
        baud = edit("E220 UART baud", "9600")
        exclusive = CheckBox(this).apply { text = "DMD LoRa and UART TX app are stopped; I own WK2" }
        layout.addView(exclusive)
        power = CheckBox(this).apply { text = "Module starts OFF: enable expansion power, then turn OFF on Stop" }
        layout.addView(power)
        button("Capture E220 UART (no writes)") { launch("capture") { putExtra("baud", baud.text.toString().toIntOrNull() ?: 0); putExtra("exclusive", exclusive.isChecked); putExtra("power", power.isChecked) } }
        button("Stop / release connection") { launch("stop") }
        button("Copy report") {
            (getSystemService(CLIPBOARD_SERVICE) as ClipboardManager).setPrimaryClip(ClipData.newPlainText("T865 Mesh report", MeshService.snapshot))
            Toast.makeText(this, "Report copied", Toast.LENGTH_SHORT).show()
        }
        log = label("No session started.", 12f).apply { setTextIsSelectable(true); typeface = android.graphics.Typeface.MONOSPACE }
        setContentView(ScrollView(this).apply { addView(layout) })
        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != android.content.pm.PackageManager.PERMISSION_GRANTED) requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 1)
        handle(intent)
    }
    private fun launch(command: String, extras: Intent.() -> Unit = {}) {
        startForegroundService(Intent(this, MeshService::class.java).putExtra("command", command).apply(extras))
    }
    private fun handle(input: Intent) {
        val command = input.getStringExtra("command") ?: return
        if (command !in listOf("selftest", "connect", "capture", "send", "stop", "decode")) return
        launch(command) { input.extras?.let { putExtras(it) } }
        // Don't replay a test or transmission after Activity recreation.
        input.removeExtra("command")
    }
    override fun onNewIntent(intent: Intent) { super.onNewIntent(intent); handle(intent) }
    override fun onStart() { super.onStart(); handler.post(refresh) }
    override fun onStop() { handler.removeCallbacks(refresh); super.onStop() }
}
