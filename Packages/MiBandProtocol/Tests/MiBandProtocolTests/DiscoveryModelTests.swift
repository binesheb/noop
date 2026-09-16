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

    func testManufacturerDataAloneDoesNotIdentifyAMiBand() {
        let result = MiBandDiscoveryModel.assess(
            .init(
                localName: "Mi Smart Band",
                manufacturerData: Data([0x01, 0x02, 0x03, 0x04])
            )
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
        XCTAssertEqual(result.reason, "no verified generation signatures are registered")
    }

    func testCharacteristicEvidenceAloneDoesNotClaimServiceInventory() {
        let result = MiBandDiscoveryModel.assess(
            .init(characteristicUUIDs: ["2A37"])
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery])
        XCTAssertFalse(result.capabilities.contains(.serviceInventory))
        XCTAssertEqual(result.reason, "no verified generation signatures are registered")
    }

    func testNormalizedDuplicateGattEntriesDoNotChangeAssessment() {
        let single = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["180D"], characteristicUUIDs: ["2A37"])
        )
        let normalizedDuplicates = MiBandDiscoveryModel.assess(
            .init(
                serviceUUIDs: ["180D", " 180d "],
                characteristicUUIDs: ["2A37", " 2a37 "]
            )
        )

        XCTAssertEqual(single, normalizedDuplicates)
    }

    func testDefaultAssessmentUsesEmptyVerifiedRegistry() {
        XCTAssertTrue(MiBandDiscoveryModel.verifiedGenerationRegistry.isEmpty)

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["ABCD"], characteristicUUIDs: ["1234"])
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .serviceInventory])
        XCTAssertEqual(result.reason, "Mi Band generation signature is not yet verified")
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

    func testCharacteristicOnlyVerifiedSignatureDoesNotClaimServiceInventory() {
        let signature = MiBandGenerationSignature(
            identifier: "characteristic-only-fixture",
            requiredCharacteristicUUIDs: ["1234"],
            capabilities: [.battery]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(characteristicUUIDs: ["1234"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .supported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .modelIdentification, .battery])
        XCTAssertFalse(result.capabilities.contains(.serviceInventory))
    }

    func testCharacteristicOnlySignatureCannotGrantServiceInventoryCapability() {
        let signature = MiBandGenerationSignature(
            identifier: "characteristic-only-fixture",
            requiredCharacteristicUUIDs: ["1234"],
            capabilities: [.battery, .serviceInventory]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(characteristicUUIDs: ["1234"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .supported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .modelIdentification, .battery])
        XCTAssertFalse(result.capabilities.contains(.serviceInventory))
    }

    func testRegistryAssessmentUsesOnlyValidatedSignatures() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["ABCD"],
            requiredCharacteristicUUIDs: ["1234"],
            capabilities: [.battery]
        )
        let registry = MiBandGenerationSignatureRegistry(signatures: [signature])!

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["ABCD"], characteristicUUIDs: ["1234"]),
            registry: registry
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

    func testMismatchedServiceEvidencePreventsSignatureMatch() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["ABCD"],
            requiredCharacteristicUUIDs: ["1234"],
            capabilities: [.battery]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["180D"], characteristicUUIDs: ["1234"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .serviceInventory])
        XCTAssertFalse(result.capabilities.contains(.modelIdentification))
        XCTAssertFalse(result.capabilities.contains(.battery))
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

    func testBlankGenerationSignatureIdentifierNeverMatchesGattEvidence() {
        let signature = MiBandGenerationSignature(
            identifier: " \n",
            requiredServiceUUIDs: ["180D"]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["180D"]),
            signatures: [signature]
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertFalse(result.capabilities.contains(.modelIdentification))
        XCTAssertFalse(result.reason.contains("verified generation signature"))
    }

    func testAmbiguousGenerationSignaturesFailClosed() {
        let first = MiBandGenerationSignature(
            identifier: "fixture-generation-a",
            requiredServiceUUIDs: ["ABCD"]
        )
        let second = MiBandGenerationSignature(
            identifier: "fixture-generation-b",
            requiredServiceUUIDs: ["ABCD"]
        )

        let result = MiBandDiscoveryModel.assess(
            .init(serviceUUIDs: ["ABCD"]),
            signatures: [first, second]
        )

        XCTAssertEqual(result.result, .recognizedButUnsupported)
        XCTAssertEqual(result.capabilities, [.bleDiscovery, .serviceInventory])
        XCTAssertEqual(result.reason, "multiple verified generation signatures match")
        XCTAssertFalse(result.capabilities.contains(.modelIdentification))
    }

    func testGenerationSignatureValidationRejectsBlankOrEmptyDefinitions() {
        XCTAssertFalse(MiBandGenerationSignature(identifier: " \n", requiredServiceUUIDs: ["180D"]).isWellFormed)
        XCTAssertFalse(MiBandGenerationSignature(identifier: "fixture").isWellFormed)
        XCTAssertFalse(MiBandGenerationSignature(identifier: "fixture", requiredServiceUUIDs: [" \n"]).isWellFormed)
        XCTAssertTrue(MiBandGenerationSignature(identifier: "fixture", requiredServiceUUIDs: ["180D"]).isWellFormed)
    }
}
