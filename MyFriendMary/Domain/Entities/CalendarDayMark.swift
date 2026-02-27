import Foundation

struct CalendarDayMark: Codable, Equatable {
    var day: Date
    var hasPeriod: Bool
    var isPredictedFertile: Bool
    var hasSymptoms: Bool
    var hasSexEntry: Bool
}
