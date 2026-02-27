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
        let existing = try fetchEntry(for: day)

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

        try save()
    }

    func entry(for day: Date) async throws -> SexEntry? {
        guard let model = try fetchEntry(for: day) else {
            return nil
        }
        return try SexEntryMapper.toDomain(model, cryptoService: cryptoService)
    }

    func entries(in interval: DateInterval) async throws -> [SexEntry] {
        let start = DateNormalizer.startOfDay(interval.start)
        let end = interval.end

        let descriptor = FetchDescriptor<SDSexEntry>(
            predicate: #Predicate { model in
                model.day >= start && model.day < end
            },
            sortBy: [SortDescriptor(\.day, order: .forward)]
        )

        return try context.fetch(descriptor).compactMap {
            try SexEntryMapper.toDomain($0, cryptoService: cryptoService)
        }
    }

    private func fetchEntry(for day: Date) throws -> SDSexEntry? {
        let normalizedDay = DateNormalizer.startOfDay(day)
        var descriptor = FetchDescriptor<SDSexEntry>(
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
