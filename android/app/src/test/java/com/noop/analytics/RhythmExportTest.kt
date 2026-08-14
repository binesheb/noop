package com.noop.analytics

import org.junit.Assert.assertTrue
import org.junit.Assert.assertFalse
import org.junit.Test

class RhythmExportTest {
    private val summary = RhythmScreener.NightRhythmSummary(
        readableWindows = 2, steadyWindows = 1, occasionalWindows = 1, variedWindows = 0,
        variationRecurred = false, overall = RhythmRegularity.OCCASIONAL_ECTOPY,
    )
    private val steady = RhythmScreener.WindowResult(
        label = RhythmRegularity.STEADY, sd1 = 24.5, sd2 = 60.0, sd1sd2 = 0.408,
        normRmssd = 0.031, turningPointRate = 0.62, ectopicFraction = 0.0,
        nBeats = 72, confidence = RhythmConfidence.SOLID, agreedAcrossSources = true, poincare = emptyList(),
    )
    private val occasional = RhythmScreener.WindowResult(
        label = RhythmRegularity.OCCASIONAL_ECTOPY, sd1 = 40.0, sd2 = 70.0, sd1sd2 = 0.571,
        normRmssd = 0.05, turningPointRate = 0.8, ectopicFraction = 0.03,
        nBeats = 66, confidence = RhythmConfidence.BUILDING, agreedAcrossSources = false, poincare = emptyList(),
    )

    @Test
    fun csvCarriesDisclaimerAndRows() {
        val csv = RhythmExport.csv(summary, listOf(steady, occasional, RhythmScreener.WindowResult.unreadable(10)))
        assertTrue(csv.startsWith("# NOOP Rhythm export"))
        assertTrue(csv.contains("NOT a diagnosis"))
        assertTrue(csv.contains(RhythmExport.header))
        assertTrue(csv.contains("1,72,24.500,60.000,0.408,0.031,0.620,0.000,steady,solid"))
        assertTrue(csv.contains("2,66,40.000,70.000,0.571,0.050,0.800,0.030,occasionalEctopy,building"))
        assertTrue(csv.contains("3,10,,,,,,,unreadable,calibrating"))
    }

    @Test
    fun formattingPreRoundsAtThreeDecimalBoundary() {
        val csv = RhythmExport.csv(summary, listOf(steady.copy(sd1 = 0.0625)))
        assertTrue(csv.contains(",0.063,"))
    }

    @Test
    fun exportContainsNoClinicalVerdictTerms() {
        val csv = RhythmExport.csv(summary, listOf(steady, occasional)).lowercase()
        for (banned in listOf("mobitz", "afib", "atrial fibrillation", "arrhythmia", "block", "consider a clinician", "see a doctor")) {
            assertFalse(csv.contains(banned))
        }
    }
}
