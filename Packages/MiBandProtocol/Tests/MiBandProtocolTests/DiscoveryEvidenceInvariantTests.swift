import XCTest
@testable import MiBandProtocol

final class DiscoveryEvidenceInvariantTests: XCTestCase {
    func testManufacturerDataAloneDoesNotIdentifyAnUnsupportedGeneration() {
        let result = MiBandDiscoveryModel.assess(
            .init(
                localName: "Mi Smart Band",
                manufacturerData: Data([0x01, 0x02, 0x03, 0x04])
            )
        )

        XCTAssertEqual(result.result, .unknown)
        XCTAssertTrue(result.capabilities.isEmpty)
    }
}
