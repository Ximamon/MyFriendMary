import Foundation

struct CalendarDayMark: Codable, Equatable {
    var day: Date
    var hasPeriod: Bool
    var isPredictedFertile: Bool
    var hasSymptoms: Bool
    var hasSexEntry: Bool
    var isOrgasmPeakDay: Bool
    var hasRingUsage: Bool
    var hasRingBreak: Bool
}
