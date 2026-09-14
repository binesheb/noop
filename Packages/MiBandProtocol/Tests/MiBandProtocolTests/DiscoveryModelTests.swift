import XCTest
@testable import MiBandProtocol

final class DiscoveryModelTests: XCTestCase {
    func testEmptyEvidenceFailsClosedAsUnknown() {
        let result = MiBandDiscoveryModel.assess(.init())

        XCTAssertEqual(result.result, .unknown)
        XCTAssertTrue(result.capabilities.isEmpty)
    }

    func testWhitespaceOnlyGattEvidenceFailsClosedAsUnknown() {
        let result = MiBandDiscoveryModel.assess(
            .init(
                serviceUUIDs: ["  "],
                characteristicUUIDs: ["\n"]
            )
        )

        XCTAssertEqual(result.result, .unknown)
        XCTAssertTrue(result.capabilities.isEmpty)
    }

    func testLocalNameAloneDoesNotIdentifyAMiBand() {
        let result = MiBandDiscoveryModel.assess(
            .init(localName: "Mi Smart Band")
        )

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

    func testCharacteristicEvidenceAloneDoesNotClaimServiceInventory() {
        let result = MiBandDiscoveryModel.assess(
            .init(characteristicUUIDs: ["2A37"])
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery])
        XCTAssertFalse(result.capabilities.contains(.serviceInventory))
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

    func testVerifiedSignatureProducesSupportedAssessment() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["ABCD"],
            requiredCharacteristicUUIDs: ["1234"],
            capabilities: [.battery]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["ABCD"], characteristicUUIDs: ["1234"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .supported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .modelIdentification, .serviceInventory, .battery])
        XCTAssertEqual(result.reason, "verified generation signature: fixture-generation")
    }

    func testSignatureRequiresAllDeclaredGattEvidence() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["ABCD"],
            requiredCharacteristicUUIDs: ["1234"]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["ABCD"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertFalse(result.capabilities.contains(.modelIdentification))
    }

    func testGattUUIDMatchingIgnoresCaseAndSurroundingWhitespace() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["abcd"],
            requiredCharacteristicUUIDs: ["  1234  "],
            capabilities: [.battery]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: [" ABCD "], characteristicUUIDs: ["1234"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .supported)
        XCTAssertTrue(result.capabilities.contains(.battery))
    }

    func testEmptyGenerationSignatureNeverMatchesGattEvidence() {
        let signature = MiBandGenerationSignature(identifier: "empty")

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["180D"], characteristicUUIDs: ["2A37"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertFalse(result.capabilities.contains(.modelIdentification))
        XCTAssertFalse(result.reason.contains("verified generation signature"))
    }
}
