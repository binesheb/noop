import XCTest
@testable import MiBandProtocol

final class DiscoveryModelTests: XCTestCase {
    func testEmptyEvidenceFailsClosedAsUnknown() {
        let result = MiBandDiscoveryModel.assess(.init())

        XCTAssertEqual(result.result, .unknown)
        XCTAssertTrue(result.capabilities.isEmpty)
    }

    func testGattEvidenceDoesNotClaimMetricSupportBeforeGenerationIsVerified() {
        let result = MiBandDiscoveryModel.assess(
            .init(
                localName: "Mi Smart Band",
                serviceUUIDs: ["180D"],
                characteristicUUIDs: ["2A37"]
            )
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .serviceInventory])
        XCTAssertFalse(result.capabilities.contains(.heartRate))
        XCTAssertFalse(result.capabilities.contains(.activityHistory))
    }

    func testDuplicateGattEntriesDoNotChangeAssessment() {
        let single = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["180D"], characteristicUUIDs: ["2A37"])
        )
        let duplicate = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["180D"], characteristicUUIDs: ["2A37"])
        )

        XCTAssertEqual(single, duplicate)
    }
}
