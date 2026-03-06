import Foundation

struct RingStatusSnapshot: Codable, Equatable {
    var day: Date
    var isPlanActive: Bool
    var state: RingDayState
    var planStartDate: Date?
    var planEndDate: Date?
    var nextTransitionDate: Date?
    var method: ContraceptiveMethodType?

    static func empty(day: Date) -> RingStatusSnapshot {
        RingStatusSnapshot(
            day: DateNormalizer.startOfDay(day),
            isPlanActive: false,
            state: .sinPlan,
            planStartDate: nil,
            planEndDate: nil,
            nextTransitionDate: nil,
            method: nil
        )
    }
}
