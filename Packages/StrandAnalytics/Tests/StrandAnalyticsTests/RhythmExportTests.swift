import XCTest
@testable import StrandAnalytics

final class RhythmExportTests: XCTestCase {
    private let summary = RhythmScreener.NightRhythmSummary(
        readableWindows: 2, steadyWindows: 1, occasionalWindows: 1, variedWindows: 0,
        variationRecurred: false, overall: .occasionalEctopy)

    private let steady = RhythmScreener.WindowResult(
        label: .steady, sd1: 24.5, sd2: 60.0, sd1sd2: 0.408, normRmssd: 0.031,
        turningPointRate: 0.62, ectopicFraction: 0.0, nBeats: 72, confidence: .solid,
        agreedAcrossSources: true, poincare: [])

    private let occasional = RhythmScreener.WindowResult(
        label: .occasionalEctopy, sd1: 40.0, sd2: 70.0, sd1sd2: 0.571, normRmssd: 0.05,
        turningPointRate: 0.8, ectopicFraction: 0.03, nBeats: 66, confidence: .building,
        agreedAcrossSources: false, poincare: [])

    func testCsvCarriesDisclaimerSummaryAndPerWindowRows() {
        let csv = RhythmExport.csv(summary: summary,
                                   windows: [steady, occasional, .unreadable(nBeats: 10)])
        XCTAssertTrue(csv.hasPrefix("# NOOP Rhythm export"))
        XCTAssertTrue(csv.contains("NOT a diagnosis"))
        XCTAssertTrue(csv.contains(RhythmExport.header))
        XCTAssertTrue(csv.contains("1,72,24.500,60.000,0.408,0.031,0.620,0.000,steady,solid"))
        XCTAssertTrue(csv.contains("2,66,40.000,70.000,0.571,0.050,0.800,0.030,occasionalEctopy,building"))
        XCTAssertTrue(csv.contains("3,10,,,,,,,unreadable,calibrating"))
    }

    func testFormattingPreRoundsAtThreeDecimalBoundary() {
        let boundary = RhythmScreener.WindowResult(
            label: .steady, sd1: 0.0625, sd2: 60.0, sd1sd2: 0.408, normRmssd: 0.031,
            turningPointRate: 0.62, ectopicFraction: 0.0, nBeats: 72, confidence: .solid,
            agreedAcrossSources: true, poincare: [])
        let csv = RhythmExport.csv(summary: summary, windows: [boundary])
        XCTAssertTrue(csv.contains(",0.063,"))
    }

    func testExportContainsNoClinicalVerdictTerms() {
        let csv = RhythmExport.csv(summary: summary, windows: [steady, occasional]).lowercased()
        for banned in ["mobitz", "afib", "atrial fibrillation", "arrhythmia", "block",
                       "consider a clinician", "see a doctor"] {
            XCTAssertFalse(csv.contains(banned))
        }
    }
}
