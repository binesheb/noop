package com.noop.notif

/**
 * Pure policy for repeated call buzzes.
 *
 * The controller owns Android scheduling and BLE delivery. Keeping the cadence here makes
 * the behaviour deterministic and unit-testable.
 *
 * Defaults are deliberately conservative: an incoming call gets an immediate buzz, followed
 * by a small number of reminders. We do not buzz indefinitely because the WHOOP motor is a
 * wearable haptic actuator and a never-ending loop would be intrusive and waste battery.
 */
internal data class CallAlertPolicy(
    val repeatIntervalMs: Long = 6_000L,
    val maxBuzzes: Int = 6,
) {
    init {
        require(repeatIntervalMs > 0) { "repeatIntervalMs must be positive" }
        require(maxBuzzes >= 1) { "maxBuzzes must be at least 1" }
    }

    fun shouldBuzz(active: Boolean, buzzCount: Int, lastBuzzAtMs: Long?, nowMs: Long): Boolean {
        if (!active || buzzCount >= maxBuzzes) return false
        return lastBuzzAtMs == null || nowMs - lastBuzzAtMs >= repeatIntervalMs
    }

    fun nextDelayMs(buzzCount: Int): Long? =
        if (buzzCount < maxBuzzes) repeatIntervalMs else null
}
