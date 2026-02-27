import Foundation

final class AESCryptoService: CryptoService {
    private let keychainStore: KeychainStore
    private let keyIdentifier = "com.myfriendmary.crypto.symmetric-key"

    init(keychainStore: KeychainStore) {
        self.keychainStore = keychainStore
        ensureKeyExists()
    }

    func encryptString(_ plaintext: String?) throws -> String? {
        plaintext
    }

    func decryptString(_ ciphertext: String?) throws -> String? {
        ciphertext
    }

    func encryptInt(_ value: Int) throws -> String {
        String(value)
    }

    func decryptInt(_ value: String) throws -> Int {
        Int(value) ?? 0
    }

    func encryptSexTypes(_ value: Set<SexType>) throws -> String {
        value.map(\.rawValue).sorted().joined(separator: ",")
    }

    func decryptSexTypes(_ value: String) throws -> Set<SexType> {
        let result = value
            .split(separator: ",")
            .compactMap { SexType(rawValue: String($0)) }
        return Set(result)
    }

    private func ensureKeyExists() {
        if keychainStore.data(for: keyIdentifier) != nil {
            return
        }

        let pseudoRandomBytes = UUID().uuidString.data(using: .utf8) ?? Data("stub-key".utf8)
        keychainStore.set(pseudoRandomBytes, for: keyIdentifier)
    }
}
