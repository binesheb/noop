package com.noop.analytics

import java.util.Locale

/** Deterministic, non-diagnostic CSV export of the on-device RhythmScreener output. */
object RhythmExport {
    const val disclaimer: String =
        "NOOP Rhythm export — experimental wellness visualization, NOT a diagnosis. Not an ECG and " +
            "not a medical device; it cannot detect any heart condition. Beat-to-beat variation has many " +
            "ordinary, benign causes (breathing, movement, an imperfect optical reading, or the occasional " +
            "extra or skipped beat most healthy people have). Everything was computed on your device. " +
            "Share with a qualified professional if you wish; in an emergency, contact your local emergency service."

    const val header: String =
        "window,beats,sd1_ms,sd2_ms,sd1_sd2,norm_rmssd,turning_point_rate,ectopic_fraction,label,confidence"

    fun csv(summary: RhythmScreener.NightRhythmSummary, windows: List<RhythmScreener.WindowResult>): String {
        val lines = ArrayList<String>()
        for (chunk in disclaimer.split("\n")) lines.add("# $chunk")
        lines.add("#")
        lines.add(
            "# summary: readableWindows=${summary.readableWindows} steady=${summary.steadyWindows} " +
                "occasional=${summary.occasionalWindows} varied=${summary.variedWindows} " +
                "overall=${summary.overall.raw} variationRecurred=${summary.variationRecurred}",
        )
        lines.add("#")
        lines.add(header)
        windows.forEachIndexed { i, w ->
            lines.add(
                listOf(
                    (i + 1).toString(), w.nBeats.toString(), num(w.sd1), num(w.sd2), num(w.sd1sd2),
                    num(w.normRmssd), num(w.turningPointRate), num(w.ectopicFraction),
                    w.label.raw, w.confidence.raw,
                ).joinToString(","),
            )
        }
        return lines.joinToString("\n")
    }

    private fun num(x: Double?): String =
        if (x == null) "" else String.format(Locale.US, "%.3f", Math.round(x * 1000).toDouble() / 1000)
}
