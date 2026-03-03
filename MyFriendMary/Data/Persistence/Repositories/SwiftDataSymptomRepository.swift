import Foundation
import SwiftData

@MainActor
final class SwiftDataSymptomRepository: SymptomRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func upsertEntry(_ entry: SymptomEntry) async throws {
        let day = DateNormalizer.startOfDay(entry.date)
        let existingEntries = try fetchEntries(for: day)
        let existing = existingEntries.first

        if let existing {
            SymptomMapper.apply(entry, to: existing)
        } else {
            let model = SDSymptomEntry(
                id: entry.id,
                day: day,
                symptomsRaw: SymptomMapper.encodeSymptoms(entry.symptoms),
                note: entry.note,
                updatedAt: Date()
            )
            context.insert(model)
        }

        for duplicate in existingEntries.dropFirst() {
            context.delete(duplicate)
        }

        try save()
    }

    func entry(for day: Date) async throws -> SymptomEntry? {
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

        return SymptomMapper.toDomain(first)
    }

    func entries(in interval: DateInterval) async throws -> [SymptomEntry] {
        let start = DateNormalizer.startOfDay(interval.start)
        let end = interval.end

        let descriptor = FetchDescriptor<SDSymptomEntry>(
            predicate: #Predicate { model in
                model.day >= start && model.day < end
            },
            sortBy: [
                SortDescriptor(\.day, order: .forward),
                SortDescriptor(\.updatedAt, order: .reverse)
            ]
        )

        let fetched = try context.fetch(descriptor)
        var uniqueByDay: [String: SDSymptomEntry] = [:]
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
            .map(SymptomMapper.toDomain)
            .sorted { $0.date < $1.date }
    }

    private func fetchEntries(for day: Date) throws -> [SDSymptomEntry] {
        let normalizedDay = DateNormalizer.startOfDay(day)
        let descriptor = FetchDescriptor<SDSymptomEntry>(
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
