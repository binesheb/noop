import Foundation

/// Explicit registry for generation signatures that are safe to use for matching.
public struct MiBandGenerationSignatureRegistry: Equatable, Sendable {
    public let signatures: [MiBandGenerationSignature]

    /// Creates a registry only when every signature is well formed and has a unique identifier.
    ///
    /// The registry intentionally performs no generation inference and does not add signatures.
    public init?(signatures: [MiBandGenerationSignature]) {
        guard signatures.allSatisfy(\.isWellFormed) else {
            return nil
        }

        let identifiers = signatures.map { $0.identifier.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard Set(identifiers).count == identifiers.count else {
            return nil
        }

        self.signatures = zip(signatures, identifiers).map { signature, identifier in
            MiBandGenerationSignature(
                identifier: identifier,
                requiredServiceUUIDs: signature.requiredServiceUUIDs,
                requiredCharacteristicUUIDs: signature.requiredCharacteristicUUIDs,
                capabilities: signature.capabilities
            )
        }
    }
}
