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
        let existing = try fetchEntry(for: day)

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

        try save()
    }

    func entry(for day: Date) async throws -> SymptomEntry? {
        try fetchEntry(for: day).map(SymptomMapper.toDomain)
    }

    func entries(in interval: DateInterval) async throws -> [SymptomEntry] {
        let start = DateNormalizer.startOfDay(interval.start)
        let end = interval.end

        let descriptor = FetchDescriptor<SDSymptomEntry>(
            predicate: #Predicate { model in
                model.day >= start && model.day < end
            },
            sortBy: [SortDescriptor(\.day, order: .forward)]
        )

        return try context.fetch(descriptor).map(SymptomMapper.toDomain)
    }

    private func fetchEntry(for day: Date) throws -> SDSymptomEntry? {
        let normalizedDay = DateNormalizer.startOfDay(day)
        var descriptor = FetchDescriptor<SDSymptomEntry>(
            predicate: #Predicate { model in
                model.day == normalizedDay
            }
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
