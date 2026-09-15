import XCTest
@testable import MiBandProtocol

final class GenerationSignatureRegistryTests: XCTestCase {
    func testEmptyRegistryContainsNoVerifiedSignatures() {
        let registry = MiBandGenerationSignatureRegistry()

        XCTAssertTrue(registry.isEmpty)
        XCTAssertTrue(registry.signatures.isEmpty)
        XCTAssertNil(registry.signature(forIdentifier: "fixture-generation"))
    }

    func testRegistryAcceptsOnlyWellFormedUniqueSignatures() {
        let valid = MiBandGenerationSignature(
            identifier: "fixture",
            requiredServiceUUIDs: ["180D"]
        )

        let registry = MiBandGenerationSignatureRegistry(signatures: [valid])

        XCTAssertEqual(registry?.signatures, [valid])
    }

    func testRegistryCanonicalizesIdentifierWhitespace() {
        let signature = MiBandGenerationSignature(
            identifier: "  fixture-generation  ",
            requiredServiceUUIDs: ["180D"]
        )

        let registry = MiBandGenerationSignatureRegistry(signatures: [signature])

        XCTAssertEqual(registry?.signatures.first?.identifier, "fixture-generation")
    }

    func testRegistryRejectsMalformedSignatures() {
        let malformed = MiBandGenerationSignature(identifier: "fixture")

        XCTAssertNil(MiBandGenerationSignatureRegistry(signatures: [malformed]))
    }

    func testRegistryRejectsDuplicateIdentifiersAfterNormalization() {
        let first = MiBandGenerationSignature(
            identifier: "fixture",
            requiredServiceUUIDs: ["180D"]
        )
        let second = MiBandGenerationSignature(
            identifier: " fixture ",
            requiredServiceUUIDs: ["2A37"]
        )

        XCTAssertNil(MiBandGenerationSignatureRegistry(signatures: [first, second]))
    }

    func testRegistryLookupNormalizesIdentifierWhitespace() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["180D"]
        )
        let registry = MiBandGenerationSignatureRegistry(signatures: [signature])

        XCTAssertEqual(
            registry?.signature(forIdentifier: "  fixture-generation  "),
            signature
        )
    }

    func testRegistryLookupReturnsNilForBlankOrUnknownIdentifier() {
        let signature = MiBandGenerationSignature(
            identifier: "fixture-generation",
            requiredServiceUUIDs: ["180D"]
        )
        let registry = MiBandGenerationSignatureRegistry(signatures: [signature])

        XCTAssertNil(registry?.signature(forIdentifier: "   "))
        XCTAssertNil(registry?.signature(forIdentifier: "other"))
    }
}
