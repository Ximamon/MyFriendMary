import Foundation
import SwiftData

@MainActor
final class SwiftDataSexEntryRepository: SexEntryRepository {
    private let context: ModelContext
    private let cryptoService: CryptoService

    init(context: ModelContext, cryptoService: CryptoService) {
        self.context = context
        self.cryptoService = cryptoService
    }

    func upsertEntry(_ entry: SexEntry) async throws {
        let day = DateNormalizer.startOfDay(entry.date)
        let existingEntries = try fetchEntries(for: day)
        let existing = existingEntries.first

        if let existing {
            try SexEntryMapper.apply(entry, to: existing, cryptoService: cryptoService)
        } else {
            let model = SDSexEntry(
                id: entry.id,
                day: day,
                orgasmCountRaw: try cryptoService.encryptInt(entry.orgasmCount),
                typesRaw: try cryptoService.encryptSexTypes(entry.types),
                noteRaw: try cryptoService.encryptString(entry.note),
                updatedAt: Date()
            )
            context.insert(model)
        }

        for duplicate in existingEntries.dropFirst() {
            context.delete(duplicate)
        }

        try save()
    }

    func entry(for day: Date) async throws -> SexEntry? {
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

        return try SexEntryMapper.toDomain(first, cryptoService: cryptoService)
    }

    func entries(in interval: DateInterval) async throws -> [SexEntry] {
        let start = DateNormalizer.startOfDay(interval.start)
        let end = interval.end

        let descriptor = FetchDescriptor<SDSexEntry>(
            predicate: #Predicate { model in
                model.day >= start && model.day < end
            },
            sortBy: [
                SortDescriptor(\.day, order: .forward),
                SortDescriptor(\.updatedAt, order: .reverse)
            ]
        )

        let fetched = try context.fetch(descriptor)
        var uniqueByDay: [String: SDSexEntry] = [:]
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

        return try uniqueByDay.values
            .map { try SexEntryMapper.toDomain($0, cryptoService: cryptoService) }
            .sorted { $0.date < $1.date }
    }

    private func fetchEntries(for day: Date) throws -> [SDSexEntry] {
        let normalizedDay = DateNormalizer.startOfDay(day)
        let descriptor = FetchDescriptor<SDSexEntry>(
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
