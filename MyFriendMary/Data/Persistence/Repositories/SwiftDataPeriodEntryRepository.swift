import Foundation
import SwiftData

@MainActor
final class SwiftDataPeriodEntryRepository: PeriodEntryRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func upsertEntry(_ entry: PeriodEntry) async throws {
        let day = DateNormalizer.startOfDay(entry.date)
        let existingEntries = try fetchEntries(for: day)
        let existing = existingEntries.first

        if let existing {
            PeriodEntryMapper.apply(entry, to: existing)
        } else {
            let model = SDPeriodEntry(
                id: entry.id,
                day: day,
                intensityRaw: entry.intensity?.rawValue,
                updatedAt: Date()
            )
            context.insert(model)
        }

        for duplicate in existingEntries.dropFirst() {
            context.delete(duplicate)
        }

        try save()
    }

    func entry(for day: Date) async throws -> PeriodEntry? {
        let entries = try fetchEntries(for: day)
        guard let first = entries.first else {
            return nil
        }

        for duplicate in entries.dropFirst() {
            context.delete(duplicate)
        }
        if entries.count > 1 {
            try save()
        }

        return PeriodEntryMapper.toDomain(first)
    }

    func entries(in interval: DateInterval) async throws -> [PeriodEntry] {
        let start = DateNormalizer.startOfDay(interval.start)
        let end = interval.end

        let descriptor = FetchDescriptor<SDPeriodEntry>(
            predicate: #Predicate { model in
                model.day >= start && model.day < end
            },
            sortBy: [
                SortDescriptor(\.day, order: .forward),
                SortDescriptor(\.updatedAt, order: .reverse)
            ]
        )

        let fetched = try context.fetch(descriptor)
        var uniqueByDay: [String: SDPeriodEntry] = [:]
        var needsCleanup = false

        for model in fetched {
            let key = DayKeyFormatter.string(from: model.day)
            if uniqueByDay[key] == nil {
                uniqueByDay[key] = model
            } else {
                context.delete(model)
                needsCleanup = true
            }
        }

        if needsCleanup {
            try save()
        }

        return uniqueByDay.values
            .map(PeriodEntryMapper.toDomain)
            .sorted { $0.date < $1.date }
    }

    private func fetchEntries(for day: Date) throws -> [SDPeriodEntry] {
        let normalizedDay = DateNormalizer.startOfDay(day)
        let descriptor = FetchDescriptor<SDPeriodEntry>(
            predicate: #Predicate { model in
                model.day == normalizedDay
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
    }

    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
