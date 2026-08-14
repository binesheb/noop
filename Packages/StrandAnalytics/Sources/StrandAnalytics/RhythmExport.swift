import Foundation

// RhythmExport.swift — a plain-text (CSV) export of the DESCRIPTIVE rhythm-screening data.
//
// NON-CLINICAL, by construction: this exports the already-computed RhythmScreener output,
// carries the screen's disclaimer with the artifact, and emits only neutral labels.
public enum RhythmExport {
    public static let disclaimer: String =
        "NOOP Rhythm export — experimental wellness visualization, NOT a diagnosis. Not an ECG and "
        + "not a medical device; it cannot detect any heart condition. Beat-to-beat variation has many "
        + "ordinary, benign causes (breathing, movement, an imperfect optical reading, or the occasional "
        + "extra or skipped beat most healthy people have). Everything was computed on your device. "
        + "Share with a qualified professional if you wish; in an emergency, contact your local emergency service."

    static let header =
        "window,beats,sd1_ms,sd2_ms,sd1_sd2,norm_rmssd,turning_point_rate,ectopic_fraction,label,confidence"

    public static func csv(summary: RhythmScreener.NightRhythmSummary,
                           windows: [RhythmScreener.WindowResult]) -> String {
        var lines: [String] = []
        for chunk in disclaimer.split(separator: "\n", omittingEmptySubsequences: false) {
            lines.append("# \(chunk)")
        }
        lines.append("#")
        lines.append("# summary: readableWindows=\(summary.readableWindows) steady=\(summary.steadyWindows) "
            + "occasional=\(summary.occasionalWindows) varied=\(summary.variedWindows) "
            + "overall=\(summary.overall.rawValue) variationRecurred=\(summary.variationRecurred)")
        lines.append("#")
        lines.append(header)
        for (i, w) in windows.enumerated() {
            lines.append([
                String(i + 1), String(w.nBeats), num(w.sd1), num(w.sd2), num(w.sd1sd2),
                num(w.normRmssd), num(w.turningPointRate), num(w.ectopicFraction),
                w.label.rawValue, w.confidence.rawValue,
            ].joined(separator: ","))
        }
        return lines.joined(separator: "\n")
    }

    private static func num(_ x: Double?) -> String {
        guard let x else { return "" }
        return String(format: "%.3f", (x * 1000).rounded() / 1000)
    }
}
