import Foundation

protocol LogSexEntryUseCase {
    func execute(date: Date, orgasmCount: Int, types: Set<SexType>, note: String?) async throws
}

@MainActor
final class DefaultLogSexEntryUseCase: LogSexEntryUseCase {
    private let repository: SexEntryRepository

    init(repository: SexEntryRepository) {
        self.repository = repository
    }

    func execute(date: Date, orgasmCount: Int, types: Set<SexType>, note: String?) async throws {
        let day = DateNormalizer.startOfDay(date)
        let existing = try await repository.entry(for: day)
        let sanitizedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = SexEntry(
            id: existing?.id ?? UUID(),
            date: day,
            orgasmCount: max(0, orgasmCount),
            types: types,
            note: sanitizedNote?.isEmpty == true ? nil : sanitizedNote
        )
        try await repository.upsertEntry(entry)
    }
}
