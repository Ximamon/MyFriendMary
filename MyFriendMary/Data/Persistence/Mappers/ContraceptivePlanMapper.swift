import Foundation

enum ContraceptivePlanMapper {
    static func toDomain(_ model: SDContraceptivePlan) -> ContraceptivePlan {
        ContraceptivePlan(
            id: model.id,
            method: ContraceptiveMethodType(rawValue: model.methodRaw) ?? .anilloVaginal,
            startDate: DateNormalizer.startOfDay(model.startDay),
            endDate: model.endDay.map { DateNormalizer.startOfDay($0) },
            ringDays: model.ringDays,
            breakDays: model.breakDays,
            createdAt: model.createdAt,
            updatedAt: model.updatedAt
        )
    }

    static func apply(_ plan: ContraceptivePlan, to model: SDContraceptivePlan) {
        model.methodRaw = plan.method.rawValue
        model.startDay = DateNormalizer.startOfDay(plan.startDate)
        model.endDay = plan.endDate.map { DateNormalizer.startOfDay($0) }
        model.ringDays = plan.ringDays
        model.breakDays = plan.breakDays
        model.updatedAt = Date()
    }
}
