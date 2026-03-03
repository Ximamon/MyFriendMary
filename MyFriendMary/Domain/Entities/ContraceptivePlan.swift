import Foundation

struct ContraceptivePlan: Identifiable, Codable, Equatable {
    var id: UUID
    var method: ContraceptiveMethodType
    var startDate: Date
    var endDate: Date?
    var ringDays: Int
    var breakDays: Int
    var createdAt: Date
    var updatedAt: Date

    var cycleLength: Int {
        max(1, ringDays + breakDays)
    }

    static func defaultRingPlan(startDate: Date) -> ContraceptivePlan {
        ContraceptivePlan(
            id: UUID(),
            method: .anilloVaginal,
            startDate: DateNormalizer.startOfDay(startDate),
            endDate: nil,
            ringDays: 21,
            breakDays: 7,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
