import Foundation

protocol WipeAllUseCase {
    func execute() async throws
}

protocol WipeAllDataStore {
    func wipeAll() async throws
}

@MainActor
final class DefaultWipeAllUseCase: WipeAllUseCase {
    private let dataStore: WipeAllDataStore

    init(dataStore: WipeAllDataStore) {
        self.dataStore = dataStore
    }

    func execute() async throws {
        try await dataStore.wipeAll()
    }
}
