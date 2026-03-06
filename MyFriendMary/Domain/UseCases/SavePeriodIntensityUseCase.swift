import Foundation

protocol SavePeriodIntensityUseCase {
    func execute(date: Date, intensity: PeriodIntensity?) async throws
}

@MainActor
final class DefaultSavePeriodIntensityUseCase: SavePeriodIntensityUseCase {
    private let repository: PeriodEntryRepository

    init(repository: PeriodEntryRepository) {
        self.repository = repository
    }

    func execute(date: Date, intensity: PeriodIntensity?) async throws {
        let day = DateNormalizer.startOfDay(date)
        let existing = try await repository.entry(for: day)

        let entry = PeriodEntry(
            id: existing?.id ?? UUID(),
            date: day,
            intensity: intensity
        )
        try await repository.upsertEntry(entry)
    }
}
