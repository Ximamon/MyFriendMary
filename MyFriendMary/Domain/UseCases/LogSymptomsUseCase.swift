import Foundation

protocol LogSymptomsUseCase {
    func execute(date: Date, symptoms: [SymptomType], note: String?) async throws
}

@MainActor
final class DefaultLogSymptomsUseCase: LogSymptomsUseCase {
    private let repository: SymptomRepository

    init(repository: SymptomRepository) {
        self.repository = repository
    }

    func execute(date: Date, symptoms: [SymptomType], note: String?) async throws {
        let day = DateNormalizer.startOfDay(date)
        let existing = try await repository.entry(for: day)
        let sanitizedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = SymptomEntry(
            id: existing?.id ?? UUID(),
            date: day,
            symptoms: symptoms,
            note: sanitizedNote?.isEmpty == true ? nil : sanitizedNote
        )
        try await repository.upsertEntry(entry)
    }
}
