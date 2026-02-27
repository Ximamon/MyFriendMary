import Foundation

enum CycleMapper {
    static func toDomain(_ model: SDCycle) -> Cycle {
        Cycle(id: model.id, startDate: model.startDay, endDate: model.endDay)
    }

    static func apply(_ cycle: Cycle, to model: SDCycle) {
        model.startDay = DateNormalizer.startOfDay(cycle.startDate)
        model.endDay = cycle.endDate.map { DateNormalizer.startOfDay($0) }
        model.updatedAt = Date()
    }
}
