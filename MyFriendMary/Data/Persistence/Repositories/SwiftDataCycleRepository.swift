import Foundation
import SwiftData

@MainActor
final class SwiftDataCycleRepository: CycleRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchCycles() async throws -> [Cycle] {
        let descriptor = FetchDescriptor<SDCycle>(sortBy: [SortDescriptor(\.startDay, order: .forward)])
        return try context.fetch(descriptor).map(CycleMapper.toDomain)
    }

    func upsertCycle(_ cycle: Cycle) async throws {
        let existing = try fetchCycle(by: cycle.id)

        if let existing {
            CycleMapper.apply(cycle, to: existing)
        } else {
            let model = SDCycle(
                id: cycle.id,
                startDay: cycle.startDate,
                endDay: cycle.endDate,
                createdAt: Date(),
                updatedAt: Date()
            )
            context.insert(model)
        }

        try save()
    }

    func getOpenCycle() async throws -> Cycle? {
        let descriptor = FetchDescriptor<SDCycle>(
            predicate: #Predicate { $0.endDay == nil },
            sortBy: [SortDescriptor(\.startDay, order: .reverse)]
        )
        return try context.fetch(descriptor).first.map(CycleMapper.toDomain)
    }

    func closeOpenCycle(on date: Date) async throws {
        let day = DateNormalizer.startOfDay(date)

        let descriptor = FetchDescriptor<SDCycle>(
            predicate: #Predicate { $0.endDay == nil },
            sortBy: [SortDescriptor(\.startDay, order: .reverse)]
        )

        guard let openCycle = try context.fetch(descriptor).first else {
            return
        }

        openCycle.endDay = max(openCycle.startDay, day)
        openCycle.updatedAt = Date()

        try save()
    }

    private func fetchCycle(by id: UUID) throws -> SDCycle? {
        var descriptor = FetchDescriptor<SDCycle>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    private func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
