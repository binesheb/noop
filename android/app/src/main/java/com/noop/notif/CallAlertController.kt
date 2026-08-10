package com.noop.notif

import android.content.Context
import android.os.Handler
import android.os.Looper
import com.noop.NoopApplication
import com.noop.ui.NotifPrefs

internal enum class CallAlertSource {
    PHONE,
    VOIP,
}

/**
 * Shared call-buzz coordinator for native phone state and strict VoIP notifications.
 *
 * This is intentionally a small state machine: phone/VoIP sources acquire tokens, while one
 * scheduler owns the physical WHOOP actuator. That prevents two simultaneous call sources from
 * doubling the haptic traffic.
 */
internal object CallAlertController {
    /**
     * Hard ceiling on one call cycle. A stop event is not guaranteed — PHONE_STATE=IDLE can be
     * dropped and a VoIP notification can disappear without a removal callback. Five minutes is
     * long enough for legitimate calls while still self-healing a leaked token.
     */
    private const val MAX_RING_WINDOW_MS = 5 * 60_000L

    private val handler = Handler(Looper.getMainLooper())
    private val policy = CallAlertPolicy()
    private val activeTokens = linkedSetOf<String>()
    private var buzzCount = 0
    private var lastBuzzAtMs: Long? = null
    private var appContext: Context? = null

    private val repeatRunnable = object : Runnable {
        override fun run() {
            val ctx = appContext ?: return
            maybeBuzz(ctx)
        }
    }

    /** Self-heal a leaked source if Android never delivers its stop event. */
    private val maxRingRunnable = Runnable { stopAll() }

    fun start(context: Context, source: CallAlertSource, key: String = source.name): Boolean {
        if (!sourceEnabled(context, source)) return false
        appContext = context.applicationContext
        val token = "${source.name}:$key"
        val wasInactive = activeTokens.isEmpty()
        activeTokens.add(token)

        // Re-arm the watchdog whenever the source reports life. This prevents a dropped stop
        // event from permanently wedging the next call cycle.
        handler.removeCallbacks(maxRingRunnable)
        handler.postDelayed(maxRingRunnable, MAX_RING_WINDOW_MS)

        if (wasInactive) {
            buzzCount = 0
            lastBuzzAtMs = null
            handler.removeCallbacks(repeatRunnable)
            maybeBuzz(context.applicationContext)
        }
        return true
    }

    fun stop(source: CallAlertSource, key: String = source.name) {
        activeTokens.remove("${source.name}:$key")
        if (activeTokens.isEmpty()) resetLoop()
    }

    fun stopSource(source: CallAlertSource) {
        activeTokens.removeAll { it.startsWith("${source.name}:") }
        if (activeTokens.isEmpty()) resetLoop()
    }

    fun stopAll() {
        activeTokens.clear()
        resetLoop()
    }

    private fun maybeBuzz(context: Context) {
        pruneDisabledSources(context)
        if (activeTokens.isEmpty()) return

        val now = System.currentTimeMillis()
        if (!policy.shouldBuzz(true, buzzCount, lastBuzzAtMs, now)) return

        // Do not consume a call-alert slot while the strap is temporarily disconnected. The
        // existing connection service can recover the BLE link, and the next policy tick will
        // retry the same call instead of silently losing the alert.
        if (!deliveryAllowed(context)) {
            scheduleNext()
            return
        }

        val ble = (context.applicationContext as? NoopApplication)?.ble ?: run {
            scheduleNext()
            return
        }

        ble.buzz(NotifPrefs.callLoops(context))
        buzzCount += 1
        lastBuzzAtMs = now
        scheduleNext()
    }

    private fun scheduleNext() {
        handler.removeCallbacks(repeatRunnable)
        val delay = policy.nextDelayMs(buzzCount) ?: return
        if (activeTokens.isNotEmpty()) handler.postDelayed(repeatRunnable, delay)
    }

    private fun resetLoop() {
        handler.removeCallbacks(repeatRunnable)
        handler.removeCallbacks(maxRingRunnable)
        buzzCount = 0
        lastBuzzAtMs = null
    }

    private fun pruneDisabledSources(context: Context) {
        activeTokens.removeAll { token ->
            val source = if (token.startsWith("${CallAlertSource.PHONE.name}:")) {
                CallAlertSource.PHONE
            } else {
                CallAlertSource.VOIP
            }
            !sourceEnabled(context, source)
        }
        if (activeTokens.isEmpty()) resetLoop()
    }

    private fun sourceEnabled(context: Context, source: CallAlertSource): Boolean {
        if (!NotifPrefs.getBool(context, NotifPrefs.MASTER, false)) return false
        if (!NotifPrefs.getBool(context, NotifPrefs.CALLS_MASTER, false)) return false
        return when (source) {
            CallAlertSource.PHONE -> NotifPrefs.getBool(context, NotifPrefs.CALLS_PHONE, false)
            CallAlertSource.VOIP -> NotifPrefs.getBool(context, NotifPrefs.CALLS_VOIP, false)
        }
    }

    private fun deliveryAllowed(context: Context): Boolean {
        if (!NotifPrefs.getBool(context, NotifPrefs.MASTER, false)) return false
        if (!NotifPrefs.getBool(context, NotifPrefs.CALLS_MASTER, false)) return false
        if (NotifPrefs.inQuietHours(context)) return false

        val ble = (context.applicationContext as? NoopApplication)?.ble ?: return false
        val state = ble.state.value
        // `bonded` can remain true after a transient GATT disconnect. A haptic command sent in
        // that window would be lost but would still count as a buzz, so require an active link.
        if (!state.connected || !state.bonded) return false
        if (NotifPrefs.getBool(context, NotifPrefs.WORN, true) && !state.worn) return false
        return true
    }
}
