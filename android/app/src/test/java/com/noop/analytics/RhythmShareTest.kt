package com.noop.analytics

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class RhythmShareTest {
    @Test
    fun artifactUsesStableCsvShareContract() {
        val summary = RhythmScreener.NightRhythmSummary(
            readableWindows = 0,
            steadyWindows = 0,
            occasionalWindows = 0,
            variedWindows = 0,
            variationRecurred = false,
            overall = RhythmRegularity.UNREADABLE,
        )

        val artifact = RhythmShare.artifact(summary, emptyList())

        assertEquals("noop-rhythm-export.csv", artifact.filename)
        assertEquals("text/csv", artifact.mimeType)
        assertEquals("Share NOOP Rhythm export", artifact.chooserTitle)
        assertTrue(artifact.text.startsWith("# NOOP Rhythm export"))
        assertTrue(artifact.text.contains(RhythmExport.header))
    }

    @Test
    fun customFilenameStillRequiresCsv() {
        val summary = RhythmScreener.NightRhythmSummary(
            readableWindows = 0,
            steadyWindows = 0,
            occasionalWindows = 0,
            variedWindows = 0,
            variationRecurred = false,
            overall = RhythmRegularity.UNREADABLE,
        )
        val artifact = RhythmShare.artifact(summary, emptyList(), "night-2026-09-13.csv")
        assertEquals("night-2026-09-13.csv", artifact.filename)
    }
}
