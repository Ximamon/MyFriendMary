import Foundation

protocol RingScheduleService {
    func state(on day: Date, plan: ContraceptivePlan) -> RingDayState
    func nextTransition(on day: Date, plan: ContraceptivePlan) -> Date?
}

struct DefaultRingScheduleService: RingScheduleService {
    func state(on day: Date, plan: ContraceptivePlan) -> RingDayState {
        let normalizedDay = DateNormalizer.startOfDay(day)
        let start = DateNormalizer.startOfDay(plan.startDate)
        guard normalizedDay >= start else {
            return .sinPlan
        }

        if let endDate = plan.endDate,
           normalizedDay > DateNormalizer.startOfDay(endDate) {
            return .sinPlan
        }

        let usageDays = max(1, plan.ringDays)
        let breakDays = max(0, plan.breakDays)
        let cycleLength = max(1, usageDays + breakDays)

        let offset = max(0, DateNormalizer.daysBetween(start, normalizedDay))
        let index = offset % cycleLength

        if index < usageDays {
            return .uso
        }
        return .descanso
    }

    func nextTransition(on day: Date, plan: ContraceptivePlan) -> Date? {
        let normalizedDay = DateNormalizer.startOfDay(day)
        let start = DateNormalizer.startOfDay(plan.startDate)
        guard normalizedDay >= start else {
            return start
        }

        if let endDate = plan.endDate,
           normalizedDay > DateNormalizer.startOfDay(endDate) {
            return nil
        }

        let usageDays = max(1, plan.ringDays)
        let breakDays = max(0, plan.breakDays)
        let cycleLength = max(1, usageDays + breakDays)

        let offset = max(0, DateNormalizer.daysBetween(start, normalizedDay))
        let index = offset % cycleLength
        let currentState = state(on: normalizedDay, plan: plan)

        let daysUntilTransition: Int
        switch currentState {
        case .uso:
            daysUntilTransition = usageDays - index
        case .descanso:
            daysUntilTransition = cycleLength - index
        case .sinPlan:
            return nil
        }

        let transition = DateNormalizer.addingDays(daysUntilTransition, to: normalizedDay)
        if let endDate = plan.endDate,
           transition > DateNormalizer.startOfDay(endDate) {
            return nil
        }
        return transition
    }
}
