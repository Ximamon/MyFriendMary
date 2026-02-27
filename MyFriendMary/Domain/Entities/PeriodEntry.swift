import Foundation

struct PeriodEntry: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var intensity: PeriodIntensity?
}
