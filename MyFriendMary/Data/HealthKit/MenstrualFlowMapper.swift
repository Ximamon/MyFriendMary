import Foundation

struct MenstrualFlowMapper {
    func dayRange(for cycle: Cycle) -> [Date] {
        let start = DateNormalizer.startOfDay(cycle.startDate)
        let end = DateNormalizer.startOfDay(cycle.endDate ?? cycle.startDate)
        let days = max(0, DateNormalizer.daysBetween(start, end))
        return (0...days).map { DateNormalizer.addingDays($0, to: start) }
    }
}
