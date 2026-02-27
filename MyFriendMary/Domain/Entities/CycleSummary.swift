import Foundation

struct CycleSummary: Codable, Equatable {
    var today: Date
    var estimatedPhase: AppPhase
    var daysUntilNextPeriod: Int?
    var nextPeriodStart: Date?
    var fertileWindowStart: Date?
    var fertileWindowEnd: Date?
    var ovulationDate: Date?

    static func empty(today: Date) -> CycleSummary {
        CycleSummary(
            today: today,
            estimatedPhase: .desconocida,
            daysUntilNextPeriod: nil,
            nextPeriodStart: nil,
            fertileWindowStart: nil,
            fertileWindowEnd: nil,
            ovulationDate: nil
        )
    }
}
