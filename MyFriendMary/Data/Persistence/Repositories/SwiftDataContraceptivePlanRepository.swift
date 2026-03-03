import Foundation
import SwiftData

@MainActor
final class SwiftDataContraceptivePlanRepository: ContraceptivePlanRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchPlans() async throws -> [ContraceptivePlan] {
        let descriptor = FetchDescriptor<SDContraceptivePlan>(
            sortBy: [SortDescriptor(\.startDay, order: .forward)]
        )
        return try context.fetch(descriptor).map(ContraceptivePlanMapper.toDomain)
    }

    func activePlan() async throws -> ContraceptivePlan? {
        var descriptor = FetchDescriptor<SDContraceptivePlan>(
            predicate: #Predicate { $0.endDay == nil },
            sortBy: [SortDescriptor(\.startDay, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first.map(ContraceptivePlanMapper.toDomain)
    }

    func plan(containing day: Date) async throws -> ContraceptivePlan? {
        let normalizedDay = DateNormalizer.startOfDay(day)

        let descriptor = FetchDescriptor<SDContraceptivePlan>(
            predicate: #Predicate { $0.startDay <= normalizedDay },
            sortBy: [SortDescriptor(\.startDay, order: .reverse)]
        )

        let candidates = try context.fetch(descriptor)
        return candidates.first { model in
            guard let endDay = model.endDay else {
                return true
            }
            return endDay >= normalizedDay
        }.map(ContraceptivePlanMapper.toDomain)
    }

    func upsertPlan(_ plan: ContraceptivePlan) async throws {
        if let existing = try fetchModel(by: plan.id) {
            ContraceptivePlanMapper.apply(plan, to: existing)
        } else {
            let model = SDContraceptivePlan(
                id: plan.id,
                methodRaw: plan.method.rawValue,
                startDay: plan.startDate,
                endDay: plan.endDate,
                ringDays: plan.ringDays,
                breakDays: plan.breakDays,
                createdAt: plan.createdAt,
                updatedAt: plan.updatedAt
            )
            context.insert(model)
        }

        try save()
    }

    private func fetchModel(by id: UUID) throws -> SDContraceptivePlan? {
        var descriptor = FetchDescriptor<SDContraceptivePlan>(
            predicate: #Predicate { $0.id == id }
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
