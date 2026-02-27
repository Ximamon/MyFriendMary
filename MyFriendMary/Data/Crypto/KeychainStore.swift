import Foundation

final class KeychainStore {
    private var memoryStore: [String: Data] = [:]

    func data(for key: String) -> Data? {
        memoryStore[key]
    }

    func set(_ data: Data, for key: String) {
        memoryStore[key] = data
    }
}
