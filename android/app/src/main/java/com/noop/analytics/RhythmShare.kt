package com.noop.analytics

/**
 * Share-ready metadata for a Rhythm export. Keeps Android UI code independent of the
 * CSV-generation details and gives the eventual ACTION_SEND integration one stable contract.
 */
data class RhythmShareArtifact(
    val filename: String,
    val mimeType: String,
    val chooserTitle: String,
    val text: String,
) {
    init {
        require(filename.endsWith(".csv")) { "Rhythm exports must use a .csv filename" }
        require(mimeType == "text/csv") { "Rhythm exports must use text/csv" }
        require(text.startsWith("# NOOP Rhythm export")) { "Share artifact must carry the export disclaimer" }
    }
}

object RhythmShare {
    const val MIME_TYPE = "text/csv"
    const val DEFAULT_FILENAME = "noop-rhythm-export.csv"
    const val CHOOSER_TITLE = "Share NOOP Rhythm export"

    fun artifact(
        summary: RhythmScreener.NightRhythmSummary,
        windows: List<RhythmScreener.WindowResult>,
        filename: String = DEFAULT_FILENAME,
    ): RhythmShareArtifact = RhythmShareArtifact(
        filename = filename,
        mimeType = MIME_TYPE,
        chooserTitle = CHOOSER_TITLE,
        text = RhythmExport.csv(summary, windows),
    )
}
