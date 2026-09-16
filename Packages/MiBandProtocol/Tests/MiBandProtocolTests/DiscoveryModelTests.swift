import XCTest
@testable import MiBandProtocol

final class DiscoveryModelTests: XCTestCase {
    func testEmptyEvidenceIsUnknown() {
        let assessment = MiBandDiscoveryModel.assess(MiBandDiscoveryEvidence())

        XCTAssertEqual(assessment.result, .unknown)
        XCTAssertTrue(assessment.capabilities.isEmpty)
        XCTAssertEqual(assessment.reason, "insufficient GATT evidence")
    }

    func testLocalNameAloneDoesNotIdentifyMiBand() {
        let evidence = MiBandDiscoveryEvidence(localName: "Mi Smart Band")

        let assessment = MiBandDiscoveryModel.assess(evidence)

        XCTAssertEqual(assessment.result, .unknown)
        XCTAssertTrue(assessment.capabilities.isEmpty)
    }

    func testServiceEvidenceWithoutVerifiedSignatureIsRecognizedButUnsupported() {
        let evidence = MiBandDiscoveryEvidence(serviceUUIDs: ["180D"])

        let assessment = MiBandDiscoveryModel.assess(evidence)

        XCTAssertEqual(assessment.result, .recognizedButUnsupported)
        XCTAssertEqual(assessment.capabilities, [.bleDiscovery, .serviceInventory])
        XCTAssertEqual(assessment.reason, "no verified generation signatures are registered")
    }

    func testCharacteristicEvidenceWithoutVerifiedSignatureIsRecognizedButUnsupported() {
        let evidence = MiBandDiscoveryEvidence(characteristicUUIDs: ["2A37"])

        let assessment = MiBandDiscoveryModel.assess(evidence)

        XCTAssertEqual(assessment.result, .recognizedButUnsupported)
        XCTAssertEqual(assessment.capabilities, [.bleDiscovery])
        XCTAssertEqual(assessment.reason, "no verified generation signatures are registered")
    }

    func testVerifiedServiceSignatureReportsServiceInventory() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["180D"],
            capabilities: [.heartRate]
        )
        let registry = MiBandGenerationSignatureRegistry(signatures: [signature])!
        let evidence = MiBandDiscoveryEvidence(serviceUUIDs: ["180D"])

        let assessment = MiBandDiscoveryModel.assess(evidence, registry: registry)

        XCTAssertEqual(assessment.result, .supported)
        XCTAssertEqual(
            assessment.capabilities,
            [.bleDiscovery, .modelIdentification, .serviceInventory, .heartRate]
        )
        XCTAssertEqual(assessment.reason, "verified generation signature: fixture-generation")
    }

    func testVerifiedCharacteristicSignatureDoesNotReportServiceInventory() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredCharacteristicUUIDs: ["2A37"],
            capabilities: [.heartRate, .serviceInventory]
        )
        let registry = MiBandGenerationSignatureRegistry(signatures: [signature])!
        let evidence = MiBandDiscoveryEvidence(characteristicUUIDs: ["2A37"])

        let assessment = MiBandDiscoveryModel.assess(evidence, registry: registry)

        XCTAssertEqual(assessment.result, .supported)
        XCTAssertEqual(assessment.capabilities, [.bleDiscovery, .modelIdentification, .heartRate])
        XCTAssertEqual(assessment.reason, "verified generation signature: fixture-generation")
    }
}
