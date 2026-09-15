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

/// A verified, generation-specific protocol signature.
public struct MiBandGenerationSignature: Equatable, Sendable {
    public let identifier: String
    public let requiredServiceUUIDs: Set<String>
    public let requiredCharacteristicUUIDs: Set<String>
    public let capabilities: Set<MiBandCapability>

    public init(
        identifier: String,
        requiredServiceUUIDs: Set<String> = [],
        requiredCharacteristicUUIDs: Set<String> = [],
        capabilities: Set<MiBandCapability> = []
    ) {
        self.identifier = identifier
        self.requiredServiceUUIDs = requiredServiceUUIDs
        self.requiredCharacteristicUUIDs = requiredCharacteristicUUIDs
        self.capabilities = capabilities
    }

    /// Whether the signature has enough identifying data to participate in matching.
    public var isWellFormed: Bool {
        let normalizedIdentifier = identifier.trimmingCharacters(in: .whitespacesAndNewlines)
        return !normalizedIdentifier.isEmpty &&
            (!normalized(requiredServiceUUIDs).isEmpty || !normalized(requiredCharacteristicUUIDs).isEmpty)
    }

    fileprivate func matches(serviceUUIDs: Set<String>, characteristicUUIDs: Set<String>) -> Bool {
        guard isWellFormed else {
            return false
        }

        let requiredServices = normalized(requiredServiceUUIDs)
        let requiredCharacteristics = normalized(requiredCharacteristicUUIDs)

        return requiredServices.isSubset(of: normalized(serviceUUIDs)) &&
            requiredCharacteristics.isSubset(of: normalized(characteristicUUIDs))
    }
}

public enum MiBandDiscoveryModel {
    /// The production registry. It intentionally contains no signatures until they are verified from hardware evidence.
    public static let verifiedGenerationRegistry = MiBandGenerationSignatureRegistry()

    /// Conservative first-stage assessment. No model is inferred from a name alone.
    public static func assess(
        _ evidence: MiBandDiscoveryEvidence
    ) -> MiBandDiscoveryAssessment {
        assess(evidence, registry: verifiedGenerationRegistry)
    }

    /// Assesses evidence against an explicit signature list. Kept for fixtures and controlled callers.
    public static func assess(
        _ evidence: MiBandDiscoveryEvidence,
        signatures: [MiBandGenerationSignature]
    ) -> MiBandDiscoveryAssessment {
        assess(evidence, signatures: signatures, normalizedServiceUUIDs: nil)
    }

    /// Assesses evidence using only signatures accepted by the validated registry.
    public static func assess(
        _ evidence: MiBandDiscoveryEvidence,
        registry: MiBandGenerationSignatureRegistry
    ) -> MiBandDiscoveryAssessment {
        assess(evidence, signatures: registry.signatures, normalizedServiceUUIDs: nil)
    }

    private static func assess(
        _ evidence: MiBandDiscoveryEvidence,
        signatures: [MiBandGenerationSignature],
        normalizedServiceUUIDs: Set<String>?
    ) -> MiBandDiscoveryAssessment {
        let serviceUUIDs = normalizedServiceUUIDs ?? normalized(evidence.serviceUUIDs)
        let characteristicUUIDs = normalized(evidence.characteristicUUIDs)

        guard !serviceUUIDs.isEmpty || !characteristicUUIDs.isEmpty else {
            return MiBandDiscoveryAssessment(result: .unknown, capabilities: [], reason: "insufficient GATT evidence")
        }

        let matchingSignatures = signatures.filter {
            $0.matches(serviceUUIDs: serviceUUIDs, characteristicUUIDs: characteristicUUIDs)
        }

        if matchingSignatures.count == 1, let signature = matchingSignatures.first {
            return MiBandDiscoveryAssessment(
                result: .supported,
                capabilities: [.bleDiscovery, .modelIdentification, .serviceInventory].union(signature.capabilities),
                reason: "verified generation signature: \(signature.identifier)"
            )
        }

        if matchingSignatures.count > 1 {
            return MiBandDiscoveryAssessment(
                result: .recognizedButUnsupported,
                capabilities: serviceUUIDs.isEmpty ? [.bleDiscovery] : [.bleDiscovery, .serviceInventory],
                reason: "multiple verified generation signatures match"
            )
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

    private static func normalized(_ values: Set<String>) -> Set<String> {
        Set(values.compactMap { value in
            let normalized = value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            return normalized.isEmpty ? nil : normalized
        })
    }
}
