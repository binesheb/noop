import Foundation

public enum MiBandDiscoveryResult: Equatable, Sendable {
    case supported
    case recognizedButUnsupported
    case unknown
}

public enum MiBandCapability: String, CaseIterable, Equatable, Sendable {
    case bleDiscovery
    case modelIdentification
    case serviceInventory
    case heartRate
    case activityHistory
    case sleepHistory
    case battery
}

public struct MiBandDiscoveryEvidence: Equatable, Sendable {
    public let localName: String?
    public let manufacturerData: Data
    public let serviceUUIDs: Set<String>
    public let characteristicUUIDs: Set<String>

    public init(localName: String? = nil, manufacturerData: Data = Data(), serviceUUIDs: Set<String> = [], characteristicUUIDs: Set<String> = []) {
        self.localName = localName
        self.manufacturerData = manufacturerData
        self.serviceUUIDs = serviceUUIDs
        self.characteristicUUIDs = characteristicUUIDs
    }
}

public struct MiBandDiscoveryAssessment: Equatable, Sendable {
    public let result: MiBandDiscoveryResult
    public let capabilities: Set<MiBandCapability>
    public let reason: String

    public init(result: MiBandDiscoveryResult, capabilities: Set<MiBandCapability>, reason: String) {
        self.result = result
        self.capabilities = capabilities
        self.reason = reason
    }
}

public enum MiBandDiscoveryModel {
    /// Conservative first-stage assessment. No model is inferred from a name alone.
    public static func assess(_ evidence: MiBandDiscoveryEvidence) -> MiBandDiscoveryAssessment {
        let serviceUUIDs = evidence.serviceUUIDs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let characteristicUUIDs = evidence.characteristicUUIDs.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        guard !serviceUUIDs.isEmpty || !characteristicUUIDs.isEmpty else {
            return MiBandDiscoveryAssessment(result: .unknown, capabilities: [], reason: "insufficient GATT evidence")
        }

        // Until a generation-specific signature is verified, do not claim support
        // or grant metric capabilities from incomplete protocol evidence.
        var capabilities: Set<MiBandCapability> = [.bleDiscovery]
        if !serviceUUIDs.isEmpty {
            capabilities.insert(.serviceInventory)
        }

        return MiBandDiscoveryAssessment(
            result: .recognizedButUnsupported,
            capabilities: capabilities,
            reason: "Mi Band generation signature is not yet verified"
        )
    }
}
